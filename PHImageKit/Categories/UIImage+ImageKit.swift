//
//  UIImage+ImageKit.swift
//  PHImageKit
//
// Copyright (c) 2016 Product Hunt (http://producthunt.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

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