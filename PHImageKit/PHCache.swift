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

    func saveImage(imageObject: PHImageObject, url: NSURL) {
        let key = cacheKey(url)

        memoryCache.saveImageObject(imageObject, key: key)
        fileCache.saveImageObject(imageObject, key: key)
    }

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

    func isImageCached(url: NSURL) -> Bool {
        let key = cacheKey(url)
        return memoryCache.isCached(key) || fileCache.isCached(key)
    }

    func removeImage(url: NSURL, completion: PHVoidCompletion? = nil) {
        let key = cacheKey(url)

        memoryCache.removeImageObject(key)

        fileCache.removeImageObject(key, completion: completion)
    }

    func setCacheSize(memoryCacheSize: UInt, fileCacheSize: UInt) {
        memoryCache.setCacheSize(memoryCacheSize)
        fileCache.setCacheSize(fileCacheSize)
    }

    func clearMemoryCache() {
        memoryCache.clear()
    }

    func clearFileChache(completion: PHVoidCompletion?) {
        fileCache.clear(completion)
    }

    func cleanExpiredDiskCache() {
        fileCache.clearExpiredImages()
    }

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
