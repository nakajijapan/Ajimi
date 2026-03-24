//
//  ImageUploader.swift
//  Ajimi
//
//  Created by nakajijapan on 2017/07/16.
//  Copyright © 2017 nakajijapan. All rights reserved.
//

import Foundation
import UIKit
import AjimiCore

protocol ImageUploaderProtocol: AnyObject {
    static func uploadImage(url: URL, key: String?, imageData: Data) async throws -> String
}

final class ImageUploader: ImageUploaderProtocol {

    static func uploadImage(url: URL, key: String?, imageData: Data) async throws -> String {
        let boundary = "----BOUNDARYBOUNDARY----"

        let body: Data
        do {
            body = try createBody(with: ["key": key], image: imageData, boundary: boundary)
        } catch {
            throw ImageUploaderError.requestParseError
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("\(body.count)", forHTTPHeaderField: "Content-Length")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("ios-ajimi/1.0", forHTTPHeaderField: "User-Agent")
        request.httpBody = body

        let (data, _) = try await URLSession.shared.data(for: request)

        guard let urlString = String(data: data, encoding: .utf8) else {
            throw ImageUploaderError.urlCreateError
        }

        return urlString
    }

    private static func createBody(with parameters: [String: String?], image: Data, boundary: String) throws -> Data {
        var body = Data()

        for (key, value) in parameters {
            guard let value else { continue }
            body.append(Data("--\(boundary)\r\n".utf8))
            body.append(Data("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".utf8))
            body.append(Data("\(value)\r\n".utf8))
        }

        body.append(Data("--\(boundary)\r\n".utf8))
        body.append(Data("Content-Disposition: form-data; name=\"imagedata\"; filename=\"gyazo.com\"\r\n\r\n".utf8))
        body.append(image)
        body.append(Data("\r\n".utf8))
        body.append(Data("--\(boundary)--\r\n".utf8))

        return body
    }
}
