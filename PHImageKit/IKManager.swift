//
//  IKManager.swift
//  PHImageKit
//
//  Created by Vlado on 12/6/15.
//  Copyright © 2015 Product Hunt. All rights reserved.
//

import UIKit

let imageKitDomain = "com.productHunt.imageKit"

typealias IKVoidCompletion = () -> Void
typealias IKProgressCompletion = (percent : CGFloat) -> Void
typealias IKManagerCompletion = (object: IKImageObject?) -> Void

class IKManager: NSObject {

    static let sharedInstance = IKManager()

    private let downloader = IKDownloader()
    private let cache = IKCache()

    //TODO: (Vlado) Handle local url cases.
    func imageWithUrl(url: NSURL, progress: IKProgressCompletion, completion: IKManagerCompletion) -> String? {
        if imageFromCache(url, completion: completion) {
            return nil;
        }

        return imageFromWeb(url, progress: progress, completion: completion)
    }

    func imageWithUrl(url: NSURL, completion: ((image: UIImage?) -> Void)) {
        imageWithUrl(url, progress: { (percent) -> Void in }) { (object) -> Void in
            completion(image: object?.image)
        }
    }

    func imageData(url: NSURL, comletion: ((data: NSData) -> Void)) {
        imageWithUrl(url, progress: { (percent) -> Void in }) { (object) -> Void in
            if let object = object, data = object.data {
                comletion(data: data)
            }
        }
    }

    func cancelImageRetrieve(url: NSURL, key: String) {
        downloader.cancel(url, key: key)
    }

    func purgeCache(includingFileCache fileCache: Bool, completion: IKVoidCompletion? = nil) {
        cache.clearMemoryCache()

        if fileCache {
            cache.clearFileChache(completion)
        }
    }

    private func imageFromCache(url: NSURL, completion: IKManagerCompletion) -> Bool {
        if cache.isImageCached(url) {
            cache.getImage(url, completion: completion)
            return true
        }

        return false
    }

    private func imageFromWeb(url: NSURL,progress: IKProgressCompletion , completion: IKManagerCompletion) -> String? {
        return downloader.download(url, progress: progress) { (imageObject, error) in
            if let object = imageObject {
                self.cache.saveImage(object, url: url)
            }

            completion(object: imageObject)
        }
    }
}

