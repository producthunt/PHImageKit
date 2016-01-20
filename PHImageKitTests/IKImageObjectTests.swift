//
//  IKImageObjectTests.swift
//  PHImageKit
//
//  Created by Vlado on 12/7/15.
//  Copyright © 2015 Product Hunt. All rights reserved.
//

import XCTest

class IKImageObjectTests: XCTestCase {

    func testThatItHandlesProperlyImageData() {
        let imageObject = IKImageObject(data: ik_imageData())!

        XCTAssertNotNil(imageObject.image)
        XCTAssertNil(imageObject.gif)
    }

    func testThatItHandlesProperlyGifData() {
        let imageObject = IKImageObject(data: ik_gifData())!

        XCTAssertNil(imageObject.image)
        XCTAssertNotNil(imageObject.gif)
    }

    func testThatItReturnsNilForInvalidData() {
        let imageObject = IKImageObject(data: NSData())
        XCTAssertNil(imageObject)
    }

    func testThatItReturnsNilIfNoData() {
        let imageObject = IKImageObject()
        XCTAssertNil(imageObject)
    }

}
