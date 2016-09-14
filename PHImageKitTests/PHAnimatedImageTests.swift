//
//  PHAnimatedImageTests.swift
//  PHImageKit
//
//  Created by Vlado on 12/7/15.
//  Copyright © 2015 Product Hunt. All rights reserved.
//

import XCTest

@testable import PHImageKit

class PHAnimatedImageTests: XCTestCase {

    func testThatItCanBeInitedWithGifData() {
        let image = PHAnimatedImage(initWithAnimatedGIFData: ik_gifData())
        XCTAssertNotNil(image)
    }

    func testThatItWontCrashIfInitWithWrongData() {
        let image = PHAnimatedImage(initWithAnimatedGIFData: Data())
        XCTAssertNotNil(image)
    }

    func testThatItWontCrashIfInitedWithImageData() {
        let image = PHAnimatedImage(initWithAnimatedGIFData: ik_imageData())
        XCTAssertNotNil(image)
    }

    func testThatFrameCountIsAssignedToGif() {
        let image = PHAnimatedImage(initWithAnimatedGIFData: ik_gifData())
        XCTAssertNotEqual(image.frameCount, 0)
    }

    func testThatFrameCountIsZeroWithImageData() {
        let image = PHAnimatedImage(initWithAnimatedGIFData: ik_imageData())
        XCTAssertEqual(image.frameCount, 0)
    }

    func testThatItReturnsPosterImageIfGif() {
        let image = PHAnimatedImage(initWithAnimatedGIFData: ik_gifData())
        XCTAssertNotNil(image.posterImage)
    }

    func testThatItHasPosterImage() {
        let image = PHAnimatedImage(initWithAnimatedGIFData: ik_gifData())
        XCTAssertNotNil(image.posterImage)
    }

    func testThatItReturnsLoopCount() {
        let image = PHAnimatedImage(initWithAnimatedGIFData: ik_gifData())
        XCTAssertGreaterThan(image.loopCount, 1)
    }

    func testThatItReturnsFrameCount() {
        let image = PHAnimatedImage(initWithAnimatedGIFData: ik_gifData())
        XCTAssertGreaterThan(image.frameCount, 1)
    }
}
