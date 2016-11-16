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
//        LSNocilla.sharedInstance().start()
    }

    override class func tearDown() {
        super.tearDown()
//        LSNocilla.sharedInstance().stop()
    }

    override func tearDown() {
//        LSNocilla.sharedInstance().clearStubs()
        super.tearDown()
    }

    func testDownloadImage() {
//        let url = URL(string: urlPath)!
//
//        let expectedData = ik_imageData()
//
//        stubRequest("GET", urlPath as LSMatcheable!).withBody(expectedData)
//
//        ik_expectation("Image download expectation") { (expectation) -> Void in
//
//            let _ = self.downloader.download(url, progress: { (percent) -> Void in }, completion: { (imageObject, error) -> Void in
//                XCTAssertNotNil(imageObject!.image)
//                XCTAssertEqual(imageObject!.data, expectedData)
//                XCTAssertNil(error)
//                expectation.fulfill()
//            })
//        }
    }

    func testThatReturnsErrorForInvalidUrlScheme() {
//        let url = URL(string: "file://localFile")
//
//        stubRequest("GET", urlPath as LSMatcheable!)
//
//        ik_expectation("Invalid url error expectaion") { (expectation) -> Void in
//            let _ = self.downloader.download(url!, progress: { (percent) -> Void in }, completion: { (imageObject, error) -> Void in
//                XCTAssertNil(imageObject)
//                XCTAssertEqual(error, NSError.ik_invalidUrlError())
//                expectation.fulfill()
//            })
//        }
    }

    func testThatReturnsErrorForEmptyUrl() {
//        let url = URL(string: "")
//
//        stubRequest("GET", urlPath as LSMatcheable!)
//
//        ik_expectation("Error for empty url") { (expectation) -> Void in
//            let _ = self.downloader.download(url!, progress: { (percent) -> Void in }, completion: { (imageObject, error) -> Void in
//                XCTAssertNil(imageObject)
//                XCTAssertEqual(error, NSError.ik_invalidUrlError())
//                expectation.fulfill()
//            })
//        }
    }

    func testThatItReturnsServerError() {
//        let url = URL(string: urlPath)
//
//        stubRequest("GET", urlPath as LSMatcheable!).andFailWithError(NSError(domain: "error", code: 404, userInfo: nil))
//
//        ik_expectation("Server error expectation") { (expectation) -> Void in
//            let _ = self.downloader.download(url!, progress: { (percent) -> Void in }, completion: { (imageObject, error) -> Void in
//                XCTAssertNil(imageObject)
//                XCTAssertNotNil(error)
//                expectation.fulfill()
//            })
//        }
    }

    func testThatItFailsWithInvalidImageDataError() {
//        let url = URL(string: urlPath)
//
//        stubRequest("GET", urlPath as LSMatcheable!).andReturn(200)?.withBody(Data())
//
//        ik_expectation("Invalid data expectation") { (expectation) -> Void in
//            let _ = self.downloader.download(url!, progress: { (percent) -> Void in }, completion: { (imageObject, error) -> Void in
//                XCTAssertNil(imageObject)
//                XCTAssertEqual(error, NSError.ik_invalidDataError())
//                expectation.fulfill()
//            })
//        }
    }

    func testDownloadRetry() {
//        let url = URL(string: urlPath)
//
//        let expectedData = ik_imageData()
//
//        let expectedError = NSError(domain: "test.domain", code: -1, userInfo: nil)
//
//        stubRequest("GET", urlPath as LSMatcheable!).andFailWithError(expectedError)
//
//        ik_expectation("Download retry expectation") { (expectation) -> Void in
//            let _ = self.downloader.download(url!, progress: { (percent) -> Void in }, completion: { (imageObject, error) -> Void in
//
//                XCTAssertEqual(error, expectedError)
//
//                LSNocilla.sharedInstance().clearStubs()
//
//                stubRequest("GET", self.urlPath as LSMatcheable!).andReturn(200)?.withBody(expectedData)
//
//               let _ = self.downloader.download(url!, progress: { (percent) -> Void in }, completion: { (imageObject, error) -> Void in
//                    XCTAssertNotNil(imageObject!.image)
//                    XCTAssertEqual(imageObject!.data, expectedData)
//                    XCTAssertNil(error)
//                    expectation.fulfill()
//                })
//            })
//        }
    }
}
