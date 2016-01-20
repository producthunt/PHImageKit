//
//  NSError+ImageKit.swift
//  PHImageKit
//
//  Created by Vlado on 12/6/15.
//  Copyright © 2015 Product Hunt. All rights reserved.
//

import Foundation

enum IKErrorCodes : Int {
    case InvalidUrl     = 1
    case InvalidData    = 2
}

extension NSError {

    class func ik_invalidUrlError() -> NSError {
        return NSError(domain: imageKitDomain, code: IKErrorCodes.InvalidUrl.rawValue, userInfo: [NSLocalizedDescriptionKey : "Invalid URL"])
    }

    class func ik_invalidDataError() -> NSError {
        return NSError(domain: imageKitDomain, code: IKErrorCodes.InvalidData.rawValue, userInfo: [NSLocalizedDescriptionKey : "Invalid Data"])
    }
}