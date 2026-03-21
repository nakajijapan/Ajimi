//
//  PostGIFView.swift
//  Ajimi
//
//  Created by nakajijapan on 2017/07/17.
//  Copyright © 2017 nakajijapan. All rights reserved.
//

import SwiftUI
import WebKit

struct PostGIFView: View {
    @EnvironmentObject private var state: AjimiState
    let imageURL: URL
    @State private var title = ""
    @State private var body = ""

    var body: some View {
        NavigationStack {
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

                GIFWebView(url: imageURL)
                    .frame(width: 100, height: 200)
                    .background(Color.gray)
            }
            .padding(8)
            .navigationTitle("Ajimi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        state.cancel()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if state.isSubmitting {
                        ProgressView()
                    } else {
                        Button("Send") {
                            guard let imageData = try? Data(contentsOf: imageURL) else { return }
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
}

struct GIFWebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        let html = "<img src='\(url.absoluteString)' style='width: 100%; height: auto;'>"
        webView.loadHTMLString(html, baseURL: nil)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
