//
//  PHImageObjectTests.swift
//  PHImageKit
//
//  Created by Vlado on 12/7/15.
//  Copyright © 2015 Product Hunt. All rights reserved.
//

import XCTest

@testable import PHImageKit

class PHImageObjectTests: XCTestCase {

    func testThatItHandlesProperlyImageData() {
        let imageObject = PHImageObject(data: ik_imageData())!

        XCTAssertNotNil(imageObject.image)
        XCTAssertNil(imageObject.gif)
    }

    func testThatItHandlesProperlyGifData() {
        let imageObject = PHImageObject(data: ik_gifData())!

        XCTAssertNil(imageObject.image)
        XCTAssertNotNil(imageObject.gif)
    }

    func testThatItReturnsNilForInvalidData() {
        let imageObject = PHImageObject(data: NSData())
        XCTAssertNil(imageObject)
    }

    func testThatItReturnsNilIfNoData() {
        let imageObject = PHImageObject()
        XCTAssertNil(imageObject)
    }

}
