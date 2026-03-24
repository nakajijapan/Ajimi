//
//  Reporter.swift
//  Ajimi
//
//  Created by nakajijapan on 2017/07/15.
//  Copyright © 2017 nakajijapan. All rights reserved.
//

import Foundation
import AjimiCore

final class Reporter {

    private let options: AjimiOptions

    init(options: AjimiOptions) {
        self.options = options
    }

    func submit(title: String, body: String, screenshotData: Data) async throws {
        let imageUrlString = try await ImageUploader.uploadImage(
            url: options.imageUploadURL,
            key: options.imageUploadKey,
            imageData: screenshotData
        )

        var issueBody = "\(body) \n\n ![image](\(imageUrlString)) \n\n ----\n"
        for (key, value) in Device.all {
            issueBody += "\(key): \(value)\n"
        }

        try await createIssue(issueTitle: title, issueBody: issueBody)
    }

    private func createIssue(issueTitle: String, issueBody: String) async throws {
        let payload: [String: Any] = ["title": "Ajimi: " + issueTitle, "body": issueBody]
        let jsonData = try JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted)

        var request = createRequest()
        request.httpBody = jsonData

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ReporterError.networkError("Invalid response")
        }

        guard httpResponse.statusCode == 201 else {
            throw ReporterError.gitHubSaveError("repo \(options.github.repo). Status: \(httpResponse.statusCode)")
        }
    }

    // https://developer.github.com/v3/issues/#create-an-issue
    private func createRequest() -> URLRequest {
        let basePath = options.github.basePath
        let repo = options.github.repo
        let user = options.github.user
        let token = options.github.accessToken

        let url = URL(string: "\(basePath)/repos/\(user)/\(repo)/issues")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let plainText = "\(user):\(token)"
        let basicAuth = "Basic \(plainText.base64)"
        request.setValue(basicAuth, forHTTPHeaderField: "Authorization")

        return request
    }
}
