//
//  NSDate+ImageKit.swift
//  PHImageKit
//
//  Created by Vlado on 12/6/15.
//  Copyright © 2015 Product Hunt. All rights reserved.
//

import Foundation

extension NSDate {

    func ik_isExpired() -> Bool {
        return self.compare(NSDate(timeIntervalSinceNow: -60 * 60 * 24 * 7)) == .OrderedAscending
    }

}

