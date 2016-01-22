//
//  PHImageObject.swift
//  PHImageKit
//
//  Created by Vlado on 12/7/15.
//  Copyright © 2015 Product Hunt. All rights reserved.
//

import UIKit

public class PHImageObject {

    public var image: UIImage?
    public var gif: PHAnimatedImage?
    public var data: NSData?

    public init?(data: NSData? = nil) {
        guard let data = data else {
            return nil
        }

        self.data = data

        switch data.ik_imageFormat {

        case .PNG, .JPEG :
            image = UIImage(data: data, scale: UIScreen.mainScreen().scale)?.ik_decompress()

        case .GIF :
            gif = PHAnimatedImage(initWithAnimatedGIFData: data)


        default :
            return nil
        }
    }

    public init(image: UIImage) {
        self.image = image
    }

}