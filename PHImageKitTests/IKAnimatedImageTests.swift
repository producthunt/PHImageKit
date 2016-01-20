//
//  IKAnimatedImageTests.swift
//  PHImageKit
//
//  Created by Vlado on 12/7/15.
//  Copyright © 2015 Product Hunt. All rights reserved.
//

import XCTest

class IKAnimatedImageTests: XCTestCase {

    func testThatItCanBeInitedWithGifData() {
        let image = IKAnimatedImage(initWithAnimatedGIFData: ik_gifData())
        XCTAssertNotNil(image)
    }

    func testThatItWontCrashIfInitWithWrongData() {
        let image = IKAnimatedImage(initWithAnimatedGIFData: NSData())
        XCTAssertNotNil(image)
    }

    func testThatItWontCrashIfInitedWithImageData() {
        let image = IKAnimatedImage(initWithAnimatedGIFData: ik_imageData())
        XCTAssertNotNil(image)
    }

    func testThatFrameCountIsAssignedToGif() {
        let image = IKAnimatedImage(initWithAnimatedGIFData: ik_gifData())
        XCTAssertNotEqual(image.frameCount, 0)
    }

    func testThatFrameCountIsZeroWithImageData() {
        let image = IKAnimatedImage(initWithAnimatedGIFData: ik_imageData())
        XCTAssertEqual(image.frameCount, 0)
    }

    func testThatItReturnsPosterImageIfGif() {
        let image = IKAnimatedImage(initWithAnimatedGIFData: ik_gifData())
        XCTAssertNotNil(image.posterImage)
    }

    func testThatItHasPosterImage() {
        let image = IKAnimatedImage(initWithAnimatedGIFData: ik_gifData())
        XCTAssertNotNil(image.posterImage)
    }

    func testThatItReturnsLoopCount() {
        let image = IKAnimatedImage(initWithAnimatedGIFData: ik_gifData())
        XCTAssertGreaterThan(image.loopCount, 1)
    }

    func testThatItReturnsFrameCount() {
        let image = IKAnimatedImage(initWithAnimatedGIFData: ik_gifData())
        XCTAssertGreaterThan(image.frameCount, 1)
    }
}
