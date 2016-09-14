//
//  PHDonwloaderTests.swift
//  PHImageKit
//
//  Created by Vlado on 12/7/15.
//  Copyright © 2015 Product Hunt. All rights reserved.
//

import XCTest
import UIKit

@testable import PHImageKit

class PHDonwloaderTests: XCTestCase {

    let downloader = PHDownloader()
    let urlPath = "http://producthunt.com/test.jpg"

    override class func setUp() {
        super.setUp()
        LSNocilla.sharedInstance().start()
    }

    override class func tearDown() {
        super.tearDown()
        LSNocilla.sharedInstance().stop()
    }

    override func tearDown() {
        LSNocilla.sharedInstance().clearStubs()
        super.tearDown()
    }

    func testDownloadImage() {
        let url = URL(string: urlPath)!

        let expectedData = ik_imageData()

        stubRequest("GET", urlPath as LSMatcheable!).andReturn(200)?.withBody(expectedData)

        ik_expectation(description: "Image download expectation") { (expectation) -> Void in

            self.downloader.download(url, progress: { (percent) -> Void in }, completion: { (imageObject, error) -> Void in
                XCTAssertNotNil(imageObject!.image)
                XCTAssertEqual(imageObject!.data, expectedData)
                XCTAssertNil(error)
                expectation.fulfill()
            })
        }
    }

    func testThatReturnsErrorForInvalidUrlScheme() {
        let url = NSURL(string: "file://localFile")

        stubRequest("GET", urlPath)

        ik_expectation(description: "Invalid url error expectaion") { (expectation) -> Void in
            self.downloader.download(url!, progress: { (percent) -> Void in }, completion: { (imageObject, error) -> Void in
                XCTAssertNil(imageObject)
                XCTAssertEqual(error, NSError.ik_invalidUrlError())
                expectation.fulfill()
            })
        }
    }

    func testThatReturnsErrorForEmptyUrl() {
        let url = NSURL(string: "")

        stubRequest("GET", urlPath)

        ik_expectation("Error for empty url") { (expectation) -> Void in
            self.downloader.download(url!, progress: { (percent) -> Void in }, completion: { (imageObject, error) -> Void in
                XCTAssertNil(imageObject)
                XCTAssertEqual(error, NSError.ik_invalidUrlError())
                expectation.fulfill()
            })
        }
    }

    func testThatItReturnsServerError() {
        let url = NSURL(string: urlPath)

        stubRequest("GET", urlPath).andFailWithError(NSError(domain: "error", code: 404, userInfo: nil))

        ik_expectation("Server error expectation") { (expectation) -> Void in
            self.downloader.download(url!, progress: { (percent) -> Void in }, completion: { (imageObject, error) -> Void in
                XCTAssertNil(imageObject)
                XCTAssertNotNil(error)
                expectation.fulfill()
            })
        }
    }

    func testThatItFailsWithInvalidImageDataError() {
        let url = NSURL(string: urlPath)

        stubRequest("GET", urlPath).andReturn(200).withBody(NSData())

        ik_expectation("Invalid data expectation") { (expectation) -> Void in
            self.downloader.download(url!, progress: { (percent) -> Void in }, completion: { (imageObject, error) -> Void in
                XCTAssertNil(imageObject)
                XCTAssertEqual(error, NSError.ik_invalidDataError())
                expectation.fulfill()
            })
        }
    }

    func testDownloadRetry() {
        let url = NSURL(string: urlPath)

        let expectedData = ik_imageData()

        let expectedError = NSError(domain: "test.domain", code: -1, userInfo: nil)

        stubRequest("GET", urlPath).andFailWithError(expectedError)

        ik_expectation("Download retry expectation") { (expectation) -> Void in
            self.downloader.download(url!, progress: { (percent) -> Void in }, completion: { (imageObject, error) -> Void in

                XCTAssertEqual(error, expectedError)

                LSNocilla.sharedInstance().clearStubs()

                stubRequest("GET", self.urlPath).andReturn(200).withBody(expectedData)

                self.downloader.download(url!, progress: { (percent) -> Void in }, completion: { (imageObject, error) -> Void in
                    XCTAssertNotNil(imageObject!.image)
                    XCTAssertEqual(imageObject!.data, expectedData)
                    XCTAssertNil(error)
                    expectation.fulfill()
                })
            })
        }
    }
}
