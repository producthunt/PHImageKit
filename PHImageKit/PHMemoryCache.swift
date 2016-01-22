//
//  PHMemoryCache.swift
//  PHImageKit
//
//  Created by Vlado on 12/6/15.
//  Copyright © 2015 Product Hunt. All rights reserved.
//

import UIKit

class PHMemoryCache: NSCache, PHCacheProtocol {

    override init() {
        super.init()

        setCacheSize(50)

        countLimit = 150

        evictsObjectsWithDiscardedContent = true

        name = imageKitDomain + "memoryCache"
    }

    func saveImageObject(object: PHImageObject, key: String, completion: PHVoidCompletion? = nil) {
        if let image = object.image {
            self.setObject(image, forKey: key, cost: image.ik_memoryCost)
        }
    }

    func getImageObject(key: String) -> PHImageObject? {
        guard let image = objectForKey(key) as? UIImage else {
            return nil
        }

        return PHImageObject(image: image)
    }

    func isCached(key: String) -> Bool {
        return objectForKey(key) != nil
    }

    func removeImageObject(key: String, completion: PHVoidCompletion? = nil) {
        removeObjectForKey(key)
    }

    func clear(completion: PHVoidCompletion? = nil) {
        removeAllObjects()
    }

    func setCacheSize(size: UInt) {
        totalCostLimit = max(50, min(Int(size), 250)) * 1024 * 1024
    }
    
}
