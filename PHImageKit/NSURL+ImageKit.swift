//
//  NSURL+ImageKit.swift
//  PHImageKit
//
//  Created by Vlado on 12/6/15.
//  Copyright © 2015 Product Hunt. All rights reserved.
//

import Foundation

extension NSURL {

    func ik_isValid() -> Bool {
        let urlRegEx = "(https|http)://.*"
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[urlRegEx])

        return predicate.evaluateWithObject(absoluteString)
    }

    func ik_cacheKey() -> String {
        return absoluteString.ik_MD5()
    }

}
