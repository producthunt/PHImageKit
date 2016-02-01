//
//  PHAnimatedImage.swift
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
import ImageIO
import MobileCoreServices
import QuartzCore

/// Subclass of UIImage, responsible for playback of GIFs.
public class PHAnimatedImage: UIImage {

    //TODO: (Vlado) Handle memory warnings
    private(set) internal var loopCount = Int.max
    private(set) internal var posterImage: UIImage?
    private(set) internal var delayTimesForIndexes = [Int : NSTimeInterval]()
    private(set) internal var frameCount = 0

    private var frameCacheSize = 10
    private var cachedFramesForIndexes = [Int:UIImage]()
    private var cachedFrameIndexes = NSMutableIndexSet()
    private var requestedFrameIndexes = NSMutableIndexSet()
    private var imageSource: CGImageSourceRef?
    private var posterImageFrameIndex = 0
    private lazy var readFrameQueue = dispatch_queue_create(imageKitDomain + ".gifReadQueue", DISPATCH_QUEUE_SERIAL)

    /**
     Create animated image

     - parameter data: GIF data

     - returns: Newly created instance of `PHAnimatedImage`
     */
    public init(initWithAnimatedGIFData data: NSData) {
        super.init()

        if data.length == 0 {
            return
        }

        guard let imageSource = CGImageSourceCreateWithData(data, nil) else {
            return
        }

        self.imageSource = imageSource

        guard let imageSourceContainerType = CGImageSourceGetType(imageSource) where UTTypeConformsTo(imageSourceContainerType, kUTTypeGIF) else {
            return
        }

        let imageProperties = CGImageSourceCopyProperties(imageSource,nil)! as NSDictionary

        setLoopCount(imageProperties)

        frameCount = CGImageSourceGetCount(imageSource)

        for i in 0..<frameCount {
            setPosterImage(i)
            setDelayTimes(i)
        }

        frameCacheSize = min(frameCount, 10)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    required convenience public init(imageLiteral name: String) {
        fatalError("init(imageLiteral:) has not been implemented")
    }

    /**
     GIF frame at given index

     - parameter index: If index is out of bounds will return nil.

     - returns: Optional UIImage
     */
    public func imageFrame(atIndex index: Int) -> UIImage? {
        if index >= frameCount {
            return nil
        }

        if cachedFramesForIndexes.count < frameCount {
            let indexesToCache = frameIndexesToCache(index)

            indexesToCache.removeIndexes(cachedFrameIndexes)
            indexesToCache.removeIndexes(requestedFrameIndexes)
            indexesToCache.removeIndex(posterImageFrameIndex)

            if indexesToCache.count > 0 {
                addFrameIndexesToCache(indexesToCache, index: index)
            }
        }

        return cachedFramesForIndexes[index]
    }

    private func addFrameIndexesToCache(indexesToCache:NSIndexSet, index:Int) {
        requestedFrameIndexes.addIndexes(indexesToCache)

        dispatch_async(readFrameQueue) { [weak self] () -> Void in
            indexesToCache.enumerateRangesWithOptions(NSEnumerationOptions.Concurrent) { (range, stop) in
                for var i = range.location; i < NSMaxRange(range); i++ {
                    self?.cachedFramesForIndexes[i] = self?.predrawnImageAtIndex(i)
                    self?.cachedFrameIndexes.addIndex(i)
                    self?.requestedFrameIndexes.removeIndex(i)
                }
            }

            self?.purgeFrameCacheIfNeeded(index)
        }
    }

    private func predrawnImageAtIndex(index:Int) -> UIImage {
        let imageRef = CGImageSourceCreateImageAtIndex(imageSource!, index, nil)
        return UIImage(CGImage: imageRef!).ik_decompress()
    }

    private func frameIndexesToCache(index:Int) -> NSMutableIndexSet {
        if frameCacheSize == frameCount {
            return NSMutableIndexSet(indexesInRange: NSMakeRange(0, frameCount))
        }

        let firstLength = min(frameCacheSize, frameCount - index)

        let indexesToCacheMutable = NSMutableIndexSet()

        indexesToCacheMutable.addIndexesInRange(NSMakeRange(index, firstLength))

        let secondLength = frameCacheSize - firstLength
        if (secondLength > 0) {
            indexesToCacheMutable.addIndexesInRange(NSMakeRange(0, secondLength))
        }

        return indexesToCacheMutable;
    }

    private func purgeFrameCacheIfNeeded (index:Int) {
        if cachedFrameIndexes.count > frameCacheSize {
            let indexesToPurge = cachedFrameIndexes.mutableCopy()

            indexesToPurge.removeIndexes(frameIndexesToCache(index))
            indexesToPurge.removeIndex(posterImageFrameIndex)

            indexesToPurge.enumerateRangesUsingBlock { (range, stop) in
                for var i = range.location; i < NSMaxRange(range); i++ {
                    self.cachedFrameIndexes.removeIndex(i)
                    self.cachedFramesForIndexes.removeValueForKey(i)
                }
            }
        }
    }

    private func setPosterImage(index : Int) {
        if posterImage != nil {
            return
        }

        guard let imageSource = imageSource, let frameImageRef = CGImageSourceCreateImageAtIndex(imageSource, index, nil) else {
            return
        }

        posterImage = UIImage(CGImage: frameImageRef)
        posterImageFrameIndex = index
        cachedFramesForIndexes[posterImageFrameIndex] = posterImage
        cachedFrameIndexes.addIndex(posterImageFrameIndex)
    }

    private func setLoopCount(properties: NSDictionary) {
        if let properties = properties.objectForKey(kCGImagePropertyGIFDictionary) as? NSDictionary, let count =  properties.objectForKey(kCGImagePropertyGIFLoopCount) as? Int {
            loopCount = count
        }

        if loopCount == 0 {
            loopCount = Int.max
        }
    }

    private func setDelayTimes(index : Int) {
        let properties = CGImageSourceCopyPropertiesAtIndex(self.imageSource!, index , nil)! as NSDictionary
        let framePropertiesGIF = properties.objectForKey(kCGImagePropertyGIFDictionary)

        let minumumDelay : NSTimeInterval = 0.1
        var delayTime : NSTimeInterval = 0

        if let time = framePropertiesGIF?.objectForKey(kCGImagePropertyGIFUnclampedDelayTime) as! Double? {
            delayTime = time
        } else if let time = framePropertiesGIF?.objectForKey(kCGImagePropertyGIFDelayTime) as! Double? {
            delayTime = time
        } else {
            delayTime = index == 0 ? minumumDelay : delayTimesForIndexes[index - 1]!
        }

        if Float(delayTime) < Float(0.02) - FLT_EPSILON {
            delayTime = minumumDelay
        }

        delayTimesForIndexes[index] = delayTime
    }

}