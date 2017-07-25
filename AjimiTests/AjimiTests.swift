//
//  AjimiTests.swift
//  AjimiTests
//
//  Created by nakajijapan on 2017/07/19.
//  Copyright © 2017 nakajijapan. All rights reserved.
//

import XCTest
@testable import Ajimi

class AjimiTests: XCTestCase {
    func test64() {
        let string = "nakajijapan:nakaji"
        let authString = string.base64
        XCTAssertEqual(authString, "bmFrYWppamFwYW46bmFrYWpp")
    }
}
