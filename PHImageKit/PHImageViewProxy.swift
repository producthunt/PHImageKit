//
//  PHImageViewProxy.swift
//  PHImageKit
//
//  Created by Vlado on 12/6/15.
//  Copyright © 2015 Product Hunt. All rights reserved.
//

import Foundation

class PHImageViewProxy {

    weak var target: AnyObject

    /**
     Proxy object

     - parameter targetObject:

     - returns: Newly created proxy object
     */
    init(weakProxyForObject targetObject: AnyObject) {
        self.target = targetObject
    }

    @objc func forwardingTargetForSelector(selector: Selector) -> AnyObject {
        return target
    }

}
