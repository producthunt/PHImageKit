//
//  IKCacheProtocol.swift
//  PHImageKit
//
//  Created by Vlado on 12/6/15.
//  Copyright © 2015 Product Hunt. All rights reserved.
//

import UIKit

protocol IKCacheProtocol {

    func saveImageObject(object: IKImageObject, key: String, completion: IKVoidCompletion?)

    func getImageObject(key: String) -> IKImageObject?

    func isCached(key: String) -> Bool

    func removeImageObject(key: String, completion: IKVoidCompletion?)

    func clear(completion: IKVoidCompletion?)
    
}
