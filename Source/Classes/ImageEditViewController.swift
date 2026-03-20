//
//  ImageEditViewController.swift
//  Ajimi
//
//  Created by nakajijapan on 2017/07/11.
//  Copyright © 2017 nakajijapan. All rights reserved.
//

import UIKit

final class ImageEditViewController: UIViewController {

    let image: UIImage
    let containerView = UIView(frame: .zero)
    let toolbar = UIToolbar(frame: .zero)
    var rectangleViews: [RectangleView] = []

    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Ajimi"

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done, target: self, action: #selector(rightBarButtonItemDidTap(_:))
        )
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel, target: self, action: #selector(leftBarButtonItemDidTap(_:))
        )
        view.backgroundColor = .black

        layoutToolbar()
        view.layoutIfNeeded()

        let safeAreaTop = view.safeAreaInsets.top
        let toolbarHeight = toolbar.bounds.height
        let availableHeight = view.bounds.height - toolbarHeight - safeAreaTop
        let imageViewWidth = (availableHeight * image.size.width) / image.size.height
        let frame = CGRect(x: 0, y: 0, width: imageViewWidth, height: availableHeight)

        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.widthAnchor.constraint(equalToConstant: imageViewWidth),
            containerView.bottomAnchor.constraint(equalTo: toolbar.topAnchor),
        ])

        let imageView = UIImageView(frame: frame)
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        containerView.addSubview(imageView)
    }

    private func layoutToolbar() {
        let rectangleBarButtonItem = UIBarButtonItem(
            title: "rectangle", style: .plain, target: self, action: #selector(onClickBarButton(_:))
        )
        rectangleBarButtonItem.tag = 1

        toolbar.items = [rectangleBarButtonItem]
        view.addSubview(toolbar)

        toolbar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    @objc private func onClickBarButton(_ button: UIBarButtonItem) {
        let side: CGFloat = 100.0
        let rectangleView = RectangleView(frame: CGRect(x: 0, y: 0, width: side, height: side))
        containerView.addSubview(rectangleView)
        rectangleViews.append(rectangleView)
    }

    @objc private func rightBarButtonItemDidTap(_ button: UIBarButtonItem) {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        let newImage = renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: image.size))
            let ratio = image.size.width / containerView.frame.size.width

            for rectangleView in rectangleViews {
                var frame = rectangleView.rectangleRect()
                frame.origin.x *= ratio
                frame.origin.y *= ratio
                frame.size.width *= ratio
                frame.size.height *= ratio

                let layer = rectangleView.createShapeLayer()
                layer.path = UIBezierPath(rect: frame).cgPath
                layer.render(in: context.cgContext)
            }
        }

        let viewController = PostViewController(image: newImage)
        navigationController?.pushViewController(viewController, animated: true)
    }

    @objc private func leftBarButtonItemDidTap(_ button: UIBarButtonItem) {
        dismiss(animated: true)
    }
}
