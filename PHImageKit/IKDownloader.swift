//
//  IKDownloader.swift
//  PHImageKit
//
//  Created by Vlado on 12/6/15.
//  Copyright © 2015 Product Hunt. All rights reserved.
//

import UIKit

typealias IKCompletion  = (image: IKImageObject?, error: NSError?) -> Void
typealias IKCallback    = (progress: IKProgressCompletion , completion: IKCompletion)

class IKDownloader : NSObject {

    private var fetchObjects = [NSURL : IKDownload]()
    private let timeout : NSTimeInterval = 15
    private let barrierQueue: dispatch_queue_t = dispatch_queue_create(imageKitDomain + ".barrierQueue", DISPATCH_QUEUE_CONCURRENT)
    private let processQueue: dispatch_queue_t = dispatch_queue_create(imageKitDomain + ".processQueue", DISPATCH_QUEUE_CONCURRENT)

    func download(URL: NSURL, progress: IKProgressCompletion, completion: IKCompletion) -> String? {
        if !URL.ik_isValid() {
            completion(image: nil, error: NSError.ik_invalidUrlError())
            return nil
        }

        var key:String?

        barrierDispatch {
            let fetchObject = self.fetchObjects[URL] ?? IKDownload(task: self.createTask(URL))

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

    private func fetchObjectForKey(key: NSURL) -> IKDownload? {
        var object : IKDownload?

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

extension IKDownloader : NSURLSessionDataDelegate {

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
