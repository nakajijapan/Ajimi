//
//  PostViewController.swift
//  Ajimi
//
//  Created by nakajijapan on 2017/07/12.
//  Copyright © 2017 nakajijapan. All rights reserved.
//

import UIKit

protocol PostViewControllerProtocol: AnyObject {
    var textField: UITextField { get }
    var textView: UITextView { get }
}

extension PostViewControllerProtocol where Self: UIViewController {

    func showAlertController(title: String, message: String) {
        let showAlert = {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                self.dismiss(animated: true)
            })
            self.present(alert, animated: true)
        }

        if Thread.isMainThread {
            showAlert()
        } else {
            DispatchQueue.main.async {
                showAlert()
            }
        }
    }

    func reportIssue(imageData: Data) {
        guard let window = Ajimi.window else { return }
        let reporter = Reporter(options: window.options)
        let title = textField.text ?? ""
        let body = textView.text ?? ""

        Task {
            do {
                try await reporter.submit(title: title, body: body, screenshotData: imageData)
                await MainActor.run {
                    showAlertController(title: "Success", message: "Posted.")
                }
            } catch {
                await MainActor.run {
                    showAlertController(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
}

final class PostViewController: UIViewController, PostViewControllerProtocol {

    let image: UIImage
    let textField = UITextField(frame: .zero)
    let textView = UITextView(frame: .zero)

    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Send", style: .plain, target: self, action: #selector(rightBarButtonItemDidTap(_:))
        )

        let imageView = UIImageView(frame: .zero)
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .gray
        view.addSubview(imageView)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 100),
            imageView.heightAnchor.constraint(equalToConstant: 200),
        ])

        view.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "title"
        textField.borderStyle = .roundedRect
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            textField.trailingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: -8),
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
            textView.trailingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: -8),
            textView.heightAnchor.constraint(equalToConstant: 200),
        ])

        textField.becomeFirstResponder()
    }

    @objc private func rightBarButtonItemDidTap(_ button: UIBarButtonItem) {
        guard let imageData = image.pngData() else {
            showAlertController(title: "Error", message: "Cannot create PNG data from image")
            return
        }
        reportIssue(imageData: imageData)
    }
}
