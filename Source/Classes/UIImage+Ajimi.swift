//
//  UIImage+Ajimi.swift
//  Ajimi
//
//  Created by nakajijapan on 2017/07/23.
//  Copyright © 2017 nakajijapan. All rights reserved.
//

import UIKit

extension UIImage {
    func resize(size specifiedSize: CGSize) -> UIImage? {
        let widthRatio = specifiedSize.width / size.width
        let heightRatio = specifiedSize.height / size.height
        let ratio = widthRatio < heightRatio ? widthRatio : heightRatio

        let resizedSize = CGSize(width: size.width * ratio, height: size.height * ratio)

        UIGraphicsBeginImageContextWithOptions(resizedSize, false, 0.0)
        draw(in: CGRect(origin: .zero, size: resizedSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return resizedImage
    }
}
