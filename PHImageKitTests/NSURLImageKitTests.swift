//
//  NSURL+ImageKitTests.swift
//  PHImageKit
//
//  Created by Vlado on 12/6/15.
//  Copyright © 2015 Product Hunt. All rights reserved.
//

import XCTest

@testable import PHImageKit

class NSURLImageKitTests: XCTestCase {

    func testThatHTTPShouldBeValidURL() {
        let url = URL(string: "http://example.com")!
        XCTAssertTrue(url.ik_isValid())
    }

    func testThatHTTPSShouldBeValidURL() {
        let url = URL(string: "https://example.com")!
        XCTAssertTrue(url.ik_isValid())
    }

    func testThatDeepLinkShouldNotBeValidURL() {
        let url = URL(string: "hello://example.com")!
        XCTAssertFalse(url.ik_isValid())
    }
}
