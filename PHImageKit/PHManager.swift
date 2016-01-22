//
//  PHManager.swift
//  PHImageKit
//
//  Created by Vlado on 12/6/15.
//  Copyright © 2015 Product Hunt. All rights reserved.
//

import UIKit

let imageKitDomain = "\(NSBundle.mainBundle().bundleIdentifier!).imageKit"

typealias PHVoidCompletion = () -> Void
typealias PHProgressCompletion = (percent : CGFloat) -> Void
typealias PHManagerCompletion = (object: PHImageObject?) -> Void

class PHManager: NSObject {

    /// Shared Instance
    static let sharedInstance = PHManager()

    private let downloader = PHDownloader()
    private let cache = PHCache()

    //TODO: (Vlado) Handle local url cases.

    /**
    Get image from given url. If image is in cache will be taken from there.

    - parameter url:        Image URL
    - parameter progress:   Progress closure returns downloaded percent.
    - parameter completion: Completion closure returns `PHImageObject` that holds image or gif.

    - returns: Unique generated download key. It can be used to cancel request.
    */
    func imageWithUrl(url: NSURL, progress: PHProgressCompletion, completion: PHManagerCompletion) -> String? {
        if imageFromCache(url, completion: completion) {
            return nil;
        }

        return imageFromWeb(url, progress: progress, completion: completion)
    }

    /**
     Get image from given url
     
     - parameters:
        - url: Image URL
        - completion: Completion closure returns image
     */
    func imageWithUrl(url: NSURL, completion: ((image: UIImage?) -> Void)) {
        imageWithUrl(url, progress: { (percent) -> Void in }) { (object) -> Void in
            completion(image: object?.image)
        }
    }

    /**
     Get image data from given url

     - parameters:
        - url: Image URL
        - completion: Completion closure returns raw image data
    */
    func imageData(url: NSURL, comletion: ((data: NSData) -> Void)) {
        imageWithUrl(url, progress: { (percent) -> Void in }) { (object) -> Void in
            if let object = object, data = object.data {
                comletion(data: data)
            }
        }
    }

    /**
    Cancel retrieve of ongoing image download request
     
    - parameters:
        - url: Image URL
        - key: Unique key returned from `imageWithUrl:`

    */
    func cancelImageRetrieve(url: NSURL, key: String) {
        downloader.cancel(url, key: key)
    }

    /**
     Purge memory and file cache
     
     - parameters: 
        - includingFileCache: If `true` file cache will be purged.
    */


     /**
     Purche memory and file cache.

     - parameter fileCache:  If set to `true` file cache will be removed too.
     - parameter completion: Optional completion closure.
     */
    func purgeCache(includingFileCache fileCache: Bool, completion: PHVoidCompletion? = nil) {
        cache.clearMemoryCache()

        if fileCache {
            cache.clearFileChache(completion)
        }
    }

    /**
     Change memory and file cache size
     
     - parameters:
        - memoryCacheSize: Size for memory cache in MB. Minimum 50 mb. maximum 250 mb. Default is 50 mb.
        - fileCacheSize: Size for file cache in MB. Minimum 50 mb. maximum 500 mb. Default is 200 mb.
    */
    func setCacheSize(memoryCacheSize: UInt, fileCacheSize: UInt) {
        cache.setCacheSize(memoryCacheSize, fileCacheSize: fileCacheSize)
    }

    private func imageFromCache(url: NSURL, completion: PHManagerCompletion) -> Bool {
        if cache.isImageCached(url) {
            cache.getImage(url, completion: completion)
            return true
        }

        return false
    }

    private func imageFromWeb(url: NSURL,progress: PHProgressCompletion , completion: PHManagerCompletion) -> String? {
        return downloader.download(url, progress: progress) { (imageObject, error) in
            if let object = imageObject {
                self.cache.saveImage(object, url: url)
            }

            completion(object: imageObject)
        }
    }
}

