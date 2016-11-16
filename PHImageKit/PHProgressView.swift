//
//  PHProgressView.swift
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

class PHProgressView: UIView {

    var lineWidth : CGFloat = 5
    var arkColor = UIColor.black
    var radius : CGFloat = 30 {
        didSet {
            setNeedsDisplay()
        }
    }

    fileprivate let backgroundLayer = CALayer()
    fileprivate let progressLayer = CAShapeLayer()
    fileprivate let backgroundView = UIView()

    class func progressInSuperview(_ superview: UIView) -> PHProgressView {
        let progressView = PHProgressView()

        superview.addSubview(progressView)
        progressView.ik_setConstraintsToSuperview()
        progressView.setProgress(0)

        return progressView
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    fileprivate func commonInit() {
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = arkColor.cgColor
        progressLayer.lineWidth = lineWidth
        progressLayer.strokeStart = 0.0
        progressLayer.strokeEnd = 0.0

        backgroundView.frame = self.bounds;
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView.layer.addSublayer(backgroundLayer)

        addSubview(backgroundView)

        backgroundLayer.addSublayer(progressLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        backgroundLayer.frame = bounds

        let path = UIBezierPath()
        path.lineCapStyle = CGLineCap.butt
        path.lineWidth = lineWidth

        path.addArc(withCenter: backgroundView.center, radius: radius + lineWidth / 2, startAngle: CGFloat(-M_PI_2), endAngle: CGFloat(M_PI + M_PI_2), clockwise: true)
        progressLayer.path = path.cgPath
    }

    func setProgress(_ progress: CGFloat) {
        let normalizedProgress = max(0, min(progress, 1))

        backgroundView.isHidden = !(normalizedProgress > 0) || normalizedProgress > CGFloat.greatestFiniteMagnitude
        progressLayer.strokeEnd = normalizedProgress

        if normalizedProgress == 1 {
            hide()
        }
    }

    func hide() {
        backgroundView.alpha = 1

        UIView.animate(withDuration: 0.1, animations: {
            self.backgroundView.alpha = 0
            }) { (finished) -> Void in
                self.backgroundView.isHidden = true
        }
    }
    
}
