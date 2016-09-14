//
//  PHCache.swift
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

class PHCache: NSObject {

    fileprivate let memoryCache = PHMemoryCache()
    fileprivate let fileCache   = PHFileCache()

    override init() {
        super.init()
        addObservers()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /**
     Save image in cache. File will be saved both in memory and file cache

     - Parameters:
     - imageObject:
     - url: Image URL. Cache key is generated from the URL.
     */
    func saveImage(_ imageObject: PHImageObject, url: URL) {
        let key = cacheKey(url)

        memoryCache.saveImageObject(imageObject, key: key)
        fileCache.saveImageObject(imageObject, key: key)
    }

    /**
     Get image from the cache. If image is in memory cache `completion` will be called.
     If image is in file cache will be loaded in memory and then `completion` will be called

     - Parameters:
     - url: Image URL. Cache key is generated from the URL
     - completion: Completion closure called when image is loaded
     */
    func getImage(_ url: URL, completion: @escaping PHManagerCompletion) {
        let key = cacheKey(url)

        if memoryCache.isCached(key) {
            memoryCache.getImageObject(key, completion: completion)
            return
        }

        fileCache.getImageObject(key) { (object) in
            guard let object = object  else {
                completion(nil)
                return
            }

            self.memoryCache.saveImageObject(object, key: key)

            completion(object)
        }
    }

    /**
     Check if image is in memory or file cache

     parameter url: Image URL
     */
    func isImageCached(_ url: URL) -> Bool {
        let key = cacheKey(url)
        return memoryCache.isCached(key) || fileCache.isCached(key)
    }

    /**
     Evict image from both file and memory cache

     - parameters:
     - url: Image URL
     - completion: Optional completion closure
     */
    func removeImage(_ url: URL, completion: PHVoidCompletion? = nil) {
        let key = cacheKey(url)

        memoryCache.removeImageObject(key)

        fileCache.removeImageObject(key, completion: completion)
    }

    /**
     Change memory and file cache size

     - parameters:
     - memoryCacheSize: Size for memory cache in MB. Minimum 50 mb. maximum 250 mb. Default is 50 mb.
     - fileCacheSize: Size for file cache in MB. Minimum 50 mb. maximum 500 mb. Default is 200 mb.
     */
    func setCacheSize(_ memoryCacheSize: UInt, fileCacheSize: UInt) {
        memoryCache.setCacheSize(memoryCacheSize)
        fileCache.setCacheSize(fileCacheSize)
    }

    /**
     Clear memory cache
     */
    func clearMemoryCache() {
        memoryCache.clear()
    }

    /**
     Clear file cache

     - parameter completion: Optional completion closure
     */
    func clearFileChache(_ completion: PHVoidCompletion?) {
        fileCache.clear(completion)
    }

    /**
     Clear expired images from image cache. If image is older than 1 week by default,
     will be removed from the file cache.
     */
    func cleanExpiredDiskCache() {
        fileCache.clearExpiredImages()
    }

    /**
     Clear expired and overexeeded max size file cache. If file cache is bigger than maxFileCache size,
     oldest files will be removed while file chache is 50% of the max size.
     */
    func backgroundCleanExpiredDiskCache() {
        var backgroundTask: UIBackgroundTaskIdentifier = 0

        backgroundTask = UIApplication.shared.beginBackgroundTask (expirationHandler: {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = UIBackgroundTaskInvalid
        })

        fileCache.clearExpiredImages {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = UIBackgroundTaskInvalid
        }
    }

    /**
     Get size of the cache.

     - returns: Size of cached files in kb.
     */
    func cacheSize() -> UInt {
        return fileCache.cacheSize()
    }

    fileprivate func cacheKey(_ url: URL) -> String {
        return url.absoluteString.ik_MD5
    }

    fileprivate func addObservers() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(PHCache.clearMemoryCache), name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: nil)
        center.addObserver(self, selector: #selector(PHCache.cleanExpiredDiskCache), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
        center.addObserver(self, selector: #selector(PHCache.backgroundCleanExpiredDiskCache), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
}
