//
//  PHManager.swift
//  PHImageKit
//
//  Created by Vlado on 12/6/15.
//  Copyright © 2015 Product Hunt. All rights reserved.
//

import UIKit

let imageKitDomain = "\(NSBundle.mainBundle().bundleIdentifier!).imageKit"

public typealias PHVoidCompletion = () -> Void
public typealias PHProgressCompletion = (percent : CGFloat) -> Void
public typealias PHManagerCompletion = (object: PHImageObject?) -> Void

/// PHManager is responsible for downloading images, cancel ongoing reques and handle cache.
public class PHManager: NSObject {

    /// Shared Instance
    public static let sharedInstance = PHManager()

    private let downloader = PHDownloader()
    private let cache = PHCache()

    /**
    Get image from given url. If image is in cache will be taken from there.

    - parameter url:        Image URL
    - parameter progress:   Progress closure returns downloaded percent.
    - parameter completion: Completion closure returns `PHImageObject` that holds image or gif.

    - returns: Unique generated download key. It can be used to cancel request.
    */
    public func imageWithUrl(url: NSURL, progress: PHProgressCompletion, completion: PHManagerCompletion) -> String? {
        if imageFromCache(url, completion: completion) {
            return nil;
        }

        return imageFromWeb(url, progress: progress, completion: completion)
    }

     /**
     Convinience method for downloading image from given url.

     - parameter url:        Image URL
     - parameter completion: Completion closure it returns image
     */
    public func imageWithUrl(url: NSURL, completion: ((image: UIImage?) -> Void)) {
        imageWithUrl(url, progress: { (percent) -> Void in }) { (object) -> Void in
            completion(image: object?.image)
        }
    }

     /**
     Convinience method for downloading image data from given url.

     - parameter url:       Image URL
     - parameter comletion: Completion closure returns raw image data
     */
    public func imageData(url: NSURL, comletion: ((data: NSData) -> Void)) {
        imageWithUrl(url, progress: { (percent) -> Void in }) { (object) -> Void in
            if let object = object, data = object.data {
                comletion(data: data)
            }
        }
    }

     /**
     Cancel retrieve of ongoing image download request

     - parameter url: Image URL
     - parameter key: Unique key returned from `imageWithUrl:`
     */
    public func cancelImageRetrieve(url: NSURL, key: String) {
        downloader.cancel(url, key: key)
    }

     /**
     Purche memory and file cache.

     - parameter fileCache:  If set to `true` file cache will be removed too.
     - parameter completion: Optional completion closure.
     */
    public func purgeCache(includingFileCache fileCache: Bool, completion: PHVoidCompletion? = nil) {
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
    public func setCacheSize(memoryCacheSize: UInt, fileCacheSize: UInt) {
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

