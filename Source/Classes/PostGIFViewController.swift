//
//  PostGIFViewController.swift
//  Ajimi
//
//  Created by nakajijapan on 2017/07/17.
//  Copyright © 2017 nakajijapan. All rights reserved.
//

import UIKit

class PostGIFViewController: UIViewController, PostViewControllerProtocol {

    let imageURL: URL
    let textField = UITextField(frame: .zero)
    let textView = UITextView(frame: .zero)

    init(imageURL: URL) {
        self.imageURL = imageURL
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Ajimi"

        view.backgroundColor = .white
        automaticallyAdjustsScrollViewInsets = false

        navigationItem.leftBarButtonItem  = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(leftBarButtonItemDidTap(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: UIBarButtonItemStyle.plain, target: self, action: #selector(rightBarButtonItemDidTap(_:)))

        let webView = UIWebView(frame: .zero)
        let htmlString = "<img src='\(imageURL.absoluteString)' style='width: 100%; height: auto;'>"
        webView.loadHTMLString(htmlString, baseURL: nil)

        view.addSubview(webView)

        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.topAnchor.constraint(equalTo: view.topAnchor, constant: 64).isActive = true
        webView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        webView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        webView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        webView.backgroundColor = .gray
        view.addSubview(textField)

        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.topAnchor.constraint(equalTo: view.topAnchor, constant: 64 + 8).isActive = true
        textField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8).isActive = true
        textField.rightAnchor.constraint(equalTo: webView.leftAnchor, constant: -8).isActive = true
        textField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        textField.placeholder = "title"
        textField.borderStyle = UITextBorderStyle.roundedRect
        view.addSubview(textView)

        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8).isActive = true
        textView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8).isActive = true
        textView.rightAnchor.constraint(equalTo: webView.leftAnchor, constant: -8).isActive = true
        textView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 6.0
        textView.layer.borderColor = UIColor(red: 229/255.0, green: 229/255.0, blue: 229/255, alpha: 1.0).cgColor
        textField.becomeFirstResponder()
    }

    func rightBarButtonItemDidTap(_ button: UIBarButtonItem) {
        let imageData: Data
        do {
            imageData = try Data(contentsOf: imageURL)
        } catch {
            showAlertContrller(title: "Error", message: "can not create Data")
            return
        }
        reportIssue(imageData: imageData)
    }

    func leftBarButtonItemDidTap(_ button: UIBarButtonItem) {
        dismiss(animated: true) { }
    }
}
