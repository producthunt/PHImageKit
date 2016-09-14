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
            let imageRef = self.cgImage;
            let bytesPerPixel = imageRef!.bitsPerPixel / 8;
            return imageRef!.width * imageRef!.height * bytesPerPixel;
        }
    }

    //NOTE: (Vlado) For super smooth image loading. Inspired from https://gist.github.com/steipete/1144242
    func predrawnImageFromImage(_ imageToPredraw:UIImage) -> UIImage? {
        let colorSpaceDeviceRGBRef = CGColorSpaceCreateDeviceRGB()

        let numberOfComponents = colorSpaceDeviceRGBRef.numberOfComponents + 1
        let width = imageToPredraw.size.width
        let height = imageToPredraw.size.height
        let bitsPerComponent = Int(CHAR_BIT)

        let bitsPerPixel = bitsPerComponent * numberOfComponents
        let bytesPerPixel = bitsPerPixel/Int(BYTE_SIZE)
        let bytesPerRow = bytesPerPixel * Int(width)

        let bitmapInfo:CGBitmapInfo = []

        var alphaInfo = imageToPredraw.cgImage!.alphaInfo

        switch alphaInfo {
        case .none, .alphaOnly   : alphaInfo = CGImageAlphaInfo.noneSkipFirst
        case .first         : alphaInfo = CGImageAlphaInfo.premultipliedFirst
        case .last          : alphaInfo = CGImageAlphaInfo.premultipliedLast
        default             : break
        }

        let info = bitmapInfo.rawValue | alphaInfo.rawValue

        let bitmapContextRef = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpaceDeviceRGBRef, bitmapInfo: info)

        if bitmapContextRef == nil {
            print("Failed to `CGBitmapContextCreate` with color space \(colorSpaceDeviceRGBRef) and parameters (width: \(width) height: \(height) bitsPerComponent: \(bitsPerComponent) bytesPerRow: \(bytesPerRow)) for image \(imageToPredraw)")
            return nil
        }

        bitmapContextRef?.draw(imageToPredraw.cgImage!, in: CGRect(x: 0, y: 0, width: imageToPredraw.size.width, height: imageToPredraw.size.height))

        let predrawnImageRef = bitmapContextRef!.makeImage()

        return UIImage(cgImage: predrawnImageRef!, scale: imageToPredraw.scale, orientation: imageToPredraw.imageOrientation)
    }
}
