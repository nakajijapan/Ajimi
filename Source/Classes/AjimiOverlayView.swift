//
//  AjimiOverlayView.swift
//  Ajimi
//
//  Created by nakajijapan on 2017/07/11.
//  Copyright © 2017 nakajijapan. All rights reserved.
//

import SwiftUI

/// Root SwiftUI view for the Ajimi overlay
struct AjimiOverlayView: View {
    @StateObject var state: AjimiState

    var body: some View {
        ZStack {
            switch state.screen {
            case .idle:
                FloatingButtonView()
                    .environmentObject(state)

            case .imageEdit(let image):
                ImageEditView(image: image)
                    .environmentObject(state)
                    .transition(.move(edge: .bottom))

            case .postScreenshot(let image):
                NavigationStack {
                    PostView(image: image)
                        .environmentObject(state)
                }
                .transition(.move(edge: .trailing))

            case .recording:
                FloatingButtonView()
                    .environmentObject(state)

            case .postGIF(let url):
                PostGIFView(imageURL: url)
                    .environmentObject(state)
                    .transition(.move(edge: .bottom))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: state.screen)
    }
}
