//
//  String+.swift
//  Ajimi
//
//  Created by nakajijapan on 2017/07/16.
//  Copyright © 2017 nakajijapan. All rights reserved.
//

import Foundation

extension String {
    var base64: String {
        let userPasswordData = data(using: String.Encoding.utf8)
        let base64EncodedCredential = userPasswordData?.base64EncodedString()
        return base64EncodedCredential!
    }
}
