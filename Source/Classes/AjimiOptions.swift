//
//  AjimiOptions.swift
//  Ajimi
//
//  Created by nakajijapan on 2017/07/11.
//  Copyright © 2017 nakajijapan. All rights reserved.
//

import Foundation

public struct AjimiOptions: Sendable {
    public let imageUploadURL: URL
    public let imageUploadKey: String?
    public let github: GitHubOptions

    public init(
        githubBasePath: String,
        githubAccessToken: String,
        githubUser: String,
        githubRepo: String,
        imageUploadURL: URL,
        imageUploadKey: String?
    ) {
        github = GitHubOptions(
            basePath: githubBasePath,
            accessToken: githubAccessToken,
            user: githubUser,
            repo: githubRepo
        )
        self.imageUploadURL = imageUploadURL
        self.imageUploadKey = imageUploadKey
    }

    public struct GitHubOptions: Sendable {
        public let basePath: String
        public let accessToken: String
        public let user: String
        public let repo: String
    }
}
