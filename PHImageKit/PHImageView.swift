//
//  PHImageView.swift
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

/// PHImageView subclass of `UIImageView`. Set `url` and image view will handle everything for you
open class PHImageView: UIImageView {

    /// Images Asset URL - If there is already ongoing request will be cancelled
    open var url : URL? {
        didSet {
            if let oldValue = oldValue {
                if let url = url , url.absoluteString == oldValue.absoluteString {
                    return
                }

                if let downloadKey = downloadKey {
                    PHManager.sharedInstance.cancelImageRetrieve(oldValue, key: downloadKey)
                }
            }

            downloadKey = nil
            animatedImage = nil
            super.image = nil

            if let url = url {
                loadImage(url)
            }
        }
    }

    /// Boolean that indicates should progress view
    open var showProgress = true {
        willSet {
            if let progressView = progressView {
                progressView.removeFromSuperview()
            }
        }
        didSet {
            if showProgress {
                progressView = PHProgressView.progressInSuperview(self)
            }
        }
    }

    /// Should transition of the image should be animated (TransitionCrossDissolve).
    open var animatedImageTransition = true

    /// Animated image
    open var animatedImage: PHAnimatedImage! {
        didSet {
            guard let animatedImage = animatedImage else {
                stopAnimating()
                return
            }

            super.image = nil

            super.isHighlighted = false

            invalidateIntrinsicContentSize()

            loopCountdown = animatedImage.loopCount

            currentFrame = animatedImage.posterImage

            currentFrameIndex = 0

            accumulator = 0

            updateShouldAnimate()

            if shouldAnimate {
                startAnimating()
            }
            
            layer.setNeedsDisplay()
        }
    }

    fileprivate var downloadKey : String?

    fileprivate var progressView : PHProgressView?
    fileprivate var currentFrame: UIImage!
    fileprivate var currentFrameIndex = 0

    fileprivate var loopCountdown = Int.max
    fileprivate var accumulator: TimeInterval = 0
    fileprivate var displayLink: CADisplayLink!

    fileprivate var shouldAnimate = false
    fileprivate var needsDisplayWhenImageBecomesAvailable = false

    //MARK: Life cycle

    required public init?(coder aDecoder: NSCoder)  {
        super.init(coder: aDecoder)
        commonInit()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public override init(image: UIImage?) {
        super.init(image: image)
        commonInit()
    }

    public override init(image: UIImage?, highlightedImage: UIImage!)  {
        super.init(image: image, highlightedImage: highlightedImage)
        commonInit()
    }

    open override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }

    open func commonInit() {
        showProgress = true

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(PHImageView.stopAnimating), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        notificationCenter.addObserver(self, selector: #selector(PHImageView.startAnimating), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }

    deinit {
        if let displayLink = displayLink {
            displayLink.invalidate()
        }

        NotificationCenter.default.removeObserver(self)
    }

    //MARK: Override

    open override func didMoveToSuperview() {
        super.didMoveToSuperview()

        self.updateShouldAnimate()
        if self.shouldAnimate {
            self.startAnimating()
        } else {
            self.stopAnimating()
        }
    }

    open override func didMoveToWindow() {
        super.didMoveToWindow()

        self.updateShouldAnimate()
        if self.shouldAnimate {
            self.startAnimating()
        } else {
            self.stopAnimating()
        }
    }

    open override var intrinsicContentSize : CGSize {
        guard let image = animatedImage, let poster = image.posterImage else {
            return super.intrinsicContentSize
        }

        return poster.size
    }

    open override var image:UIImage? {
        get {
            return self.currentFrame ?? super.image
        } set {
            if image != nil {
                self.animatedImage = nil
            }

            super.image = image
        }
    }

    open override func startAnimating() {
        guard let _ = animatedImage else {
            super.startAnimating()
            return
        }

        if displayLink == nil {
            let weakProxy : PHImageViewProxy = PHImageViewProxy(weakProxyForObject: self)
            displayLink = CADisplayLink(target: weakProxy, selector: #selector(PHImageView.displayDidRefresh(_:)))

            let mode : String = {
                var modeToReturn =  RunLoopMode.defaultRunLoopMode

                if ProcessInfo.processInfo.activeProcessorCount > 1 {
                    modeToReturn = RunLoopMode.commonModes
                }

                return modeToReturn.rawValue
            }()

            displayLink.add(to: RunLoop.main, forMode: RunLoopMode(rawValue: mode))
        }

        displayLink.isPaused = false
    }

    open override func stopAnimating() {
        if self.animatedImage != nil &&  displayLink != nil {
            self.displayLink.isPaused = true
        } else {
            super.stopAnimating()
        }
    }

    open override var isAnimating : Bool {
        var isAnimating = false

        if self.animatedImage != nil {
            isAnimating = self.displayLink != nil && !self.displayLink.isPaused ? true : false
        }

        return isAnimating
    }

    open override var isHighlighted: Bool {
        set {
            if self.animatedImage != nil {
                super.isHighlighted = false
            }
        }
        get {
            return super.isHighlighted
        }
 
    }

    open override func display(_ layer: CALayer) {
        layer.contents = image?.cgImage
    }

    //MARK: Private

    fileprivate func loadImage(_ url: URL) {
        downloadKey = PHManager.sharedInstance.imageWithUrl(url, progress: { [weak self] (percent) in

            self?.setProgress(percent)

            }) { [weak self] (imageObject) -> Void in

                if let imageObject = imageObject {
                    self?.setImage(imageObject)
                }
        }
    }

    fileprivate func setProgress(_ percent: CGFloat) {
        ik_dispatch_main_queue({ () -> Void in
            if let progressView = self.progressView {
                progressView.setProgress(percent)
            }
        })
    }

    fileprivate func setImage(_ object: PHImageObject) {
        ik_dispatch_main_queue {
            if !self.animatedImageTransition {
                self.willChangeValue(forKey: "image")
                super.image = object.image
                self.animatedImage = object.gif
                self.didChangeValue(forKey: "image")

                return
            }

            UIView.transition(with: self, duration: 0.15, options: .transitionCrossDissolve, animations: {
                self.willChangeValue(forKey: "image")
                super.image = object.image
                self.animatedImage = object.gif
                self.didChangeValue(forKey: "image")

                }, completion: nil)
        }
    }

    fileprivate func updateShouldAnimate() {
        self.shouldAnimate = self.animatedImage != nil && self.window != nil && self.superview != nil ? true : false
    }

    //MARK: Animation related

    func displayDidRefresh(_ displayLink:CADisplayLink) {
        if shouldAnimate == false {
            return
        }

        guard let animatedImage = animatedImage else {
            return
        }

        if let delayTimeNumber = animatedImage.delayTimesForIndexes[currentFrameIndex] {
            animatedFrameForCurrentIndex()

            accumulator = accumulator + Double(displayLink.duration)

            let delayTime =  TimeInterval(delayTimeNumber)
            while accumulator >= delayTime {
                accumulator = accumulator - delayTime
                currentFrameIndex += 1
                if currentFrameIndex >= animatedImage.frameCount {
                    loopCountdown = loopCountdown - 1

                    if loopCountdown == 0 {
                        stopAnimating()
                        return
                    }

                    currentFrameIndex = 0
                }

                needsDisplayWhenImageBecomesAvailable = true
            }
        } else {
            currentFrameIndex += 1
        }
    }

    fileprivate func animatedFrameForCurrentIndex() {
        currentFrame = animatedImage.imageFrame(atIndex: currentFrameIndex)

        if image != nil && needsDisplayWhenImageBecomesAvailable  {
            layer.setNeedsDisplay()
            needsDisplayWhenImageBecomesAvailable = false
        }
    }

}
