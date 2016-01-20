//
//  IKDownloadObject.swift
//  PHImageKit
//
//  Created by Vlado on 12/6/15.
//  Copyright © 2015 Product Hunt. All rights reserved.
//

import UIKit

class IKDownload {

    private var callbacks = [String:IKCallback]()

    private var task : NSURLSessionDataTask
    private var data = NSMutableData()

    init(task: NSURLSessionDataTask) {
        self.task = task
    }

    func addCallback(callback:IKCallback) -> String {
        let key = "\(task.currentRequest?.URL?.absoluteString ?? "Unknown")-\(NSDate().timeIntervalSince1970)";

        callbacks[key] = callback;

        return key;
    }

    func failure(error: NSError) {
        for (_, callback) in callbacks {
            callback.completion(image: nil, error: error)
        }
    }

    func success() {
        let imageObject = IKImageObject(data: data)
        let error : NSError? = imageObject != nil ? nil : NSError.ik_invalidDataError()

        for (_, callback) in callbacks {
            callback.completion(image: imageObject, error: error)

        }
    }

    func progress(newData: NSData, contentLenght: UInt) {
        data.appendData(newData)

        let percent = CGFloat(UInt(data.length)/contentLenght)

        for (_, callback) in callbacks {
            callback.progress(percent: percent)
        }
    }

    func cancel(key: String) -> Bool {
        callbacks.removeValueForKey(key)

        if callbacks.count > 0 {
            return false
        }

        task.cancel()

        return true
    }
}

