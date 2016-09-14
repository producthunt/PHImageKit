//
//  PHFileCacheTests.swift
//  PHImageKit
//
//  Created by Vlado on 12/7/15.
//  Copyright © 2015 Product Hunt. All rights reserved.
//

import XCTest

@testable import PHImageKit

class PHFileCacheTests: XCTestCase {

    let cache = PHFileCache()
    let testPath = "https://example.com"

    override func tearDown() {
        cache.clear()
        super.tearDown()
    }

    func testThatItCachesImage() {
        let object = PHImageObject(data: ik_imageData())!

        let key = URL(string: testPath)!.ik_cacheKey()

        ik_expectation(description: "Save in cache expectation") { (expectation) -> Void in
            self.cache.saveImageObject(object, key: key) {
                XCTAssertTrue(self.cache.isCached(key))
                expectation.fulfill()
            }
        }
    }

    func testThatItCachesGif() {
        let object = PHImageObject(data: ik_gifData())!

        let key = URL(string: testPath)!.ik_cacheKey()

        ik_expectation(description: "Save in cache expectation") { (expectation) -> Void in
            self.cache.saveImageObject(object, key: key) {
                XCTAssertTrue(self.cache.isCached(key))
                expectation.fulfill()
            }
        }
    }

    func testThatItGetsCachedImage() {
        let object = PHImageObject(data: ik_imageData())!
        let key = URL(string: testPath)!.ik_cacheKey()

        ik_expectation(description: "File cache worker expectation") { (expectation) -> Void in
            self.cache.saveImageObject(object, key: key, completion: {
                self.cache.getImageObject(key, completion: { (object) -> Void in
                    XCTAssertNotNil(object!.image)
                    XCTAssertNil(object!.gif)

                    expectation.fulfill()
                })
            })
        }
    }

    func testThatItGetsCachedGif() {
        let object = PHImageObject(data: ik_gifData())!
        let key = URL(string: testPath)!.ik_cacheKey()

        ik_expectation(description: "File cache worker expectation") { (expectation) -> Void in
            self.cache.saveImageObject(object, key: key, completion: {

                self.cache.getImageObject(key, completion: { (object) -> Void in
                    XCTAssertNil(object!.image)
                    XCTAssertNotNil(object!.gif)

                    expectation.fulfill()
                })
            })
        }
    }

    func testThatItRemovesCachedImage() {
        let object = PHImageObject(data: ik_imageData())!
        let key = URL(string: testPath)!.ik_cacheKey()

        ik_expectation(description: "File cache worker expectation") { (expectation) -> Void in
            self.cache.saveImageObject(object, key: key, completion: {
                XCTAssertTrue(self.cache.isCached(key))

                self.cache.removeImageObject(key, completion: {
                    XCTAssertFalse(self.cache.isCached(key))
                    expectation.fulfill()
                })

            })
        }
    }

    func testThatItRemovesCachedGif() {
        let object = PHImageObject(data: ik_gifData())!
        let key = URL(string: testPath)!.ik_cacheKey()

        ik_expectation(description: "File cache worker expectation") { (expectation) -> Void in
            self.cache.saveImageObject(object, key: key, completion: {
                XCTAssertTrue(self.cache.isCached(key))

                self.cache.removeImageObject(key, completion: {
                    XCTAssertFalse(self.cache.isCached(key))
                    expectation.fulfill()
                })
            })
        }
    }

    func testThatItRemovesAllCachedImages() {
        ik_expectation(description: "File cache worker expectation") { (expectation) -> Void in

            let group = dispatch_group_create()

            var keys = [String]()
            for i in 0...5 {
                dispatch_group_enter(group)
                let image = self.ik_createImage(UIColor.whiteColor(), size: CGSize(width: 1+i, height: 1+1))
                let object = PHImageObject(data: UIImagePNGRepresentation(image))!
                let key = NSURL(string: "https://example.com" + "\(i)")!.ik_cacheKey()

                keys.append(key)

                self.cache.saveImageObject(object, key: key, completion: {
                    dispatch_group_leave(group)
                })
            }

            dispatch_group_notify(group, dispatch_get_main_queue()) {
                self.cache.clear {
                    var exist : Bool = true
                    for key in keys {
                        exist = self.cache.isCached(key)
                    }
                    
                    XCTAssertFalse(exist)
                    
                    expectation.fulfill()
                }
            }
        }
    }

    func testThatReturnsCachedSize() {
        let object = PHImageObject(data: ik_imageData())!

        let key = URL(string: testPath)!.ik_cacheKey()

        ik_expectation(description: "Save in cache expectation") { (expectation) -> Void in
            self.cache.saveImageObject(object, key: key) {
                XCTAssertTrue(self.cache.cacheSize() > 0)
                expectation.fulfill()
            }
        }
    }
    
}
