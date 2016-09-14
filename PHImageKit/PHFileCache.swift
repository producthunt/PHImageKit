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

    fileprivate let ioQueue: DispatchQueue = DispatchQueue(label: imageKitDomain  + ".ioQueue")
    fileprivate var fileManager = FileManager()
    fileprivate var directory : String!
    fileprivate var maxDiskCacheSize : UInt = 0

    override init() {
        super.init()

        directory = (NSSearchPathForDirectoriesInDomains(.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first! as NSString).appendingPathComponent(imageKitDomain)

        createDirectoryIfNeeded()

        setCacheSize(200)
    }

    func saveImageObject(_ object: PHImageObject, key: String, completion: PHVoidCompletion? = nil) {
        ioDispatch {
            if let data = object.data {
                self.fileManager.createFile(atPath: self.pathFromKey(key), contents: data as Data, attributes: nil)
            }

            if let completion = completion {
                completion()
            }
        }
    }

    func getImageObject(_ key: String, completion: @escaping PHManagerCompletion) {
        ioDispatch {
            let data = Data(contentsOf: URL(string: self.pathFromKey(key))!)
            completion(object: PHImageObject(data: data))
        }
    }

    func isCached(_ key: String) -> Bool {
        return fileManager.fileExists(atPath: pathFromKey(key))
    }

    func removeImageObject(_ key: String, completion: PHVoidCompletion?) {
        ioDispatch {
            do {
                try self.fileManager.removeItem(atPath: self.pathFromKey(key))
            } catch _ {}

            self.callCompletion(completion)
        }
    }

    func clear(_ completion: PHVoidCompletion? = nil) {
        ioDispatch { () -> Void in
            do {
                try self.fileManager.removeItem(atPath: self.directory)
            } catch _ {}

            self.createDirectoryIfNeeded()

            self.callCompletion(completion)
        }
    }

    func clearExpiredImages(_ completion: PHVoidCompletion? = nil) {
        ioDispatch {
            let targetSize: UInt = self.maxDiskCacheSize/2
            var totalSize: UInt = 0

            for object in self.getCacheObjects() {
                if object.modificationDate.ik_isExpired() || totalSize > targetSize {
                    do {
                        try self.fileManager.removeItem(at: object.url)
                    } catch _ {}
                } else {
                    totalSize += object.size
                }
            }

            self.callCompletion(completion)
        }
    }

    func setCacheSize(_ size: UInt) {
        maxDiskCacheSize = max(50, min(size, 500)) * 1024 * 1024
    }

    func cacheSize() -> UInt {
        var totalSize: UInt = 0

        getFiles().forEach {
            totalSize += self.getResourceValue($0, key: URLResourceKey.totalFileAllocatedSizeKey.rawValue, defaultValue: NSNumber()).uintValue
        }

        return totalSize
    }

    fileprivate func ioDispatch(_ operation : @escaping (() -> Void)) {
        ioQueue.async(execute: operation)
    }

    fileprivate func callCompletion(_ completion: PHVoidCompletion? = nil) {
        if let completion = completion {
            completion()
        }
    }

    fileprivate func pathFromKey(_ key : String) -> String {
        return (directory as NSString).appendingPathComponent(key)
    }

    fileprivate func createDirectoryIfNeeded() {
        ioDispatch {
            if !self.fileManager.fileExists(atPath: self.directory) {
                try! self.fileManager.createDirectory(atPath: self.directory, withIntermediateDirectories: true, attributes: nil)
            }
        }
    }

    fileprivate func getFiles() -> [URL] {
        let directoryUrl = URL(fileURLWithPath: self.directory)
        let resourceKeys = [URLResourceKey.isDirectoryKey, URLResourceKey.contentModificationDateKey, URLResourceKey.totalFileAllocatedSizeKey]

        let fileEnumerator = self.fileManager.enumerator(at: directoryUrl, includingPropertiesForKeys: resourceKeys, options: .skipsHiddenFiles, errorHandler: nil)

        if let fileEnumerator = fileEnumerator, let urls = fileEnumerator.allObjects as? [NSURL] {
            return urls as [URL]
        }

        return []
    }

    fileprivate func getCacheObjects() -> [PHFileCacheObject] {
        return getFiles().map { (url) -> PHFileCacheObject in
            let object = PHFileCacheObject()

            object.url = url
            object.modificationDate = self.getResourceValue(url, key: URLResourceKey.contentModificationDateKey, defaultValue: NSDate())
            object.size = self.getResourceValue(url, key: URLResourceKey.totalFileAllocatedSizeKey.rawValue, defaultValue: NSNumber()).uintValue

            return object
            }.sorted(by: {
                $0.modificationDate.compare($1.modificationDate as Date) == .orderedAscending
            })
    }

    fileprivate func getResourceValue<T:AnyObject>(_ url: URL, key: String, defaultValue: T) -> T {
        var value: AnyObject?
        try! (url as! NSURL).getResourceValue(&value, forKey: URLResourceKey(rawValue: key))

        if let value = value as? T {
            return value
        }
        
        return defaultValue
    }
    
}

class PHFileCacheObject {
    
    var url : URL!
    var size : UInt = 0
    var modificationDate = Date()
    
}
