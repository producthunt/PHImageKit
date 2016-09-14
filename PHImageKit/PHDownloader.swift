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

typealias PHCompletion  = (_ image: PHImageObject?, _ error: NSError?) -> Void
typealias PHCallback    = (progress: PHProgressCompletion , completion: PHCompletion)

class PHDownloader : NSObject {

    fileprivate var fetchObjects = [URL : PHDownload]()
    fileprivate let timeout : TimeInterval = 15
    fileprivate let barrierQueue: DispatchQueue = DispatchQueue(label: imageKitDomain + ".barrierQueue", attributes: .concurrent)
    fileprivate let processQueue: DispatchQueue = DispatchQueue(label: imageKitDomain + ".processQueue", attributes: .concurrent)

    func download(_ URL: Foundation.URL, progress: @escaping PHProgressCompletion, completion: @escaping PHCompletion) -> String? {
        if !URL.ik_isValid() {
            completion(nil, NSError.ik_invalidUrlError())
            return nil
        }

        var key:String?

        barrierDispatch {
            let fetchObject = self.fetchObjects[URL] ?? PHDownload(task: self.createTask(URL as NSURL))

            key = fetchObject.addCallback((progress: progress, completion: completion))

            self.fetchObjects[URL] = fetchObject
        }

        return key
    }

    func cancel(_ url: URL, key: String) {
        if let object = fetchObjectForKey(url) {
            if (object.cancel(key)) {
                removeFetchObject(url)
            }
        }
    }

    fileprivate func createTask(_ url: NSURL) -> URLSessionDataTask {
        let request = NSMutableURLRequest(url: url as URL, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: self.timeout)
        request.httpShouldUsePipelining = true

        let session = Foundation.URLSession(configuration: URLSessionConfiguration.ephemeral, delegate: self, delegateQueue:OperationQueue.main)

        let task = session.dataTask(with: request as URLRequest)
        task.priority = URLSessionTask.defaultPriority
        task.resume()

        return task
    }

    fileprivate func fetchObjectForKey(_ key: URL) -> PHDownload? {
        var object : PHDownload?

        barrierDispatch {
            object = self.fetchObjects[key]
        }

        return object
    }

    fileprivate func removeFetchObject(_ URL: Foundation.URL) {
        barrierDispatch {
            self.fetchObjects.removeValue(forKey: URL)
        }
    }

    fileprivate func barrierDispatch(_ closure: (() -> Void)) {
        (barrierQueue).sync(flags: .barrier, execute: closure)
    }

    fileprivate func processDispatch(_ closure: @escaping (() -> Void)) {
        (processQueue).async(execute: closure)
    }
}

extension PHDownloader : URLSessionDataDelegate {

    func urlSession(_ session: Foundation.URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if let URL = dataTask.originalRequest?.url, let fetchObject = fetchObjectForKey(URL) {
            fetchObject.progress(data, contentLenght: UInt(max(dataTask.response!.expectedContentLength, 1)))
        }
    }


    func urlSession(_ session: Foundation.URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let url = (task.originalRequest?.url)!

        guard let fetchObject = self.fetchObjectForKey(url) else {
            return
        }

        if error?._code == NSURLErrorCancelled {
            return
        }

        self.removeFetchObject(url)


        if let error = error {
            fetchObject.failure(error as NSError);
        } else {
            processDispatch {
                fetchObject.success();
            }
        }
    }

    fileprivate func URLSession(_ session: Foundation.URLSession, dataTask: URLSessionDataTask, didReceiveResponse response: URLResponse, completionHandler: (Foundation.URLSession.ResponseDisposition) -> Void) {
        completionHandler(Foundation.URLSession.ResponseDisposition.allow)
    }

    fileprivate func URLSession(_ session: Foundation.URLSession, didReceiveChallenge challenge: URLAuthenticationChallenge, completionHandler: (Foundation.URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.performDefaultHandling, nil)
    }
    
}
