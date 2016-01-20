//
//  IKImageObject.swift
//  PHImageKit
//
//  Created by Vlado on 12/7/15.
//  Copyright © 2015 Product Hunt. All rights reserved.
//

import UIKit

class IKImageObject {

    var image: UIImage?
    var gif: IKAnimatedImage?
    var data: NSData?

    //TODO: (Vlado) Investigate do we need this object.
    init?(data: NSData? = nil) {
        guard let data = data else {
            return nil
        }

        self.data = data

        switch data.ik_imageFormat {

        case .PNG, .JPEG :
            image = UIImage(data: data, scale: UIScreen.mainScreen().scale)?.ik_decompress()

        case .GIF :
            gif = IKAnimatedImage(initWithAnimatedGIFData: data)


        default :
            return nil
        }
    }

    init(image: UIImage) {
        self.image = image
    }

}