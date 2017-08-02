//
//  Window.swift
//  Ajimi
//
//  Created by nakajijapan on 2017/07/11.
//  Copyright © 2017 nakajijapan. All rights reserved.
//

import UIKit

class Window: UIWindow {

    var options: AjimiOptions!
    fileprivate let snapshotButton = UIButton(type: .system)
    fileprivate let recordButton = RecordButton(type: .system)
    fileprivate let stackView = UIStackView(frame: .zero)

    override var rootViewController: UIViewController? {
        didSet {
            if let TopViewController = rootViewController as? TopViewController {

                let cameraPath = resourceBundle().path(forResource: "camera", ofType: "png")!
                let cameraImage = UIImage(contentsOfFile: cameraPath)
                snapshotButton.setImage(cameraImage, for: .normal)
                snapshotButton.addTarget(self,
                                 action: #selector(snapshotButtonDidTap(_:)),
                                 for: .touchUpInside)

                let videoPath = resourceBundle().path(forResource: "video", ofType: "png")!
                let videoImage = UIImage(contentsOfFile: videoPath)

                recordButton.setImage(videoImage, for: .normal)
                recordButton.setTitleColor(.black, for: .normal)
                recordButton.addTarget(self,
                                 action: #selector(recordButtonDidTap(_:)),
                                 for: .touchUpInside)

                stackView.frame = CGRect(
                    x: 0.0,
                    y: self.bounds.height * 0.3,
                    width: cameraImage!.size.width + 8,
                    height: videoImage!.size.height * 2.0
                )

                stackView.alignment = UIStackViewAlignment.center
                stackView.axis = UILayoutConstraintAxis.vertical
                stackView.addArrangedSubview(snapshotButton)
                stackView.addArrangedSubview(recordButton)
                self.addSubview(stackView)
                let panGestureRecognizer = UIPanGestureRecognizer(
                    target: rootViewController,
                    action: #selector(TopViewController.handlePanGesture(_:)))
                stackView.addGestureRecognizer(panGestureRecognizer)
            }
        }
    }

    private func resourceBundle() -> Bundle {
        let bundlePath = Bundle.main.path(
            forResource: "Ajimi",
            ofType: "bundle",
            inDirectory: "Frameworks/Ajimi.framework"
        )

        if bundlePath != nil {
            return Bundle(path: bundlePath!)!
        }

        return Bundle(for: type(of: self))
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view === self {
            return nil
        }

        return view
    }

}

// MARK: - Button Actions
extension Window {

    func snapshotButtonDidTap(_ button: UIButton) {
        button.alpha = 1.0

        guard let image = takePhoto() else {
            return
        }

        let viewController = ImageEditViewController(image: image)
        let navigationController = UINavigationController(rootViewController: viewController)
        rootViewController?.present(navigationController, animated: true) { }
    }

    private func takePhoto() -> UIImage? {
        let window = Ajimi.targetWindow
        UIGraphicsBeginImageContext(window.bounds.size)
        window.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }

    func recordButtonDidTap(_ button: UIButton) {

        let outputPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!.appending("/ajimi.gif")
        if FileManager.default.fileExists(atPath: outputPath) {
            do {
                try FileManager.default.removeItem(atPath: outputPath)
            } catch {
                fatalError("failed to delete the file \(outputPath)")
            }
        }

        let screenRecorder = ScreenRecorder()
        screenRecorder.videoURL = URL(fileURLWithPath: outputPath)
        screenRecorder.startRecording()
        screenRecorder.delegate = self

        DispatchQueue.main.asyncAfter(deadline: .now() + screenRecorder.recordTime) {
            screenRecorder.stopRecording {
                let viewController = PostGIFViewController(imageURL: screenRecorder.videoURL!)
                let navigationController = UINavigationController(rootViewController: viewController)
                self.rootViewController?.present(navigationController, animated: true) { }
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
