//
//  IKFileCache.swift
//  PHImageKit
//
//  Created by Vlado on 12/6/15.
//  Copyright © 2015 Product Hunt. All rights reserved.
//

import UIKit

class IKFileCache: NSObject, IKCacheProtocol {

    private let ioQueue = dispatch_queue_create(imageKitDomain  + "ioQueue", DISPATCH_QUEUE_SERIAL)
    private var fileManager = NSFileManager()
    private var directory : String!
    private var maxDiskCacheSize : UInt = 200 * 1024 * 1024

    override init() {
        super.init()

        directory = (NSSearchPathForDirectoriesInDomains(.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).first! as NSString).stringByAppendingPathComponent(imageKitDomain)

        createDirectoryIfNeeded()
    }

    func saveImageObject(object: IKImageObject, key: String, completion: IKVoidCompletion? = nil) {
        ioDispatch {
            if let data = object.data {
                self.fileManager.createFileAtPath(self.pathFromKey(key), contents: data, attributes: nil)
            }

            if let completion = completion {
                completion()
            }
        }
    }

    func getImageObject(key: String) -> IKImageObject? {
        guard let data = NSData(contentsOfFile: pathFromKey(key)) else {
            return nil
        }

        return IKImageObject(data: data)
    }

    func isCached(key: String) -> Bool {
        return fileManager.fileExistsAtPath(pathFromKey(key))
    }

    func removeImageObject(key: String, completion: IKVoidCompletion?) {
        ioDispatch {
            do {
                try self.fileManager.removeItemAtPath(self.pathFromKey(key))
            } catch _ {}

            self.callCompletion(completion)
        }
    }

    func clear(completion: IKVoidCompletion? = nil) {
        ioDispatch { () -> Void in
            do {
                try self.fileManager.removeItemAtPath(self.directory)
            } catch _ {}

            self.createDirectoryIfNeeded()

            self.callCompletion(completion)
        }
    }

    func clearExpiredImages(completion: IKVoidCompletion? = nil) {
        ioDispatch {
            let targetSize: UInt = self.maxDiskCacheSize/2
            var totalSize: UInt = 0

            for object in self.getCacheObjects() {
                if object.modificationDate.ik_isExpired() || totalSize > targetSize {
                    do {
                        try self.fileManager.removeItemAtURL(object.url)
                    } catch _ {}
                } else {
                    totalSize += object.size
                }
            }

            self.callCompletion(completion)
        }
    }

    private func ioDispatch(operation : (() -> Void)) {
        dispatch_async(ioQueue, operation)
    }

    private func callCompletion(completion: IKVoidCompletion? = nil) {
        if let completion = completion {
            completion()
        }
    }

    private func pathFromKey(key : String) -> String {
        return (directory as NSString).stringByAppendingPathComponent(key)
    }

    private func createDirectoryIfNeeded() {
        ioDispatch {
            if !self.fileManager.fileExistsAtPath(self.directory) {
                try! self.fileManager.createDirectoryAtPath(self.directory, withIntermediateDirectories: true, attributes: nil)
            }
        }
    }

    private func getFiles() -> [NSURL] {
        let directoryUrl = NSURL(fileURLWithPath: self.directory)
        let resourceKeys = [NSURLIsDirectoryKey, NSURLContentModificationDateKey, NSURLTotalFileAllocatedSizeKey]

        let fileEnumerator = self.fileManager.enumeratorAtURL(directoryUrl, includingPropertiesForKeys: resourceKeys, options: .SkipsHiddenFiles, errorHandler: nil)

        if let fileEnumerator = fileEnumerator, urls = fileEnumerator.allObjects as? [NSURL] {
            return urls
        }

        return []
    }

    private func getCacheObjects() -> [IKFileCacheObject] {
        return getFiles().map { (url) -> IKFileCacheObject in
            let object = IKFileCacheObject()

            object.url = url
            object.modificationDate = self.getResourceValue(url, key: NSURLContentModificationDateKey, defaultValue: NSDate())
            object.size = self.getResourceValue(url, key: NSURLTotalFileAllocatedSizeKey, defaultValue: NSNumber()).unsignedLongValue

            return object
            }.sort({
                $0.modificationDate.compare($1.modificationDate) == .OrderedAscending
            })
    }

    private func getResourceValue<T:AnyObject>(url: NSURL, key: String, defaultValue: T) -> T {
        var value: AnyObject?
        try! url.getResourceValue(&value, forKey: key)

        if let value = value as? T {
            return value
        }
        
        return defaultValue
    }

}

class IKFileCacheObject {
    
    var url : NSURL!
    var size : UInt = 0
    var modificationDate = NSDate()
    
}