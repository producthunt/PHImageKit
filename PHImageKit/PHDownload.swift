//
//  PHDownloadObject.swift
//  PHImageKit
//
// Copyright (c) 2016 Product Hunt (http://producthunt.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

class PHDownload {

    fileprivate var callbacks = [String:PHCallback]()

    fileprivate var task : URLSessionDataTask
    fileprivate var data = NSMutableData()

    init(task: URLSessionDataTask) {
        self.task = task
    }

    func addCallback(_ callback:PHCallback) -> String {
        let key = "\(task.currentRequest?.url?.absoluteString ?? "Unknown")-\(Date().timeIntervalSince1970)";

        callbacks[key] = callback;

        return key;
    }

    func failure(_ error: NSError) {
        for (_, callback) in callbacks {
            callback.completion(nil, error)
        }
    }

    func success() {
        let imageObject = PHImageObject(data: data as Data)
        let error : NSError? = imageObject != nil ? nil : NSError.ik_invalidDataError()

        for (_, callback) in callbacks {
            callback.completion(imageObject, error)

        }
    }

    func progress(_ newData: Data, contentLenght: UInt) {
        data.append(newData as Data)

        let percent = CGFloat(UInt(data.length)/contentLenght)

        for (_, callback) in callbacks {
            callback.progress(percent)
        }
    }

    func cancel(_ key: String) -> Bool {
        callbacks.removeValue(forKey: key)

        if callbacks.count > 0 {
            return false
        }

        task.cancel()

        return true
    }
}

