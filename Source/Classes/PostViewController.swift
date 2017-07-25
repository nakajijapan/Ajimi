//
//  PostViewController.swift
//  Ajimi
//
//  Created by nakajijapan on 2017/07/12.
//  Copyright © 2017 nakajijapan. All rights reserved.
//

import UIKit

protocol PostViewControllerProtocol: class {
    var textField: UITextField { get }
    var textView: UITextView { get }
}
extension PostViewControllerProtocol where Self: UIViewController {
    func showAlertContrller(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { _ in
            self.dismiss(animated: true) { }
        }))

        if Thread.isMainThread {
            self.present(alert, animated: true) { }
        } else {
            DispatchQueue.main.sync {
                self.present(alert, animated: true) { }
            }
        }
    }

    func reportIssue(imageData: Data) {
        let windows = UIApplication.shared.windows.filter { $0 is Window }
        guard let window = windows.first as? Window else { fatalError("invalid window") }

        let reporter = Reporter(options: window.options)
        let title = textField.text ?? ""
        let body = textView.text ?? ""

        reporter.submit(title: title, body: body, screenshotData: imageData) { result in
            switch result {
            case .success:
                self.showAlertContrller(title: "Success", message: "Posted.")
            case .failure(let error):
                self.showAlertContrller(title: "Error", message: error.localizedDescription)
            }
        }
    }
}

class PostViewController: UIViewController, PostViewControllerProtocol {

    let image: UIImage
    let textField = UITextField(frame: .zero)
    let textView = UITextView(frame: .zero)

    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: UIBarButtonItemStyle.plain, target: self, action: #selector(rightBarButtonItemDidTap(_:)))

        let imageView = UIImageView(frame: .zero)
        imageView.image = image
        imageView.contentMode = .scaleAspectFit

        view.addSubview(imageView)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 64).isActive = true
        imageView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        imageView.backgroundColor = .gray
        view.addSubview(textField)

        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.topAnchor.constraint(equalTo: view.topAnchor, constant: 64 + 8).isActive = true
        textField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8).isActive = true
        textField.rightAnchor.constraint(equalTo: imageView.leftAnchor, constant: -8).isActive = true
        textField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        textField.placeholder = "title"
        textField.borderStyle = UITextBorderStyle.roundedRect
        view.addSubview(textView)

        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8).isActive = true
        textView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8).isActive = true
        textView.rightAnchor.constraint(equalTo: imageView.leftAnchor, constant: -8).isActive = true
        textView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 6.0
        textView.layer.borderColor = UIColor(red: 229/255.0, green: 229/255.0, blue: 229/255, alpha: 1.0).cgColor
        textField.becomeFirstResponder()
    }

    func rightBarButtonItemDidTap(_ button: UIBarButtonItem) {
        guard let imageData = UIImagePNGRepresentation(image) else {
            showAlertContrller(title: "Error", message: "can not create UIImagePNGRepresentation")
            return
        }
        reportIssue(imageData: imageData)
    }
}
