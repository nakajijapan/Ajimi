//
//  AjimiCoreTests.swift
//  AjimiCoreTests
//
//  Created by nakajijapan on 2017/07/19.
//  Copyright © 2017 nakajijapan. All rights reserved.
//

import XCTest
@testable import AjimiCore

final class AjimiCoreTests: XCTestCase {

    func testBase64Encoding() {
        let string = "nakajijapan:nakaji"
        let authString = string.base64
        XCTAssertEqual(authString, "bmFrYWppamFwYW46bmFrYWpp")
    }

    func testBase64EmptyString() {
        let string = ""
        let authString = string.base64
        XCTAssertEqual(authString, "")
    }

    func testBase64SpecialCharacters() {
        let string = "user:p@$$w0rd!"
        let authString = string.base64
        let decoded = Data(base64Encoded: authString).flatMap { String(data: $0, encoding: .utf8) }
        XCTAssertEqual(decoded, string)
    }

    func testAjimiOptionsInitialization() {
        let options = AjimiOptions(
            githubBasePath: "https://api.github.com",
            githubAccessToken: "test-token",
            githubUser: "testuser",
            githubRepo: "testrepo",
            imageUploadURL: URL(string: "https://example.com/upload")!,
            imageUploadKey: "test-key"
        )

        XCTAssertEqual(options.github.basePath, "https://api.github.com")
        XCTAssertEqual(options.github.accessToken, "test-token")
        XCTAssertEqual(options.github.user, "testuser")
        XCTAssertEqual(options.github.repo, "testrepo")
        XCTAssertEqual(options.imageUploadURL.absoluteString, "https://example.com/upload")
        XCTAssertEqual(options.imageUploadKey, "test-key")
    }

    func testAjimiOptionsWithNilKey() {
        let options = AjimiOptions(
            githubBasePath: "https://api.github.com",
            githubAccessToken: "token",
            githubUser: "user",
            githubRepo: "repo",
            imageUploadURL: URL(string: "https://example.com/upload")!,
            imageUploadKey: nil
        )

        XCTAssertNil(options.imageUploadKey)
    }
}
