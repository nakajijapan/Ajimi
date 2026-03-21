//
//  AjimiState.swift
//  Ajimi
//
//  Created by nakajijapan on 2017/07/11.
//  Copyright © 2017 nakajijapan. All rights reserved.
//

import SwiftUI
import Combine

@MainActor
final class AjimiState: ObservableObject {

    enum Screen: Equatable {
        case idle
        case imageEdit(UIImage)
        case postScreenshot(UIImage)
        case recording
        case postGIF(URL)
    }

    @Published var screen: Screen = .idle
    @Published var isSubmitting = false
    @Published var alertMessage: AlertMessage?

    let options: AjimiOptions

    struct AlertMessage: Identifiable {
        let id = UUID()
        let title: String
        let message: String
    }

    init(options: AjimiOptions) {
        self.options = options
    }

    func takeScreenshot() {
        guard let window = Ajimi.targetWindow else { return }
        let renderer = UIGraphicsImageRenderer(bounds: window.bounds)
        let image = renderer.image { _ in
            window.layer.render(in: UIGraphicsGetCurrentContext()!)
        }
        screen = .imageEdit(image)
    }

    func startRecording() {
        screen = .recording
    }

    func finishRecording(gifURL: URL) {
        screen = .postGIF(gifURL)
    }

    func submitIssue(title: String, body: String, imageData: Data) {
        isSubmitting = true
        let reporter = Reporter(options: options)

        Task {
            do {
                try await reporter.submit(title: title, body: body, screenshotData: imageData)
                isSubmitting = false
                alertMessage = AlertMessage(title: "Success", message: "Posted.")
            } catch {
                isSubmitting = false
                alertMessage = AlertMessage(title: "Error", message: error.localizedDescription)
            }
        }
    }

    func dismissAlert() {
        alertMessage = nil
        screen = .idle
    }

    func cancel() {
        screen = .idle
    }
}
