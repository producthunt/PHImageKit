//
//  PHDownloader.swift
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

typealias PHCompletion  = (image: PHImageObject?, error: NSError?) -> Void
typealias PHCallback    = (progress: PHProgressCompletion , completion: PHCompletion)

class PHDownloader : NSObject {

    private var fetchObjects = [NSURL : PHDownload]()
    private let timeout : NSTimeInterval = 15
    private let barrierQueue: dispatch_queue_t = dispatch_queue_create(imageKitDomain + ".barrierQueue", DISPATCH_QUEUE_CONCURRENT)
    private let processQueue: dispatch_queue_t = dispatch_queue_create(imageKitDomain + ".processQueue", DISPATCH_QUEUE_CONCURRENT)

    func download(URL: NSURL, progress: PHProgressCompletion, completion: PHCompletion) -> String? {
        if !URL.ik_isValid() {
            completion(image: nil, error: NSError.ik_invalidUrlError())
            return nil
        }

        var key:String?

        barrierDispatch {
            let fetchObject = self.fetchObjects[URL] ?? PHDownload(task: self.createTask(URL))

            key = fetchObject.addCallback((progress: progress, completion: completion))

            self.fetchObjects[URL] = fetchObject
        }

        return key
    }

    func cancel(url: NSURL, key: String) {
        if let object = fetchObjectForKey(url) {
            if (object.cancel(key)) {
                removeFetchObject(url)
            }
        }
    }

    private func createTask(url: NSURL) -> NSURLSessionDataTask {
        let request = NSMutableURLRequest(URL: url, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: self.timeout)
        request.HTTPShouldUsePipelining = true

        let session = NSURLSession(configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration(), delegate: self, delegateQueue:NSOperationQueue.mainQueue())

        let task = session.dataTaskWithRequest(request)
        task.priority = NSURLSessionTaskPriorityDefault
        task.resume()

        return task
    }

    private func fetchObjectForKey(key: NSURL) -> PHDownload? {
        var object : PHDownload?

        barrierDispatch {
            object = self.fetchObjects[key]
        }

        return object
    }

    private func removeFetchObject(URL: NSURL) {
        barrierDispatch {
            self.fetchObjects.removeValueForKey(URL)
        }
    }

    private func barrierDispatch(closure: (() -> Void)) {
        dispatch_barrier_sync(barrierQueue, closure)
    }

    private func processDispatch(closure: (() -> Void)) {
        dispatch_async(processQueue, closure)
    }
}

extension PHDownloader : NSURLSessionDataDelegate {

    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        if let URL = dataTask.originalRequest?.URL, fetchObject = fetchObjectForKey(URL) {
            fetchObject.progress(data, contentLenght: UInt(max(dataTask.response!.expectedContentLength, 1)))
        }
    }

    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        let url = (task.originalRequest?.URL)!

        guard let fetchObject = self.fetchObjectForKey(url) else {
            return
        }

        if error?.code == NSURLErrorCancelled {
            return
        }

        self.removeFetchObject(url)


        if let error = error {
            fetchObject.failure(error);
        } else {
            processDispatch {
                fetchObject.success();
            }
        }
    }

    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        completionHandler(NSURLSessionResponseDisposition.Allow)
    }

    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        completionHandler(.PerformDefaultHandling, nil)
    }
    
}
