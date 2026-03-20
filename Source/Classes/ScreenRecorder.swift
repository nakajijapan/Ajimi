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
import UniformTypeIdentifiers

protocol ScreenRecorderDelegate: AnyObject {
    func screenRecordDidRefresh(_ recorder: ScreenRecorder, progress: Double)
}

final class ScreenRecorder {
    var isRecording = false
    var videoURL: URL?
    var recordTime: CFTimeInterval = 5.0
    var images: [UIImage] = []
    weak var delegate: ScreenRecorderDelegate?

    private var displayLink: CADisplayLink?
    private var keyWindow: UIWindow?
    private var startTime: CFTimeInterval = 0.0

    func startRecording() {
        guard !isRecording else { return }
        isRecording = true
        keyWindow = Ajimi.targetWindow
        startTime = CACurrentMediaTime()
        let link = CADisplayLink(target: self, selector: #selector(displayDidRefresh(_:)))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    func stopRecording(completion: @escaping () -> Void) {
        guard isRecording else { return }
        isRecording = false
        displayLink?.remove(from: .main, forMode: .common)
        displayLink = nil
        completeRecordingSession(completion: completion)
    }

    @objc private func displayDidRefresh(_ sender: CADisplayLink) {
        guard let keyWindow else { return }

        let renderer = UIGraphicsImageRenderer(bounds: keyWindow.bounds)
        let image = renderer.image { context in
            keyWindow.drawHierarchy(in: keyWindow.bounds, afterScreenUpdates: false)
        }

        if let resizedImage = image.resize(size: CGSize(width: image.size.width / 2.0, height: image.size.height / 2.0)) {
            images.append(resizedImage)
        }

        let current = (CACurrentMediaTime() - startTime) / recordTime
        delegate?.screenRecordDidRefresh(self, progress: current)
    }

    func clean() {
        images = []
    }

    private func completeRecordingSession(completion: @escaping () -> Void) {
        createGIF()
        DispatchQueue.main.async {
            completion()
            self.clean()
        }
    }

    private func createGIF() {
        guard !images.isEmpty, let destinationFileURL = videoURL else { return }

        let loopCount = 0
        let frameCount = images.count
        let delayTime = recordTime / Double(frameCount)

        let fileProperties: [String: Any] = [
            kCGImagePropertyGIFDictionary as String: [
                kCGImagePropertyGIFLoopCount as String: loopCount
            ]
        ]

        let frameProperties: [String: Any] = [
            kCGImagePropertyGIFDictionary as String: [
                kCGImagePropertyGIFDelayTime as String: delayTime
            ]
        ]

        guard let destination = CGImageDestinationCreateWithURL(
            destinationFileURL as CFURL,
            UTType.gif.identifier as CFString,
            frameCount,
            nil
        ) else {
            assertionFailure("dest not found = \(destinationFileURL.absoluteString)")
            return
        }

        CGImageDestinationSetProperties(destination, fileProperties as CFDictionary)

        for image in images {
            guard let cgImage = image.cgImage else { continue }
            CGImageDestinationAddImage(destination, cgImage, frameProperties as CFDictionary)
        }

        if !CGImageDestinationFinalize(destination) {
            assertionFailure("finalize error")
        }
    }
}
