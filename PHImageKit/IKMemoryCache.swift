//
//  IKMemoryCache.swift
//  PHImageKit
//
//  Created by Vlado on 12/6/15.
//  Copyright © 2015 Product Hunt. All rights reserved.
//

import UIKit

class IKMemoryCache: NSCache, IKCacheProtocol {

    override init() {
        super.init()

        totalCostLimit = 50*1024*1024

        countLimit = 150

        evictsObjectsWithDiscardedContent = true

        name = imageKitDomain + "memoryCache"
    }

    func saveImageObject(object: IKImageObject, key: String, completion: IKVoidCompletion? = nil) {
        if let image = object.image {
            self.setObject(image, forKey: key, cost: image.ik_memoryCost)
        }
    }

    func getImageObject(key: String) -> IKImageObject? {
        guard let image = objectForKey(key) as? UIImage else {
            return nil
        }

        return IKImageObject(image: image)
    }

    func isCached(key: String) -> Bool {
        return objectForKey(key) != nil
    }

    func removeImageObject(key: String, completion: IKVoidCompletion? = nil) {
        removeObjectForKey(key)
    }

    func clear(completion: IKVoidCompletion? = nil) {
        removeAllObjects()
    }
    
}
