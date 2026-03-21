//
//  PostView.swift
//  Ajimi
//
//  Created by nakajijapan on 2017/07/12.
//  Copyright © 2017 nakajijapan. All rights reserved.
//

import SwiftUI

struct PostView: View {
    @EnvironmentObject private var state: AjimiState
    let image: UIImage
    @State private var title = ""
    @State private var body = ""

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(spacing: 8) {
                TextField("Title", text: $title)
                    .textFieldStyle(.roundedBorder)

                TextEditor(text: $body)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color(uiColor: UIColor(red: 229/255, green: 229/255, blue: 229/255, alpha: 1)), lineWidth: 1)
                    )
            }

            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: 100)
                .background(Color.gray)
        }
        .padding(8)
        .navigationTitle("Ajimi")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if state.isSubmitting {
                    ProgressView()
                } else {
                    Button("Send") {
                        guard let imageData = image.pngData() else { return }
                        state.submitIssue(title: title, body: body, imageData: imageData)
                    }
                }
            }
        }
        .alert(item: $state.alertMessage) { alert in
            Alert(
                title: Text(alert.title),
                message: Text(alert.message),
                dismissButton: .default(Text("OK")) {
                    state.dismissAlert()
                }
            )
        }
    }
}
