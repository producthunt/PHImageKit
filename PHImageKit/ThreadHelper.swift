//
//  ThreadHelper.swift
//  PHImageKit
//
//  Created by Vlado on 12/6/15.
//  Copyright © 2015 Product Hunt. All rights reserved.
//

import Foundation

func ik_dispatch_main_queue(closure: IKVoidCompletion) {
    if NSThread.isMainThread() {
        closure()
    } else {
        dispatch_async(dispatch_get_main_queue()) {
            closure()
        }
    }
}
