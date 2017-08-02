//
//  ScreenRecorder.swift
//  Ajimi
//
//  Created by nakajijapan on 2017/07/17.
//  Copyright © 2017 nakajijapan. All rights reserved.
//

import Foundation
import UIKit
import ImageIO
import MobileCoreServices

protocol ScreenRecorderDelegate: class {
    func screenRecordDidRefresh(_ recorder: ScreenRecorder, progress: Double)
}

class ScreenRecorder {
    var isRecording = false
    var videoURL: URL? {
        didSet  {
            debugPrint(videoURL ?? "")
        }
    }
    private var displayLink: CADisplayLink!
    private var keyWindow = Ajimi.targetWindow
    var recordTime: CFTimeInterval = 5.0
    var images: [UIImage] = []
    var startTime: CFTimeInterval = 0.0
    weak var delegate: ScreenRecorderDelegate?

    public func startRecording() {
        if !isRecording {
            isRecording = true
            startTime = CACurrentMediaTime()
            displayLink = CADisplayLink(target: self, selector: #selector(displayDidRefresh(_:)))
            displayLink.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
        }
    }
    public func stopRecording(completion: @escaping () -> Void) {
        if isRecording {
            isRecording = false
            displayLink.remove(from: RunLoop.main, forMode: RunLoopMode.commonModes)
            completeRecordingSession(completion: completion)
        }
    }

    @objc func displayDidRefresh(_ sender: CADisplayLink) {
        UIGraphicsBeginImageContextWithOptions(keyWindow.bounds.size, true, 0)
        keyWindow.drawHierarchy(in: keyWindow.bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        let resizedImage = image!.resize(size: CGSize(width: image!.size.width / 2.0, height: image!.size.height / 2.0))!

        images.append(resizedImage)

        let current = (CACurrentMediaTime() - startTime) / recordTime
        delegate?.screenRecordDidRefresh(self, progress: current)
    }

    func clean() {
        images = []
    }

    func completeRecordingSession(completion: @escaping () -> Void) {
        createGIF()
        DispatchQueue.main.async {
            completion()
            self.clean()
        }
    }

    func createGIF() {
        let loopCount = 0
        let frameCount = images.count
        let delayTime = recordTime / Double(images.count)
        let destinationFileURL = videoURL!

        let fileProperties = [
            kCGImagePropertyGIFDictionary as String: [
                kCGImagePropertyGIFLoopCount as String: NSNumber(value: Int32(loopCount) as Int32)
            ],
            kCGImagePropertyGIFHasGlobalColorMap as String: NSValue(nonretainedObject: true)
            ] as [String : Any]

        let frameProperties = [
            kCGImagePropertyGIFDictionary as String:[
                kCGImagePropertyGIFDelayTime as String:delayTime
            ]
        ]

        guard let destination = CGImageDestinationCreateWithURL(destinationFileURL as CFURL, kUTTypeGIF, frameCount, nil) else {
            assertionFailure("dest not found = \(destinationFileURL.absoluteString)")
            return
        }
        CGImageDestinationSetProperties(destination, fileProperties as CFDictionary)

        images.forEach { image in
            CGImageDestinationAddImage(destination, image.cgImage!, frameProperties as CFDictionary)
        }

        if !CGImageDestinationFinalize(destination) {
            assertionFailure("finalize error")
        }
    }

}
