//
//  Window.swift
//  Ajimi
//
//  Created by nakajijapan on 2017/07/11.
//  Copyright © 2017 nakajijapan. All rights reserved.
//

import UIKit

final class Window: UIWindow {

    var options: AjimiOptions!
    private let snapshotButton = UIButton(type: .system)
    private let recordButton = RecordButton(type: .system)
    private let stackView = UIStackView(frame: .zero)

    override var rootViewController: UIViewController? {
        didSet {
            guard let topViewController = rootViewController as? TopViewController else { return }

            let cameraImage = UIImage(named: "camera", in: resourceBundle(), compatibleWith: nil)
            snapshotButton.setImage(cameraImage, for: .normal)
            snapshotButton.addTarget(self, action: #selector(snapshotButtonDidTap(_:)), for: .touchUpInside)

            let videoImage = UIImage(named: "video", in: resourceBundle(), compatibleWith: nil)
            recordButton.setImage(videoImage, for: .normal)
            recordButton.setTitleColor(.black, for: .normal)
            recordButton.addTarget(self, action: #selector(recordButtonDidTap(_:)), for: .touchUpInside)

            stackView.frame = CGRect(
                x: 0.0,
                y: bounds.height * 0.3,
                width: (cameraImage?.size.width ?? 44) + 8,
                height: (videoImage?.size.height ?? 44) * 2.0
            )

            stackView.alignment = .center
            stackView.axis = .vertical
            stackView.addArrangedSubview(snapshotButton)
            stackView.addArrangedSubview(recordButton)
            addSubview(stackView)

            let panGestureRecognizer = UIPanGestureRecognizer(
                target: topViewController,
                action: #selector(TopViewController.handlePanGesture(_:))
            )
            stackView.addGestureRecognizer(panGestureRecognizer)
        }
    }

    private func resourceBundle() -> Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        let bundlePath = Bundle.main.path(
            forResource: "Ajimi",
            ofType: "bundle",
            inDirectory: "Frameworks/Ajimi.framework"
        )
        if let bundlePath {
            return Bundle(path: bundlePath) ?? Bundle(for: type(of: self))
        }
        return Bundle(for: type(of: self))
        #endif
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view === self ? nil : view
    }
}

// MARK: - Button Actions
extension Window {

    @objc private func snapshotButtonDidTap(_ button: UIButton) {
        button.alpha = 1.0

        guard let image = takePhoto() else { return }

        let viewController = ImageEditViewController(image: image)
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen
        rootViewController?.present(navigationController, animated: true)
    }

    private func takePhoto() -> UIImage? {
        guard let window = Ajimi.targetWindow else { return nil }
        let renderer = UIGraphicsImageRenderer(bounds: window.bounds)
        return renderer.image { _ in
            window.layer.render(in: UIGraphicsGetCurrentContext()!)
        }
    }

    @objc private func recordButtonDidTap(_ button: UIButton) {
        let outputPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("ajimi.gif")

        try? FileManager.default.removeItem(at: outputPath)

        let screenRecorder = ScreenRecorder()
        screenRecorder.videoURL = outputPath
        screenRecorder.startRecording()
        screenRecorder.delegate = self

        DispatchQueue.main.asyncAfter(deadline: .now() + screenRecorder.recordTime) {
            screenRecorder.stopRecording {
                guard let videoURL = screenRecorder.videoURL else { return }
                let viewController = PostGIFViewController(imageURL: videoURL)
                let navigationController = UINavigationController(rootViewController: viewController)
                navigationController.modalPresentationStyle = .fullScreen
                self.rootViewController?.present(navigationController, animated: true)
            }
        }
    }
}

// MARK: - ScreenRecorderDelegate
extension Window: ScreenRecorderDelegate {

    func screenRecordDidRefresh(_ recorder: ScreenRecorder, progress: Double) {
        recordButton.animateCurveToProgress(progress: Float(progress))
        if progress >= 1.0 {
            recordButton.reset()
        }
    }
}
