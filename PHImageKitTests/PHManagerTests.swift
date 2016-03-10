//
//  PHManagerTests.swift
//  PHImageKit
//
//  Created by Vlado on 12/7/15.
//  Copyright © 2015 Product Hunt. All rights reserved.
//

import XCTest

@testable import PHImageKit

class PHManagerTests: XCTestCase {

    let manager = PHManager.sharedInstance
    let urlPath = "http://producthunt.com/test.jpg"

    override class func setUp() {
        super.setUp()
        LSNocilla.sharedInstance().start()
    }

    override class func tearDown() {
        super.tearDown()
        LSNocilla.sharedInstance().stop()
    }

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        LSNocilla.sharedInstance().clearStubs()
        manager.purgeCache(includingFileCache: true)
        super.tearDown()
    }

    func testThatItLoadImageFromWeb() {
        let url = NSURL(string: urlPath)!

        stubRequest("GET", urlPath).andReturn(200).withBody(ik_imageData())

        ik_expectation("Mager  expectation") { (expectation) -> Void in
            self.manager.purgeCache(includingFileCache: true, completion: {
                self.manager.imageWithUrl(url, progress: { (percent) -> Void in }, completion: { (object) -> Void in
                    XCTAssertNotNil(object!.image)
                    XCTAssertNil(object!.gif)
                    XCTAssertNotNil(object!.data)

                    expectation.fulfill()
                })
            })
        }
    }

    func testThatItDownloadsGifFromWeb() {
        let url = NSURL(string: urlPath)!

        stubRequest("GET", urlPath).andReturn(200).withBody(ik_gifData())

        ik_expectation("Mager  expectation") { (expectation) -> Void in
            self.manager.purgeCache(includingFileCache: true, completion: {
                self.manager.imageWithUrl(url, progress: { (percent) -> Void in }, completion: { (object) -> Void in
                    XCTAssertNil(object!.image)
                    XCTAssertNotNil(object!.gif)
                    XCTAssertNotNil(object!.data)
                    expectation.fulfill()
                })
            })
        }
    }

    func testThatItPullsImageFromCache() {
        let url = NSURL(string: urlPath)!

        stubRequest("GET", urlPath).andReturn(200).withBody(ik_imageData())

        ik_expectation("Mager  expectation") { (expectation) -> Void in
            self.manager.purgeCache(includingFileCache: true, completion: {
                self.manager.imageWithUrl(url, progress: { (percent) -> Void in }, completion: { (object) -> Void in

                    LSNocilla.sharedInstance().clearStubs()

                    self.manager.imageWithUrl(url, progress: { (percent) -> Void in }, completion: { (object) -> Void in
                        XCTAssertNotNil(object!.image)
                        XCTAssertNil(object!.gif)
                        XCTAssertNil(object!.data)
                        expectation.fulfill()
                    })
                })
            })
        }
    }

}
