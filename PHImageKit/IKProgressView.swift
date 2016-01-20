//
//  IKProgressView.swift
//  PHImageKit
//
//  Created by Vlado on 12/6/15.
//  Copyright © 2015 Product Hunt. All rights reserved.
//

import UIKit

class IKProgressView: UIView {

    var lineWidth : CGFloat = 5
    var arkColor = UIColor.blackColor()
    var radius : CGFloat = 30 {
        didSet {
            setNeedsDisplay()
        }
    }

    private let backgroundLayer = CALayer()
    private let progressLayer = CAShapeLayer()
    private let backgroundView = UIView()

    class func progressInSuperview(superview: UIView) -> IKProgressView {
        let progressView = IKProgressView()

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

    private func commonInit() {
        progressLayer.fillColor = UIColor.clearColor().CGColor
        progressLayer.strokeColor = arkColor.CGColor
        progressLayer.lineWidth = lineWidth
        progressLayer.strokeStart = 0.0
        progressLayer.strokeEnd = 0.0

        backgroundView.frame = self.bounds;
        backgroundView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        backgroundView.layer.addSublayer(backgroundLayer)

        addSubview(backgroundView)

        backgroundLayer.addSublayer(progressLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        backgroundLayer.frame = bounds

        let path = UIBezierPath()
        path.lineCapStyle = CGLineCap.Butt
        path.lineWidth = lineWidth

        path.addArcWithCenter(backgroundView.center, radius: radius + lineWidth / 2, startAngle: CGFloat(-M_PI_2), endAngle: CGFloat(M_PI + M_PI_2), clockwise: true)
        progressLayer.path = path.CGPath
    }

    func setProgress(progress: CGFloat) {
        let normalizedProgress = max(0, min(progress, 1))

        backgroundView.hidden = !(normalizedProgress > 0) || normalizedProgress > CGFloat.max
        progressLayer.strokeEnd = normalizedProgress

        if normalizedProgress == 1 {
            hide()
        }
    }

    func hide() {
        backgroundView.alpha = 1

        UIView.animateWithDuration(0.1, animations: {
            self.backgroundView.alpha = 0
            }) { (finished) -> Void in
                self.backgroundView.hidden = true
        }
    }
    
}
