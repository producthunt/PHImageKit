//
//  IKCacheTests.swift
//  PHImageKit
//
//  Created by Vlado on 12/7/15.
//  Copyright © 2015 Product Hunt. All rights reserved.
//

import XCTest

class IKCacheTests: XCTestCase {

    let cache = IKCache()
    let baseURl = NSURL(string: "http://producthunt.com/example.jpg")!
    
    override func tearDown() {
        cache.clearMemoryCache()
        cache.clearFileChache(nil)
        super.tearDown()
    }

    func testThatItClearMemoryCacheIfMemoryWarning() {
        let image   = ik_createImage(UIColor.whiteColor(), size: CGSize(width: 10, height: 10))

        let object = IKImageObject(data: UIImagePNGRepresentation(image))!

        cache.saveImage(object, url: baseURl)

        ik_expectation("File cache clean expectation") { (expectation) -> Void in
            self.cache.clearFileChache {

                XCTAssertTrue(self.cache.isImageCached(self.baseURl))

                NSNotificationCenter.defaultCenter().postNotificationName(UIApplicationDidReceiveMemoryWarningNotification, object: nil)

                XCTAssertFalse(self.cache.isImageCached(self.baseURl))

                expectation.fulfill()
            }
        }
    }


}
