//
//  PostGIFViewController.swift
//  Ajimi
//
//  Created by nakajijapan on 2017/07/17.
//  Copyright © 2017 nakajijapan. All rights reserved.
//

import UIKit
import WebKit

final class PostGIFViewController: UIViewController, PostViewControllerProtocol {

    let imageURL: URL
    let textField = UITextField(frame: .zero)
    let textView = UITextView(frame: .zero)

    init(imageURL: URL) {
        self.imageURL = imageURL
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Ajimi"
        view.backgroundColor = .white

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel, target: self, action: #selector(leftBarButtonItemDidTap(_:))
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Send", style: .plain, target: self, action: #selector(rightBarButtonItemDidTap(_:))
        )

        let webView = WKWebView(frame: .zero)
        let htmlString = "<img src='\(imageURL.absoluteString)' style='width: 100%; height: auto;'>"
        webView.loadHTMLString(htmlString, baseURL: nil)
        webView.backgroundColor = .gray
        view.addSubview(webView)

        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.widthAnchor.constraint(equalToConstant: 100),
            webView.heightAnchor.constraint(equalToConstant: 200),
        ])

        view.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "title"
        textField.borderStyle = .roundedRect
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            textField.trailingAnchor.constraint(equalTo: webView.leadingAnchor, constant: -8),
            textField.heightAnchor.constraint(equalToConstant: 44),
        ])

        view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 6.0
        textView.layer.borderColor = UIColor(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1.0).cgColor
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            textView.trailingAnchor.constraint(equalTo: webView.leadingAnchor, constant: -8),
            textView.heightAnchor.constraint(equalToConstant: 200),
        ])

        textField.becomeFirstResponder()
    }

    @objc private func rightBarButtonItemDidTap(_ button: UIBarButtonItem) {
        do {
            let imageData = try Data(contentsOf: imageURL)
            reportIssue(imageData: imageData)
        } catch {
            showAlertController(title: "Error", message: "Cannot create data from GIF")
        }
    }

    @objc private func leftBarButtonItemDidTap(_ button: UIBarButtonItem) {
        dismiss(animated: true)
    }
}
