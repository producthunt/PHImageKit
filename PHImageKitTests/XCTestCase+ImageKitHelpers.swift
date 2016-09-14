//
//  XCTest+Helpers.swift
//  PHImageKit
//
//  Created by Vlado on 12/7/15.
//  Copyright © 2015 Product Hunt. All rights reserved.
//

import XCTest

@testable import PHImageKit

extension XCTestCase {

    func ik_expectation(_ description: String, fulfill: (_ expectation: XCTestExpectation) -> Void) {
        let expectation = self.expectation(description: description)

        fulfill(expectation)

        waitForExpectations(timeout: 5, handler: nil)
    }

    func ik_createImage(_ color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return UIImage(cgImage: image.cgImage!)
    }

    func ik_imageData() -> Data {
        let image = ik_createImage(UIColor.white, size: CGSize(width: 10, height: 10))
        return UIImagePNGRepresentation(image)!
    }

    func ik_gifData() -> Data {
        let url = Bundle.main.url(forResource: "kittyGif", withExtension: "gif")
        return try! Data(contentsOf: url!)
    }

}
