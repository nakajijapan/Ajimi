//
//  RectangleView.swift
//  Ajimi
//
//  Created by nakajijapan on 2017/07/12.
//  Copyright © 2017 nakajijapan. All rights reserved.
//

import UIKit

final class RectangleView: UIView {

    let lengthOfTouchSide: CGFloat = 20.0
    let marginOfRectangle: CGFloat = 10
    var rectangleLayer = CAShapeLayer()

    enum TransformArea: Int {
        case leftTop
        case rightTop
        case rightBottom
        case leftBottom
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        let movePanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleMovePanGesture(_:)))
        addGestureRecognizer(movePanGestureRecognizer)

        backgroundColor = .clear

        addSubview(leftTopView)
        addSubview(rightTopView)
        addSubview(leftBottomView)
        addSubview(rightBottomView)
    }

    private lazy var leftTopView: UIView = {
        makeCornerView(
            frame: CGRect(x: 0, y: 0, width: lengthOfTouchSide, height: lengthOfTouchSide),
            tag: TransformArea.leftTop.rawValue
        )
    }()

    private lazy var rightTopView: UIView = {
        makeCornerView(
            frame: CGRect(x: frame.width - lengthOfTouchSide, y: 0, width: lengthOfTouchSide, height: lengthOfTouchSide),
            tag: TransformArea.rightTop.rawValue
        )
    }()

    private lazy var rightBottomView: UIView = {
        makeCornerView(
            frame: CGRect(x: 0, y: frame.height - lengthOfTouchSide, width: lengthOfTouchSide, height: lengthOfTouchSide),
            tag: TransformArea.rightBottom.rawValue
        )
    }()

    private lazy var leftBottomView: UIView = {
        makeCornerView(
            frame: CGRect(x: frame.width - lengthOfTouchSide, y: frame.height - lengthOfTouchSide, width: lengthOfTouchSide, height: lengthOfTouchSide),
            tag: TransformArea.leftBottom.rawValue
        )
    }()

    private func makeCornerView(frame: CGRect, tag: Int) -> UIView {
        let view = UIView(frame: frame)
        view.backgroundColor = .clear
        view.tag = tag

        let circleLayer = CAShapeLayer()
        circleLayer.path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: frame.size), cornerRadius: 10.0).cgPath
        circleLayer.fillColor = UIColor.blue.cgColor
        view.layer.addSublayer(circleLayer)

        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(handleTransformMovePanGesture(_:)))
        view.addGestureRecognizer(recognizer)

        return view
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        let rect = rectangleRect(frame)
        rectangleLayer.path = UIBezierPath(rect: rect).cgPath
        rectangleLayer.lineWidth = 2.0
        rectangleLayer.strokeColor = UIColor.red.cgColor
        rectangleLayer.fillColor = UIColor.clear.cgColor
        rectangleLayer.backgroundColor = UIColor.clear.cgColor
        layer.addSublayer(rectangleLayer)
    }

    func createShapeLayer() -> CAShapeLayer {
        let rect = rectangleRect(frame)
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(rect: rect).cgPath
        layer.lineWidth = 2.0
        layer.strokeColor = UIColor.red.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.backgroundColor = UIColor.clear.cgColor
        return layer
    }

    @objc private func handleMovePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard case .changed = gestureRecognizer.state,
              let targetView = gestureRecognizer.view else { return }

        let point = gestureRecognizer.translation(in: self)
        targetView.center = CGPoint(x: targetView.center.x + point.x, y: targetView.center.y + point.y)
        gestureRecognizer.setTranslation(.zero, in: self)
    }

    func rectangleRect() -> CGRect {
        var rect = rectangleRect(frame)
        rect.origin.x += frame.origin.x
        rect.origin.y += frame.origin.y
        return rect
    }

    private func rectangleRect(_ frame: CGRect) -> CGRect {
        CGRect(
            x: marginOfRectangle,
            y: marginOfRectangle,
            width: frame.width - marginOfRectangle * 2,
            height: frame.height - marginOfRectangle * 2
        )
    }

    private func updateTransformView() {
        rightTopView.frame = CGRect(
            x: frame.width - lengthOfTouchSide,
            y: 0,
            width: lengthOfTouchSide,
            height: lengthOfTouchSide
        )
        leftBottomView.frame = CGRect(
            x: frame.width - lengthOfTouchSide,
            y: frame.height - lengthOfTouchSide,
            width: lengthOfTouchSide,
            height: lengthOfTouchSide
        )
        rightBottomView.frame = CGRect(
            x: 0,
            y: frame.height - lengthOfTouchSide,
            width: lengthOfTouchSide,
            height: lengthOfTouchSide
        )
    }

    @objc private func handleTransformMovePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard case .changed = gestureRecognizer.state,
              let targetView = gestureRecognizer.view,
              let transformArea = TransformArea(rawValue: targetView.tag) else { return }

        let point = gestureRecognizer.translation(in: self)
        var originalFrame = frame

        switch transformArea {
        case .leftTop:
            originalFrame.origin.x += point.x
            originalFrame.origin.y += point.y
            originalFrame.size = CGSize(width: frame.width - point.x, height: frame.height - point.y)
        case .rightTop:
            originalFrame.origin.y += point.y
            originalFrame.size = CGSize(width: frame.width + point.x, height: frame.height - point.y)
        case .rightBottom:
            originalFrame.origin.x += point.x
            originalFrame.size = CGSize(width: frame.width - point.x, height: frame.height + point.y)
        case .leftBottom:
            originalFrame.size = CGSize(width: frame.width + point.x, height: frame.height + point.y)
        }

        frame = originalFrame
        rectangleLayer.path = UIBezierPath(rect: rectangleRect(frame)).cgPath
        updateTransformView()
        gestureRecognizer.setTranslation(.zero, in: self)
    }
}
