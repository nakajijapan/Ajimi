//
//  ImageEditViewController.swift
//  Ajimi
//
//  Created by nakajijapan on 2017/07/11.
//  Copyright © 2017 nakajijapan. All rights reserved.
//

import UIKit

class ImageEditViewController: UIViewController {

    let image: UIImage
    let containerView = UIView(frame: .zero)

    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Ajimi"

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(rightBarButtonItemDidTap(_:)))
        navigationItem.leftBarButtonItem  = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(leftBarButtonItemDidTap(_:)))
        view.backgroundColor = .black

        layoutToolbar()
        view.layoutIfNeeded()

        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        let navigationBarHeight = navigationController?.navigationBar.bounds.height ?? 0.0
        let imageViewHeight = view.bounds.height - toolbar.bounds.height - navigationBarHeight - statusBarHeight
        let imageViewWidth = (imageViewHeight * image.size.width) / image.size.height
        let frame = CGRect(x: 0, y: 0, width: imageViewWidth, height: imageViewHeight)
        view.addSubview(containerView)

        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 64).isActive = true
        containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        containerView.widthAnchor.constraint(equalToConstant: imageViewWidth).isActive = true
        containerView.bottomAnchor.constraint(equalTo: toolbar.topAnchor).isActive = true

        let imageView = UIImageView(frame: frame)
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        containerView.addSubview(imageView)
    }

    let toolbar = UIToolbar(frame: .zero)

    func layoutToolbar() {
        let rectangleBarButtonItem: UIBarButtonItem = UIBarButtonItem(title: "rectangle", style: .plain, target: self, action: #selector(onClickBarButton(_:)))
        rectangleBarButtonItem.tag = 1

        toolbar.items = [rectangleBarButtonItem]
        view.addSubview(toolbar)

        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        toolbar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        toolbar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }

    func onClickBarButton(_ button: UIBarButtonItem) {
        let side = 100.0
        let rectangleView = RectangleView(frame: CGRect(x: 0.0, y: 0.0, width: side, height: side))
        containerView.addSubview(rectangleView)
        rectangleViews.append(rectangleView)
    }

    var rectangleViews: [RectangleView] = []

    func rightBarButtonItemDidTap(_ button: UIBarButtonItem) {

        UIGraphicsBeginImageContext(image.size)
        guard let context = UIGraphicsGetCurrentContext() else { return }

        image.draw(in: CGRect(origin: .zero, size: image.size))
        let ratio = (image.size.width /  containerView.frame.size.width)

        rectangleViews.forEach { rectangleView in
            var frame = rectangleView.rectangleRect()
            frame.origin.x *= ratio
            frame.origin.y *= ratio
            frame.size.width *= ratio
            frame.size.height *= ratio

            let layer = rectangleView.createShapeLayer()
            layer.path = UIBezierPath(rect: frame).cgPath
            layer.render(in: context)
        }

        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        let viewController = PostViewController(image: newImage)
        navigationController?.pushViewController(viewController, animated: true)

    }

    func leftBarButtonItemDidTap(_ button: UIBarButtonItem) {
        dismiss(animated: true) { }
    }

}
