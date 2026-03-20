//
//  String+Ajimi.swift
//  Ajimi
//
//  Created by nakajijapan on 2017/07/16.
//  Copyright © 2017 nakajijapan. All rights reserved.
//

import Foundation

extension String {
    var base64: String {
        guard let data = data(using: .utf8) else { return "" }
        return data.base64EncodedString()
    }
}
