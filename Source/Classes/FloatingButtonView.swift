//
//  FloatingButtonView.swift
//  Ajimi
//
//  Created by nakajijapan on 2017/07/11.
//  Copyright © 2017 nakajijapan. All rights reserved.
//

import SwiftUI

struct FloatingButtonView: View {
    @EnvironmentObject private var state: AjimiState
    @State private var position: CGPoint = CGPoint(x: 30, y: 300)
    @State private var isDragging = false
    @State private var isRecording = false
    @State private var recordProgress: Float = 0
    @State private var fadeOpacity: Double = 1.0
    @State private var fadeTask: Task<Void, Never>?

    private let screenRecorder = ScreenRecorder()

    var body: some View {
        VStack(spacing: 4) {
            snapshotButton
            recordButton
        }
        .opacity(fadeOpacity)
        .position(position)
        .gesture(dragGesture)
    }

    private var snapshotButton: some View {
        Button {
            state.takeScreenshot()
            resetFadeTimer()
        } label: {
            Image("camera", bundle: resourceBundle())
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
        }
    }

    private var recordButton: some View {
        Button {
            startRecording()
        } label: {
            ZStack {
                Image("video", bundle: resourceBundle())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)

                if isRecording {
                    Circle()
                        .trim(from: 0, to: CGFloat(recordProgress))
                        .stroke(Color.red.opacity(0.6), lineWidth: 4)
                        .rotationEffect(.degrees(-90))
                        .frame(width: 50, height: 50)
                }
            }
        }
        .disabled(isRecording)
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                isDragging = true
                fadeOpacity = 1.0
                position = value.location
            }
            .onEnded { value in
                isDragging = false
                withAnimation(.easeInOut(duration: 0.3)) {
                    position = snappedPosition(for: value.location)
                }
                resetFadeTimer()
            }
    }

    private func snappedPosition(for point: CGPoint) -> CGPoint {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        var x = point.x
        var y = point.y

        // Snap to edges
        if y < 60 {
            y = 50
            x = max(30, min(x, screenWidth - 30))
        } else if y > screenHeight - 60 {
            y = screenHeight - 50
            x = max(30, min(x, screenWidth - 30))
        } else {
            x = x < screenWidth / 2 ? 30 : screenWidth - 30
        }

        return CGPoint(x: x, y: y)
    }

    private func resetFadeTimer() {
        fadeTask?.cancel()
        fadeOpacity = 1.0
        fadeTask = Task {
            try? await Task.sleep(for: .seconds(5))
            guard !Task.isCancelled else { return }
            withAnimation(.easeInOut(duration: 0.3)) {
                fadeOpacity = 0.3
            }
        }
    }

    private func startRecording() {
        isRecording = true
        recordProgress = 0

        let outputURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("ajimi.gif")
        try? FileManager.default.removeItem(at: outputURL)

        screenRecorder.videoURL = outputURL
        screenRecorder.delegate = RecordProgressHandler { progress in
            recordProgress = Float(progress)
            if progress >= 1.0 {
                recordProgress = 0
            }
        }
        screenRecorder.startRecording()

        DispatchQueue.main.asyncAfter(deadline: .now() + screenRecorder.recordTime) {
            screenRecorder.stopRecording {
                isRecording = false
                recordProgress = 0
                if let url = screenRecorder.videoURL {
                    state.finishRecording(gifURL: url)
                }
            }
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
            return Bundle(path: bundlePath) ?? Bundle.main
        }
        return Bundle.main
        #endif
    }
}

/// Bridge for ScreenRecorderDelegate to use in SwiftUI
final class RecordProgressHandler: ScreenRecorderDelegate {
    private let onProgress: (Double) -> Void

    init(onProgress: @escaping (Double) -> Void) {
        self.onProgress = onProgress
    }

    func screenRecordDidRefresh(_ recorder: ScreenRecorder, progress: Double) {
        DispatchQueue.main.async {
            self.onProgress(progress)
        }
    }
}
