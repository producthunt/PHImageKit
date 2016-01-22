//
//  PHMemoryCacheTests.swift
//  PHImageKit
//
//  Created by Vlado on 12/7/15.
//  Copyright © 2015 Product Hunt. All rights reserved.
//

import XCTest

@testable import PHImageKit

class PHMemoryCacheTests: XCTestCase {

    let cache = PHMemoryCache()
    let testPath = "https://example.com"

    override func tearDown() {
        cache.clear()
        super.tearDown()
    }

    func testThatItCachesImage() {
        let object = PHImageObject(data: ik_imageData())!

        let key = NSURL(string: testPath)!.ik_cacheKey()

        cache.saveImageObject(object, key: key)

        XCTAssertTrue(cache.isCached(key))
    }

    func testThatItCachesNotSaveGif() {
        let object = PHImageObject(data: ik_gifData())!

        let key = NSURL(string: testPath)!.ik_cacheKey()

        cache.saveImageObject(object, key: key)

        XCTAssertFalse(cache.isCached(key))
    }

    func testThatItGetsCachedImage() {
        let object = PHImageObject(data: ik_imageData())!

        let key = NSURL(string: testPath)!.ik_cacheKey()

        cache.saveImageObject(object, key: key)

        let cachedObject = cache.getImageObject(key)!

        XCTAssertNotNil(cachedObject.image)
        XCTAssertNil(cachedObject.gif)
    }

    func testThatItRemovesCachedImage() {
        let object = PHImageObject(data: ik_imageData())!

        let key = NSURL(string: testPath)!.ik_cacheKey()

        cache.saveImageObject(object, key: key)

        XCTAssertTrue(cache.isCached(key))

        cache.removeImageObject(key)

        XCTAssertFalse(cache.isCached(key))
    }

    func testThatItRemovesAllCachedImages() {
        var keys = [String]()
        for i in 0...5 {
            let image = ik_createImage(UIColor.whiteColor(), size: CGSize(width: 1+i, height: 1+1))
            let object = PHImageObject(data: UIImagePNGRepresentation(image))!
            let key = NSURL(string: "https://example.com" + "\(i)")!.ik_cacheKey()

            keys.append(key)

            cache.saveImageObject(object, key: key)
        }

        cache.clear()
        
        var exist : Bool = true
        for key in keys {
            exist = cache.isCached(key)
        }
        
        XCTAssertFalse(exist)
    }
}
