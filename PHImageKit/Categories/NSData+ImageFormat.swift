//
//  NSData+ImageFormat.swift
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

import Foundation

private let pngHeader   : [UInt8] = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
private let jpgHeaderSOI: [UInt8] = [0xFF, 0xD8]
private let jpgHeaderIF : [UInt8] = [0xFF]
private let gifHeader   : [UInt8] = [0x47, 0x49, 0x46]

extension NSData {

    enum PHImageFormat : Int {
        case PNG
        case JPEG
        case GIF
        case Unknown
    }

    var ik_imageFormat: PHImageFormat {
        var buffer = [UInt8](count: 8, repeatedValue: 0)

        self.getBytes(&buffer, length: 8)

        if buffer == pngHeader {
            return .PNG
        }

        if buffer[0] == jpgHeaderSOI[0] && buffer[1] == jpgHeaderSOI[1] && buffer[2] == jpgHeaderIF[0] {
            return .JPEG
        }

        if buffer[0] == gifHeader[0] && buffer[1] == gifHeader[1] && buffer[2] == gifHeader[2] {
            return .GIF
        }

        return .Unknown
    }

}
