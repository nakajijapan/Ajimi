//
//  Ajimi.swift
//  Ajimi
//
//  Created by nakajijapan on 2017/07/11.
//  Copyright © 2017 nakajijapan. All rights reserved.
//

import UIKit
import SwiftUI
import AjimiCore

@MainActor
public final class Ajimi {

    private static var overlayWindow: AjimiWindow?

    static var targetWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { !($0 is AjimiWindow) }
    }

    public static func show(_ options: AjimiOptions) {
        guard overlayWindow == nil else { return }

        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first else { return }

        let state = AjimiState(options: options)
        let overlayView = AjimiOverlayView(state: state)
        let hostingController = UIHostingController(rootView: overlayView)
        hostingController.view.backgroundColor = .clear

        let window = AjimiWindow(windowScene: windowScene)
        window.backgroundColor = .clear
        window.rootViewController = hostingController
        window.windowLevel = .normal + 20.0
        window.makeKeyAndVisible()

        overlayWindow = window
    }

    public static func hide() {
        guard let window = overlayWindow else { return }
        window.isHidden = true
        window.rootViewController = nil
        overlayWindow = nil
    }
}
