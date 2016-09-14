//
//  PHMemoryCache.swift
//  PHImageKit
//
// Copyright (c) 2016 Product Hunt (http://producthunt.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

class PHMemoryCache: NSCache<AnyObject, AnyObject>, PHCacheProtocol {

    override init() {
        super.init()

        setCacheSize(50)

        countLimit = 150

        evictsObjectsWithDiscardedContent = true

        name = imageKitDomain + "memoryCache"
    }

    func saveImageObject(_ object: PHImageObject, key: String, completion: PHVoidCompletion? = nil) {
        if let image = object.image {
            self.setObject(image, forKey: key as AnyObject, cost: image.ik_memoryCost)
        }
    }

    func getImageObject(_ key: String, completion: @escaping PHManagerCompletion) {
        guard let image = object(forKey: key as AnyObject) as? UIImage else {
            completion(nil)
            return
        }

        completion(PHImageObject(image: image))
    }

    func isCached(_ key: String) -> Bool {
        return object(forKey: key as AnyObject) != nil
    }

    func removeImageObject(_ key: String, completion: PHVoidCompletion? = nil) {
        removeObject(forKey: key as AnyObject)
    }

    func clear(_ completion: PHVoidCompletion? = nil) {
        removeAllObjects()
    }

    func setCacheSize(_ size: Int) {
        totalCostLimit = max(50, min(size, 250)) * 1024 * 1024
    }

    func cacheSize() -> Int {
        return 0
    }
    
}
