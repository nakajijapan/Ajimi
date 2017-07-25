//
//  Reporter.swift
//  Ajimi
//
//  Created by nakajijapan on 2017/07/15.
//  Copyright © 2017 nakajijapan. All rights reserved.
//

import Foundation

class Reporter {

    private let options: AjimiOptions
    public init(options: AjimiOptions) {
        self.options = options
    }

    internal func submit(title: String, body: String, screenshotData: Data, completion: @escaping (Result<Bool>) -> Void) {
        ImageUploder.uploadImage(url: options.imageUploadURL, key: options.imageUploadKey, imageData: screenshotData) { result in
            switch result {
            case .success(let imageUrlString):
                var issueBody = "\(body) \n\n ![image](\(imageUrlString)) \n\n ----\n"
                Device.all.forEach { key, value in issueBody += "\(key): \(value)\n" }
                self.createIssue(issueTitle: title, issueBody: issueBody, screenshotURL: nil, completion: completion)
            case .failure(let error):
                completion(Result.failure(error))
            }
        }
    }

    private func createIssue(issueTitle: String, issueBody: String, screenshotURL: String?, completion: @escaping (Result<Bool>) -> Void) {
        let payload: [String:Any] = ["title": "Ajimi: " + issueTitle, "body": issueBody]
        var jsonSerializationData: Data?

        do {
            jsonSerializationData = try JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted)
        } catch let error as NSError {
            completion(Result.failure(error))
        }

        guard let jsonData = jsonSerializationData else { return }
        guard var request = createRequest() else { return }

        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { (_, response, error) in
            guard let response = response as? HTTPURLResponse else {
                return
            }

            if error != nil {
                DispatchQueue.main.sync {
                    completion(Result.failure(ReporterError.NetworkError(error.debugDescription)))
                }
                return
            }

            if response.statusCode != 201 {
                DispatchQueue.main.sync {
                    completion(Result.failure(ReporterError.GitHubSaveError("repo \(self.options.github.repo).")))
                }
                return
            }

            completion(Result.success(true))
        }
        task.resume()

    }

    // https://developer.github.com/v3/issues/#create-an-issue
    private func createRequest() -> URLRequest? {
        let basePath = options.github.basePath
        let repo = options.github.repo
        let user = options.github.user
        let token = options.github.accessToken

        let url = URL(string: "\(basePath)/repos/\(user)/\(repo)/issues")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let planeText = "\(user):\(token)"
        let basicAuth = "Basic \(planeText.base64)"

        request.setValue(basicAuth, forHTTPHeaderField: "Authorization")
        return request
    }

}
