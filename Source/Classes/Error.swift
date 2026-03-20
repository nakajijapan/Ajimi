//
//  Error.swift
//  Ajimi
//
//  Created by nakajijapan on 2017/07/16.
//  Copyright © 2017 nakajijapan. All rights reserved.
//

import Foundation

enum ReporterError: LocalizedError {
    case networkError(String)
    case gitHubSaveError(String)

    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network error: \(message)"
        case .gitHubSaveError(let message):
            return "GitHub save error: \(message)"
        }
    }
}

enum ImageUploaderError: LocalizedError {
    case requestParseError
    case uploadError(String)
    case urlCreateError

    var errorDescription: String? {
        switch self {
        case .requestParseError:
            return "Failed to parse upload request"
        case .uploadError(let message):
            return "Upload error: \(message)"
        case .urlCreateError:
            return "Failed to create URL from response"
        }
    }
}
