//
//  RectangleView.swift
//  Ajimi
//
//  Created by nakajijapan on 2017/07/12.
//  Copyright © 2017 nakajijapan. All rights reserved.
//

import UIKit

class RectangleView: UIView {

    let lengthOfTouchSide: CGFloat = 20.0
    let merginOfRectangle: CGFloat = 10
    var rectangleLayer = CAShapeLayer()

    enum TransformArea: Int {
        case leftTop
        case rightTop
        case rightBottom
        case leftBottom
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        let movePanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleMovePanGesture(_:)))
        addGestureRecognizer(movePanGestureRecognizer)

        backgroundColor = .clear

        self.addSubview(leftTopView)
        self.addSubview(rightTopView)

        self.addSubview(leftBottomView)
        self.addSubview(rightBottomView)
    }

    lazy var leftTopView: UIView = {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.lengthOfTouchSide, height: self.lengthOfTouchSide))
        view.backgroundColor = .clear
        view.tag = TransformArea.leftTop.rawValue

        let circleLayer = CAShapeLayer()
        let radius: CGFloat = 10.0
        circleLayer.path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: view.frame.size), cornerRadius: radius).cgPath
        circleLayer.position = CGPoint(x: 0, y: 0)
        circleLayer.fillColor = UIColor.blue.cgColor
        view.layer.addSublayer(circleLayer)

        let recongnizer = UIPanGestureRecognizer(target: self, action: #selector(handleTransformMovePanGesture(_:)))
        view.addGestureRecognizer(recongnizer)

        return view
    }()
    lazy var rightTopView: UIView = {
        let view = UIView(frame: CGRect(x: self.frame.width - self.lengthOfTouchSide, y: 0.0, width: self.lengthOfTouchSide, height: self.lengthOfTouchSide))
        view.backgroundColor = .clear
        view.tag = TransformArea.rightTop.rawValue

        let circleLayer = CAShapeLayer()
        let radius: CGFloat = 10.0
        circleLayer.path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: view.frame.size), cornerRadius: radius).cgPath
        circleLayer.position = CGPoint(x: 0, y: 0)
        circleLayer.fillColor = UIColor.blue.cgColor
        view.layer.addSublayer(circleLayer)

        let recongnizer = UIPanGestureRecognizer(target: self, action: #selector(handleTransformMovePanGesture(_:)))
        view.addGestureRecognizer(recongnizer)

        return view
    }()

    lazy var rightBottomView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: self.frame.height - self.lengthOfTouchSide, width: self.lengthOfTouchSide, height: self.lengthOfTouchSide))
        view.backgroundColor = .clear
        view.tag = TransformArea.rightBottom.rawValue

        let circleLayer = CAShapeLayer()
        let radius: CGFloat = 10.0
        circleLayer.path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: view.frame.size), cornerRadius: radius).cgPath
        circleLayer.position = CGPoint(x: 0, y: 0)
        circleLayer.fillColor = UIColor.blue.cgColor
        view.layer.addSublayer(circleLayer)

        let recongnizer = UIPanGestureRecognizer(target: self, action: #selector(handleTransformMovePanGesture(_:)))
        view.addGestureRecognizer(recongnizer)
        self.addSubview(view)

        return view
    }()

    lazy var leftBottomView: UIView = {
        let view = UIView(frame: CGRect(x: self.frame.width - self.lengthOfTouchSide, y: self.frame.height - self.lengthOfTouchSide, width: self.lengthOfTouchSide, height: self.lengthOfTouchSide))
        view.backgroundColor = .clear
        view.tag = TransformArea.leftBottom.rawValue

        let circleLayer = CAShapeLayer()
        let radius: CGFloat = 10.0
        circleLayer.path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: view.frame.size), cornerRadius: radius).cgPath
        circleLayer.position = CGPoint(x: 0, y: 0)
        circleLayer.fillColor = UIColor.blue.cgColor
        view.layer.addSublayer(circleLayer)

        let recongnizer = UIPanGestureRecognizer(target: self, action: #selector(handleTransformMovePanGesture(_:)))
        view.addGestureRecognizer(recongnizer)

        return view
    }()

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
        switch gestureRecognizer.state {
        case .changed:
            let point  = gestureRecognizer.translation(in: self)
            let center = CGPoint(x: gestureRecognizer.view!.center.x + point.x, y: gestureRecognizer.view!.center.y + point.y)
            gestureRecognizer.view!.center = center
            gestureRecognizer.setTranslation(.zero, in: self)
        default:
            break
        }
    }

    var startTransform:CGAffineTransform!

    func rectangleRect() -> CGRect {
        var rect = rectangleRect(frame)
        rect.origin.x += frame.origin.x
        rect.origin.y += frame.origin.y
        return rect
    }

    private func rectangleRect(_ frame: CGRect) -> CGRect {
        return CGRect(
            x: merginOfRectangle,
            y: merginOfRectangle,
            width: frame.width - merginOfRectangle * 2,
            height: frame.height - merginOfRectangle * 2
        )
    }

    private func updateTransformView() {
        rightTopView.frame = CGRect(
            x: frame.width - self.lengthOfTouchSide,
            y: 0.0, width: self.lengthOfTouchSide,
            height: self.lengthOfTouchSide
        )
        leftBottomView.frame = CGRect(
            x: frame.width - lengthOfTouchSide,
            y: frame.height - lengthOfTouchSide,
            width: lengthOfTouchSide,
            height: lengthOfTouchSide
        )
        rightBottomView.frame = CGRect(
            x: 0.0,
            y: frame.height - lengthOfTouchSide,
            width: lengthOfTouchSide,
            height: lengthOfTouchSide
        )
    }

    @objc private func handleTransformMovePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .changed:
            let point  = gestureRecognizer.translation(in: self)

            guard let targetView = gestureRecognizer.view else { return }
            guard let transformArea = TransformArea(rawValue: targetView.tag) else { return }

            switch transformArea {
            case .leftTop:
                var originalFrame = frame
                originalFrame.origin.x += point.x
                originalFrame.origin.y += point.y
                originalFrame.size = CGSize(width: frame.width - point.x, height: frame.height - point.y)
                frame = originalFrame
            case .rightTop:
                var originalFrame = frame
                originalFrame.origin.y += point.y
                originalFrame.size = CGSize(width: frame.width + point.x, height: frame.height - point.y)
                frame = originalFrame
            case .rightBottom:
                var originalFrame = frame
                originalFrame.origin.x += point.x
                originalFrame.size = CGSize(width: frame.width - point.x, height: frame.height + point.y)
                frame = originalFrame
            case .leftBottom:
                var originalFrame = frame
                originalFrame.size = CGSize(width: frame.width + point.x, height: frame.height + point.y)
                frame = originalFrame
            }

            let rect = rectangleRect(frame)
            rectangleLayer.path = UIBezierPath(rect: rect).cgPath
            updateTransformView()

            gestureRecognizer.setTranslation(.zero, in: self)
        default:
            break
        }
    }
}
