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
    func predrawnImageFromImage(imageToPredraw:UIImage) -> UIImage? {
        guard let colorSpaceDeviceRGBRef = CGColorSpaceCreateDeviceRGB() else {
            print("Failed to `CGColorSpaceCreateDeviceRGB` for image: \(imageToPredraw)")
            return nil
        }

        let numberOfComponents = CGColorSpaceGetNumberOfComponents(colorSpaceDeviceRGBRef) + 1
        let width = imageToPredraw.size.width
        let height = imageToPredraw.size.height
        let bitsPerComponent = Int(CHAR_BIT)

        let bitsPerPixel = bitsPerComponent * numberOfComponents
        let bytesPerPixel = bitsPerPixel/Int(BYTE_SIZE)
        let bytesPerRow = bytesPerPixel * Int(width)

        let bitmapInfo:CGBitmapInfo = CGBitmapInfo.ByteOrderDefault

        var alphaInfo = CGImageGetAlphaInfo(imageToPredraw.CGImage)

        switch alphaInfo {
        case .None, .Only   : alphaInfo = CGImageAlphaInfo.NoneSkipFirst
        case .First         : alphaInfo = CGImageAlphaInfo.PremultipliedFirst
        case .Last          : alphaInfo = CGImageAlphaInfo.PremultipliedLast
        default             : break
        }

        let info = bitmapInfo.rawValue | alphaInfo.rawValue

        let bitmapContextRef = CGBitmapContextCreate(nil, Int(width), Int(height), bitsPerComponent, bytesPerRow, colorSpaceDeviceRGBRef, info)

        if bitmapContextRef == nil {
            print("Failed to `CGBitmapContextCreate` with color space \(colorSpaceDeviceRGBRef) and parameters (width: \(width) height: \(height) bitsPerComponent: \(bitsPerComponent) bytesPerRow: \(bytesPerRow)) for image \(imageToPredraw)")
            return nil
        }

        CGContextDrawImage(bitmapContextRef, CGRectMake(0, 0, imageToPredraw.size.width, imageToPredraw.size.height), imageToPredraw.CGImage)

        let predrawnImageRef = CGBitmapContextCreateImage(bitmapContextRef)

        return UIImage(CGImage: predrawnImageRef!, scale: imageToPredraw.scale, orientation: imageToPredraw.imageOrientation)
    }
}