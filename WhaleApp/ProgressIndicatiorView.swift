//
//  ProgressIndicatiorView.swift
//  WhaleApp
//
//  Created by Dan Kindler on 12/3/16.
//  Copyright © 2016 Dan Kindler. All rights reserved.
//

import UIKit

protocol ProgressIndicatiorViewDelegate {
    func hasReachedMinimumRecordTime(sender: ProgressIndicatiorView)
    func hasReachedMaxRecordTime(sender: ProgressIndicatiorView)
}

class ProgressIndicatiorView: UIView {
    let timerSpeedInSeconds = 0.05
    let progressLayer: CAShapeLayer = CAShapeLayer()
    var progressColor: UIColor = whaleColor
    var delegate: ProgressIndicatiorViewDelegate?
    
    var timer: Timer?
    
    var hasReachedMinRecordTime = false
    var hasReachedMaxRecordTime = false

    var currentSecondsCount: CGFloat = 0 {
        didSet {
            drawProgress(progress: currentSecondsCount / MAX_RECORD)
            
            if currentSecondsCount >= MIN_RECORD && !hasReachedMinRecordTime {
                delegate?.hasReachedMinimumRecordTime(sender: self)
                hasReachedMinRecordTime = true
            }
            
            if currentSecondsCount >= MAX_RECORD && hasReachedMaxRecordTime {
                delegate?.hasReachedMaxRecordTime(sender: self)
                hasReachedMaxRecordTime = true
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.backgroundColor = .black
        self.alpha = 0.7
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func drawProgress(progress: CGFloat) {
        guard progress >= 0 && progress <= 1 else { return }
        
        if progress <= self.bounds.width - 10 {
            progressLayer.removeFromSuperlayer()
            let bezierPathProg = UIBezierPath(rect: CGRect(x: 0, y: 0, width: progress * self.bounds.width, height: self.bounds.height))
            bezierPathProg.close()
            progressLayer.path = bezierPathProg.cgPath
            progressLayer.fillColor = progress >= (MIN_RECORD/MAX_RECORD) ? progressColor.cgColor : UIColor.white.cgColor
            layer.addSublayer(progressLayer)
        }
    }
    
    // MARK: - Actions
    
    func startProgressBarProgression() {
        timer = Timer.scheduledTimer(timeInterval: timerSpeedInSeconds, target: self, selector: #selector(handleTimer), userInfo: nil, repeats: true)
    }
    
    func endProgressBarProgression() {
        timer?.invalidate()
    }
    
    func handleTimer() {
        currentSecondsCount += CGFloat(timerSpeedInSeconds)
    }
    
    func reset() {
        hasReachedMaxRecordTime = false
        hasReachedMinRecordTime = false
        currentSecondsCount = 0
    }
}









