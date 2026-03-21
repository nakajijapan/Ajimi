//
//  ImageEditView.swift
//  Ajimi
//
//  Created by nakajijapan on 2017/07/11.
//  Copyright © 2017 nakajijapan. All rights reserved.
//

import SwiftUI

struct ImageEditView: View {
    @EnvironmentObject private var state: AjimiState
    let image: UIImage
    @State private var rectangles: [AnnotationRect] = []

    struct AnnotationRect: Identifiable {
        let id = UUID()
        var origin: CGPoint
        var size: CGSize

        var rect: CGRect {
            CGRect(origin: origin, size: size)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                GeometryReader { geometry in
                    let displaySize = aspectFitSize(for: image.size, in: geometry.size)
                    let offsetX = (geometry.size.width - displaySize.width) / 2
                    let offsetY = (geometry.size.height - displaySize.height) / 2

                    ZStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: displaySize.width, height: displaySize.height)
                            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)

                        ForEach($rectangles) { $rect in
                            ResizableRectangleView(rect: $rect)
                                .offset(x: offsetX, y: offsetY)
                        }
                    }
                }

                toolbar
            }
            .background(Color.black)
            .navigationTitle("Ajimi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        state.cancel()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        let annotatedImage = renderAnnotatedImage()
                        state.screen = .postScreenshot(annotatedImage)
                    }
                }
            }
        }
    }

    private var toolbar: some View {
        HStack {
            Button("Rectangle") {
                let newRect = AnnotationRect(
                    origin: CGPoint(x: 50, y: 50),
                    size: CGSize(width: 100, height: 100)
                )
                rectangles.append(newRect)
            }
            .padding()
            Spacer()
        }
        .background(Color(uiColor: .systemBackground))
    }

    private func aspectFitSize(for imageSize: CGSize, in containerSize: CGSize) -> CGSize {
        let widthRatio = containerSize.width / imageSize.width
        let heightRatio = containerSize.height / imageSize.height
        let ratio = min(widthRatio, heightRatio)
        return CGSize(width: imageSize.width * ratio, height: imageSize.height * ratio)
    }

    private func renderAnnotatedImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        return renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: image.size))

            // We need to calculate the display-to-image ratio
            // For simplicity, use the first available geometry
            let containerSize = UIScreen.main.bounds.size
            let displaySize = aspectFitSize(for: image.size, in: containerSize)
            let ratio = image.size.width / displaySize.width

            let ctx = context.cgContext
            ctx.setStrokeColor(UIColor.red.cgColor)
            ctx.setLineWidth(2.0 * ratio)

            for rect in rectangles {
                let scaledRect = CGRect(
                    x: rect.origin.x * ratio,
                    y: rect.origin.y * ratio,
                    width: rect.size.width * ratio,
                    height: rect.size.height * ratio
                )
                ctx.stroke(scaledRect)
            }
        }
    }
}

/// A draggable and resizable rectangle annotation
struct ResizableRectangleView: View {
    @Binding var rect: ImageEditView.AnnotationRect
    @State private var dragOffset: CGSize = .zero

    var body: some View {
        ZStack {
            // Rectangle outline
            Rectangle()
                .stroke(Color.red, lineWidth: 2)
                .frame(width: rect.size.width, height: rect.size.height)
                .position(
                    x: rect.origin.x + rect.size.width / 2,
                    y: rect.origin.y + rect.size.height / 2
                )
                .gesture(moveGesture)

            // Corner handles
            cornerHandle(at: .topLeading)
            cornerHandle(at: .topTrailing)
            cornerHandle(at: .bottomLeading)
            cornerHandle(at: .bottomTrailing)
        }
    }

    enum Corner {
        case topLeading, topTrailing, bottomLeading, bottomTrailing
    }

    private func cornerHandle(at corner: Corner) -> some View {
        let position: CGPoint = {
            switch corner {
            case .topLeading:
                return CGPoint(x: rect.origin.x, y: rect.origin.y)
            case .topTrailing:
                return CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y)
            case .bottomLeading:
                return CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height)
            case .bottomTrailing:
                return CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height)
            }
        }()

        return Circle()
            .fill(Color.blue)
            .frame(width: 20, height: 20)
            .position(position)
            .gesture(resizeGesture(for: corner))
    }

    private var moveGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                rect.origin.x += value.translation.width - dragOffset.width
                rect.origin.y += value.translation.height - dragOffset.height
                dragOffset = value.translation
            }
            .onEnded { _ in
                dragOffset = .zero
            }
    }

    private func resizeGesture(for corner: Corner) -> some Gesture {
        DragGesture()
            .onChanged { value in
                let delta = CGSize(
                    width: value.translation.width - dragOffset.width,
                    height: value.translation.height - dragOffset.height
                )
                dragOffset = value.translation

                switch corner {
                case .topLeading:
                    rect.origin.x += delta.width
                    rect.origin.y += delta.height
                    rect.size.width -= delta.width
                    rect.size.height -= delta.height
                case .topTrailing:
                    rect.origin.y += delta.height
                    rect.size.width += delta.width
                    rect.size.height -= delta.height
                case .bottomLeading:
                    rect.origin.x += delta.width
                    rect.size.width -= delta.width
                    rect.size.height += delta.height
                case .bottomTrailing:
                    rect.size.width += delta.width
                    rect.size.height += delta.height
                }
            }
            .onEnded { _ in
                dragOffset = .zero
            }
    }
}
