//
//  RecordButton.swift
//  Ajimi
//
//  Created by daichi-nakajima on 2017/07/23.
//  Copyright © 2017年 nakajijapan. All rights reserved.
//

import UIKit

class RecordButton: UIButton {

    private var progressLayer: CAShapeLayer!

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }

    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        backgroundColor = UIColor.clear
    }

    public override func draw(_ rect: CGRect) {
        createProgressLayer()
    }

    private func createProgressLayer() {
        let startAngle = -Double.pi / 2.0
        let endAngle = Double.pi + 1.5
        let centerPoint = CGPoint(x: frame.width / 2, y: frame.height / 2)

        progressLayer = CAShapeLayer()
        let bezierPath = UIBezierPath(
            arcCenter: centerPoint,
            radius: 25.0,
            startAngle: CGFloat(startAngle),
            endAngle: CGFloat(endAngle), clockwise: true
        )
        progressLayer.path = bezierPath.cgPath
        progressLayer.backgroundColor = UIColor.clear.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.6).cgColor
        progressLayer.lineWidth = 4.0
        progressLayer.strokeStart = 0.0
        progressLayer.strokeEnd = 0.0
        progressLayer.lineCap = kCALineCapRound
        layer.addSublayer(progressLayer)
    }

    func reset() {
        progressLayer.removeFromSuperlayer()
        setNeedsDisplay()
    }

    func animateCurveToProgress(progress: Float) {

        if progressLayer == nil {
            return
        }

        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = NSNumber(value: Float(progressLayer.strokeEnd))
        animation.toValue = NSNumber(value: progress)
        animation.duration = 0.05
        animation.fillMode = kCAFillModeForwards
        progressLayer.strokeEnd = CGFloat(progress)
        progressLayer.add(animation, forKey: "strokeEnd")
    }

}
