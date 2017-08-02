//
//  Ajimi.swift
//  Ajimi
//
//  Created by nakajijapan on 2017/07/11.
//  Copyright © 2017 nakajijapan. All rights reserved.
//

import UIKit

public struct AjimiOptions {
    public let imageUploadURL: URL
    public let imageUploadKey: String?
    public let github: GitHubOptions

    public init(githubBasePath: String, githubAccessToken: String, githubUser: String, githubRepo: String, imageUploadURL: URL, imageUploadKey: String?) {

        github = GitHubOptions(
            basePath: githubBasePath,
            accessToken: githubAccessToken,
            user: githubUser,
            repo: githubRepo
        )

        self.imageUploadURL = imageUploadURL
        self.imageUploadKey = imageUploadKey
    }

    public struct GitHubOptions {
        let basePath: String
        let accessToken: String
        let user: String
        let repo: String
    }

}

public class Ajimi: NSObject {

    fileprivate static var AssocKeyWindow: UInt8 = 0

    class var targetWindow: UIWindow {
        let windows = UIApplication.shared.windows.filter { !($0 is Window) }
        guard let window = windows.first else { fatalError("invalid window") }
        return window
    }

    class var window: Window {
        let windows = UIApplication.shared.windows.filter { $0 is Window }
        guard let window = windows.first as? Window else { fatalError("invalid window") }
        return window
    }

    public class func show(_ options: AjimiOptions) {
        let application = UIApplication.shared
        if objc_getAssociatedObject(application, &Ajimi.AssocKeyWindow) == nil {

            let window = Window(frame: UIScreen.main.bounds)
            window.options = options
            window.backgroundColor = UIColor.clear
            window.rootViewController = TopViewController(nibName: nil, bundle: nil)
            window.windowLevel = UIWindowLevelNormal + 20.0
            window.makeKeyAndVisible()

            objc_setAssociatedObject(
                application,
                &Ajimi.AssocKeyWindow,
                window,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    public class func hide() {
        let application = UIApplication.shared
        if let window = objc_getAssociatedObject(application, &Ajimi.AssocKeyWindow) as? UIWindow {
            window.rootViewController!.view.removeFromSuperview()
            window.rootViewController = nil

            objc_setAssociatedObject(
                application,
                &Ajimi.AssocKeyWindow,
                nil,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
}
