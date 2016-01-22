//
//  PHCacheProtocol.swift
//  PHImageKit
//
//  Created by Vlado on 12/6/15.
//  Copyright © 2015 Product Hunt. All rights reserved.
//

import UIKit

protocol PHCacheProtocol {

    func saveImageObject(object: PHImageObject, key: String, completion: PHVoidCompletion?)

    func getImageObject(key: String) -> PHImageObject?

    func isCached(key: String) -> Bool

    func removeImageObject(key: String, completion: PHVoidCompletion?)

    func clear(completion: PHVoidCompletion?)

    func setCacheSize(size: UInt)
    
}
