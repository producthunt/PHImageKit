//
//  PHFileCache.swift
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

class PHFileCache: NSObject, PHCacheProtocol {

    private let ioQueue = dispatch_queue_create(imageKitDomain  + ".ioQueue", DISPATCH_QUEUE_SERIAL)
    private var fileManager = NSFileManager()
    private var directory : String!
    private var maxDiskCacheSize : UInt = 0

    override init() {
        super.init()

        directory = (NSSearchPathForDirectoriesInDomains(.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).first! as NSString).stringByAppendingPathComponent(imageKitDomain)

        createDirectoryIfNeeded()

        setCacheSize(200)
    }

    func saveImageObject(object: PHImageObject, key: String, completion: PHVoidCompletion? = nil) {
        ioDispatch {
            if let data = object.data {
                self.fileManager.createFileAtPath(self.pathFromKey(key), contents: data, attributes: nil)
            }

            if let completion = completion {
                completion()
            }
        }
    }

    func getImageObject(key: String, completion: PHManagerCompletion) {
        ioDispatch {
            let data = NSData(contentsOfFile: self.pathFromKey(key))
            completion(object: PHImageObject(data: data))
        }
    }

    func isCached(key: String) -> Bool {
        return fileManager.fileExistsAtPath(pathFromKey(key))
    }

    func removeImageObject(key: String, completion: PHVoidCompletion?) {
        ioDispatch {
            do {
                try self.fileManager.removeItemAtPath(self.pathFromKey(key))
            } catch _ {}

            self.callCompletion(completion)
        }
    }

    func clear(completion: PHVoidCompletion? = nil) {
        ioDispatch { () -> Void in
            do {
                try self.fileManager.removeItemAtPath(self.directory)
            } catch _ {}

            self.createDirectoryIfNeeded()

            self.callCompletion(completion)
        }
    }

    func clearExpiredImages(completion: PHVoidCompletion? = nil) {
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

    func setCacheSize(size: UInt) {
        maxDiskCacheSize = max(50, min(size, 500)) * 1024 * 1024
    }

    private func ioDispatch(operation : (() -> Void)) {
        dispatch_async(ioQueue, operation)
    }

    private func callCompletion(completion: PHVoidCompletion? = nil) {
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

    private func getCacheObjects() -> [PHFileCacheObject] {
        return getFiles().map { (url) -> PHFileCacheObject in
            let object = PHFileCacheObject()

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

class PHFileCacheObject {
    
    var url : NSURL!
    var size : UInt = 0
    var modificationDate = NSDate()
    
}