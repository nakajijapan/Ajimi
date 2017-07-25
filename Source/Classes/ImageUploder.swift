//
//  ImageUploder.swift
//  Ajimi
//
//  Created by nakajijapan on 2017/07/16.
//  Copyright © 2017 nakajijapan. All rights reserved.
//

import Foundation
import UIKit

protocol ImageUploderProtocol: class {
    static func uploadImage(url: URL, key: String?, imageData: Data, completion: @escaping (Result<String>) -> Void)
}

class ImageUploder: ImageUploderProtocol {

    static func uploadImage(url: URL, key: String?, imageData: Data, completion: @escaping (Result<String>) -> Void) {

        let parameters = ["key" : key]
        let boundary = "----BOUNDARYBOUNDARY----"

        let body: Data
        do {
            body = try self.createBody(with: parameters, image: imageData, boundary: boundary)
        } catch {
            completion(Result.failure(ImageUploderError.RequestParseError()))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("\(body.count)", forHTTPHeaderField: "Content-Length")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("ios-ajimi/1.0", forHTTPHeaderField: "User-Agent")
        request.httpBody = body

        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if error != nil {
                completion(Result.failure(ImageUploderError.UploadError(error?.localizedDescription ?? "")))
                return
            }

            guard let data = data, let urlString = String(data: data, encoding: .utf8) else {
                completion(Result.failure(ImageUploderError.URLCreateError()))
                return
            }

            completion(Result.success(urlString))
        }
        task.resume()
    }

    private static func createBody(with parameters: [String: String?], image: Data, boundary: String) throws -> Data {
        var body = Data()
        parameters.forEach { key, value in
            guard let value = value else { return }
            body.append("--\(boundary)\r\n".data(using: String.Encoding.ascii, allowLossyConversion: false)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: String.Encoding.ascii, allowLossyConversion: false)!)
            body.append("\(value)\r\n".data(using: String.Encoding.ascii, allowLossyConversion: false)!)
        }
        body.append("--\(boundary)\r\n".data(using: String.Encoding.ascii, allowLossyConversion: false)!)
        body.append("Content-Disposition: form-data; name=\"imagedata\"; filename=\"gyazo.com\"\r\n\r\n".data(using: String.Encoding.ascii, allowLossyConversion: false)!)
        body.append(image)
        body.append("\r\n".data(using: String.Encoding.ascii, allowLossyConversion: false)!)
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.ascii, allowLossyConversion: false)!)
        return body
    }

}
