//
//  UIImage+ImageKit.swift
//  PHImageKit
//
//  Created by Vlado on 12/6/15.
//  Copyright © 2015 Product Hunt. All rights reserved.
//

import UIKit

extension UIImage {

    var ik_memoryCost : Int {
        get {
            let imageRef = self.CGImage;
            let bytesPerPixel = CGImageGetBitsPerPixel(imageRef) / 8;
            return CGImageGetWidth(imageRef) * CGImageGetHeight(imageRef) * bytesPerPixel;
        }
    }

    //NOTE: (Vlado) For super smooth image loading. Inspired from https://gist.github.com/steipete/1144242
    func ik_decompress() -> UIImage {
        let originalImageRef = self.CGImage
        let originalBitmapInfo = CGImageGetBitmapInfo(originalImageRef)
        let alphaInfo = CGImageGetAlphaInfo(originalImageRef)

        var bitmapInfo = originalBitmapInfo
        switch (alphaInfo) {
        case .None:
            let rawBitmapInfoWithoutAlpha = bitmapInfo.rawValue & ~CGBitmapInfo.AlphaInfoMask.rawValue
            let rawBitmapInfo = rawBitmapInfoWithoutAlpha | CGImageAlphaInfo.NoneSkipFirst.rawValue
            bitmapInfo = CGBitmapInfo(rawValue: rawBitmapInfo)
        case .PremultipliedFirst, .PremultipliedLast, .NoneSkipFirst, .NoneSkipLast:
            break
        case .Only, .Last, .First: // Unsupported
            return self
        }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let pixelSize = CGSizeMake(self.size.width * self.scale, self.size.height * self.scale)
        guard let context = CGBitmapContextCreate(nil, Int(ceil(pixelSize.width)), Int(ceil(pixelSize.height)), CGImageGetBitsPerComponent(originalImageRef), 0, colorSpace, bitmapInfo.rawValue) else {
            return self
        }

        let imageRect = CGRectMake(0, 0, pixelSize.width, pixelSize.height)
        UIGraphicsPushContext(context)

        CGContextTranslateCTM(context, 0, pixelSize.height)
        CGContextScaleCTM(context, 1.0, -1.0)

        self.drawInRect(imageRect)
        UIGraphicsPopContext()

        guard let decompressedImageRef = CGBitmapContextCreateImage(context) else {
            return self
        }

        return UIImage(CGImage: decompressedImageRef, scale:UIScreen.mainScreen().scale, orientation:UIImageOrientation.Up)
    }
}