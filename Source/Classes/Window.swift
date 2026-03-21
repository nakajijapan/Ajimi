//
//  Window.swift
//  Ajimi
//
//  Created by nakajijapan on 2017/07/11.
//  Copyright © 2017 nakajijapan. All rights reserved.
//

import UIKit

/// Custom UIWindow subclass that passes through touches to the app underneath
/// when the touch doesn't hit any Ajimi UI elements.
final class AjimiWindow: UIWindow {

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        // Return nil if the touch hit the window itself (not a subview),
        // so the touch passes through to the app's windows
        return view === self ? nil : view
    }
}
