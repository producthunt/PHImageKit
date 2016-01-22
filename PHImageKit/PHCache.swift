//
//  PHCache.swift
//  PHImageKit
//
//  Created by Vlado on 12/6/15.
//  Copyright © 2015 Product Hunt. All rights reserved.
//

import UIKit

class PHCache: NSObject {

    private let memoryCache = PHMemoryCache()
    private let fileCache   = PHFileCache()

    override init() {
        super.init()
        addObservers()
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    /**
     Save image in cache. File will be saved both in memory and file cache
     
     - Parameters: 
        - imageObject:
        - url: Image URL. Cache key is generated from the URL.
     */
    func saveImage(imageObject: PHImageObject, url: NSURL) {
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
    func getImage(url: NSURL, completion: PHManagerCompletion) {
        let key = cacheKey(url)

        if let object = memoryCache.getImageObject(key) {
            completion(object: object)
            return
        }

        let object = fileCache.getImageObject(key)

        if let object = object {
            memoryCache.saveImageObject(object, key: key)
        }

        completion(object: object)
    }

    /**
     Check if image is in memory or file cache
     
     parameter url: Image URL
    */
    func isImageCached(url: NSURL) -> Bool {
        let key = cacheKey(url)
        return memoryCache.isCached(key) || fileCache.isCached(key)
    }

    /**
    Evict image from both file and memory cache
     
    - parameters:
        - url: Image URL
        - completion: Optional completion closure
     */
    func removeImage(url: NSURL, completion: PHVoidCompletion? = nil) {
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
    func setCacheSize(memoryCacheSize: UInt, fileCacheSize: UInt) {
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
    func clearFileChache(completion: PHVoidCompletion?) {
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

        backgroundTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler {
            UIApplication.sharedApplication().endBackgroundTask(backgroundTask)
            backgroundTask = UIBackgroundTaskInvalid
        }

        fileCache.clearExpiredImages {
            UIApplication.sharedApplication().endBackgroundTask(backgroundTask)
            backgroundTask = UIBackgroundTaskInvalid
        }
    }

    private func cacheKey(url: NSURL) -> String {
        return url.absoluteString.ik_MD5()
    }

    private func addObservers() {
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: "clearMemoryCache", name: UIApplicationDidReceiveMemoryWarningNotification, object: nil)
        center.addObserver(self, selector: "cleanExpiredDiskCache", name: UIApplicationWillTerminateNotification, object: nil)
        center.addObserver(self, selector: "backgroundCleanExpiredDiskCache", name: UIApplicationDidEnterBackgroundNotification, object: nil)
    }
    
}
