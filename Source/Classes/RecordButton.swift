//
//  RecordButton.swift
//  Ajimi
//
//  Created by daichi-nakajima on 2017/07/23.
//  Copyright © 2017 nakajijapan. All rights reserved.
//

import UIKit

final class RecordButton: UIButton {

    private var progressLayer: CAShapeLayer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        createProgressLayer()
    }

    private func createProgressLayer() {
        let startAngle = -CGFloat.pi / 2.0
        let endAngle = CGFloat.pi + 1.5
        let centerPoint = CGPoint(x: frame.width / 2, y: frame.height / 2)

        let layer = CAShapeLayer()
        let bezierPath = UIBezierPath(
            arcCenter: centerPoint,
            radius: 25.0,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )
        layer.path = bezierPath.cgPath
        layer.backgroundColor = UIColor.clear.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.6).cgColor
        layer.lineWidth = 4.0
        layer.strokeStart = 0.0
        layer.strokeEnd = 0.0
        layer.lineCap = .round
        self.layer.addSublayer(layer)
        progressLayer = layer
    }

    func reset() {
        progressLayer?.removeFromSuperlayer()
        progressLayer = nil
        setNeedsDisplay()
    }

    func animateCurveToProgress(progress: Float) {
        guard let progressLayer else { return }

        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = progressLayer.strokeEnd
        animation.toValue = progress
        animation.duration = 0.05
        animation.fillMode = .forwards
        progressLayer.strokeEnd = CGFloat(progress)
        progressLayer.add(animation, forKey: "strokeEnd")
    }
}
