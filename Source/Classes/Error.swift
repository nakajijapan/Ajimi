//
//  Error.swift
//  Ajimi
//
//  Created by nakajijapan on 2017/07/16.
//  Copyright © 2017 nakajijapan. All rights reserved.
//

import Foundation

enum Result<T> {
    case success(T)
    case failure(Error)
}

enum ReporterError: Error {
    case NetworkError(String)
    case GitHubSaveError(String)
}

enum ImageUploderError: Error {
    case RequestParseError()
    case UploadError(String)
    case URLCreateError()
}
