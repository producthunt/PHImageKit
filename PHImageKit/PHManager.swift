//
//  PHManager.swift
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

let imageKitDomain = "\(Bundle.main.bundleIdentifier!).imageKit"

public typealias PHVoidCompletion = () -> Void
public typealias PHProgressCompletion = (_ percent : CGFloat) -> Void
public typealias PHManagerCompletion = (_ object: PHImageObject?) -> Void

/// PHManager is responsible for downloading images, cancel ongoing reques and handle cache.
open class PHManager: NSObject {

    /// Shared Instance
    open static let sharedInstance = PHManager()

    fileprivate let downloader = PHDownloader()
    fileprivate let cache = PHCache()

    /**
    Get image from given url. If image is in cache will be taken from there.

    - parameter url:        Image URL
    - parameter progress:   Progress closure returns downloaded percent.
    - parameter completion: Completion closure returns `PHImageObject` that holds image or gif.

    - returns: Unique generated download key. It can be used to cancel request.
    */
    open func imageWithUrl(_ url: URL, progress: @escaping PHProgressCompletion, completion: @escaping PHManagerCompletion) -> String? {
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
    open func imageWithUrl(_ url: URL, completion: @escaping ((_ image: UIImage?) -> Void)) {
        let _ = imageWithUrl(url, progress: { (percent) -> Void in }) { (object) -> Void in
            completion(object?.image)
        }
    }

     /**
     Convinience method for downloading image data from given url.

     - parameter url:       Image URL
     - parameter comletion: Completion closure returns raw image data
     */
    open func imageData(_ url: URL, comletion: @escaping ((_ data: NSData) -> Void)) {
        let _ = imageWithUrl(url, progress: { (percent) -> Void in }) { (object) -> Void in
            if let object = object, let data = object.data {
                comletion(data as NSData)
            }
        }
    }

     /**
     Cancel retrieve of ongoing image download request

     - parameter url: Image URL
     - parameter key: Unique key returned from `imageWithUrl:`
     */
    open func cancelImageRetrieve(_ url: URL, key: String) {
        downloader.cancel(url, key: key)
    }

     /**
     Purche memory and file cache.

     - parameter fileCache:  If set to `true` file cache will be removed too.
     - parameter completion: Optional completion closure.
     */
    open func purgeCache(includingFileCache fileCache: Bool, completion: PHVoidCompletion? = nil) {
        cache.clearMemoryCache()

        if fileCache {
            cache.clearFileChache(completion)
        }
    }

    /**
     Purge file cache only

     - parameter completion: Optional completion closure
     */
    open func purgeFileCache(_ completion: PHVoidCompletion? = nil) {
        cache.clearFileChache(completion)
    }

    /**
     Change memory and file cache size
     
     - parameters:
        - memoryCacheSize: Size for memory cache in MB. Minimum 50 mb. maximum 250 mb. Default is 50 mb.
        - fileCacheSize: Size for file cache in MB. Minimum 50 mb. maximum 500 mb. Default is 200 mb.
    */
    open func setCacheSize(_ memoryCacheSize: UInt, fileCacheSize: UInt) {
        cache.setCacheSize(Int(memoryCacheSize), fileCacheSize: Int(fileCacheSize))
    }

    /**
     Get cache size.

     - returns: Size of cache in kb.
     */
    open func getCacheSize() -> UInt {
        return cache.cacheSize()
    }

    fileprivate func imageFromCache(_ url: URL, completion: @escaping PHManagerCompletion) -> Bool {
        if cache.isImageCached(url) {
            cache.getImage(url, completion: completion)
            return true
        }

        return false
    }

    fileprivate func imageFromWeb(_ url: URL,progress: @escaping PHProgressCompletion , completion: @escaping PHManagerCompletion) -> String? {
        return downloader.download(url, progress: progress) { (imageObject, error) in
            if let object = imageObject {
                self.cache.saveImage(object, url: url)
            }

            completion(imageObject)
        }
    }
}

