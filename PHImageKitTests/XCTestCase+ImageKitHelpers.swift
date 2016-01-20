//
//  XCTest+Helpers.swift
//  PHImageKit
//
//  Created by Vlado on 12/7/15.
//  Copyright © 2015 Product Hunt. All rights reserved.
//

import XCTest

extension XCTestCase {

    func ik_expectation(description: String, fulfill: (expectation: XCTestExpectation) -> Void) {
        let expectation = expectationWithDescription(description)

        fulfill(expectation: expectation)

        waitForExpectationsWithTimeout(5, handler: nil)
    }

    func ik_createImage(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.mainScreen().scale)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return UIImage(CGImage: image.CGImage!)
    }

    func ik_imageData() -> NSData {
        let image = ik_createImage(UIColor.whiteColor(), size: CGSizeMake(10, 10))
        return UIImagePNGRepresentation(image)!
    }

    func ik_gifData() -> NSData {
        let url = NSBundle.mainBundle().URLForResource("kittyGif", withExtension: "gif")
        return NSData(contentsOfURL: url!)!
    }

}
