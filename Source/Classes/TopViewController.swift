//
//  TopViewController.swift
//  Ajimi
//
//  Created by nakajijapan on 2017/07/11.
//  Copyright © 2017 nakajijapan. All rights reserved.
//

import UIKit

class TopViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {

        guard let gesturingView = gestureRecognizer.view else {
            return
        }

        switch gestureRecognizer.state {
        case .began:
            gesturingView.alpha = 1.0
        case .changed:
            let point  = gestureRecognizer.translation(in: view)
            let center = CGPoint(
                x: gesturingView.center.x + point.x,
                y: gesturingView.center.y + point.y
            )
            gesturingView.center = center
            gestureRecognizer.setTranslation(.zero, in: view)
        default:
            let point  = gesturingView.center
            let width  = gesturingView.bounds.width
            let height = gesturingView.bounds.height

            var x = point.x
            var y = point.y

            if y - 60.0 <= view.bounds.minY {
                if x - width * 0.5 <= view.bounds.minX {
                    x = view.bounds.minX + width * 0.5
                } else if view.bounds.maxX <= x + width * 0.5 {
                    x = view.bounds.maxX - width * 0.5
                }
                y = view.bounds.minY + height * 0.5
            } else if view.bounds.maxY <= y + 60.0 {
                if x - width * 0.5 <= view.bounds.minX {
                    x = view.bounds.minX + width * 0.5
                } else if view.bounds.maxX <= x + width * 0.5 {
                    x = view.bounds.maxX - width * 0.5
                }
                y = view.bounds.maxY - height * 0.5
            } else {
                if x < view.bounds.width * 0.5 {
                    x = view.bounds.minX + width * 0.5
                } else {
                    x = view.bounds.maxX - width * 0.5
                }
            }

            let center = CGPoint(x: x, y: y)

            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
                gesturingView.center = center
            }, completion: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    guard center.equalTo(gesturingView.center) else {
                        return
                    }

                    UIView.animate(withDuration: 0.3) {
                        gestureRecognizer.view!.alpha = 0.3
                    }
                }
            })
        }
    }
}
