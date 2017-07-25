//
//  AppDelegate.swift
//  Example
//
//  Created by nakajijapan on 2017/07/19.
//  Copyright © 2017 nakajijapan. All rights reserved.
//

import UIKit
import Ajimi

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?

    #if DEBUG
    let ajimiOptions = AjimiOptions(
        githubBasePath: "https://hostname/api/v3",
        githubAccessToken: "githubAccessToken",
        githubUser: "userName",
        githubRepo: "repositoryName",
        imageUploadURL: URL(string: "https://hostname/image/upload")!,
        imageUploadKey: "imageUploadKey"
    )
    #endif

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        guard let window = window, let splitViewController = window.rootViewController as? UISplitViewController else {
            return false
        }

        guard let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as? UINavigationController else {
            return false
        }
        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        splitViewController.delegate = self

        #if DEBUG
            Ajimi.show(ajimiOptions)
        #endif

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }

    // MARK: - Split view

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController else { return false }
        if topAsDetailController.detailItem == nil {
            return true
        }
        return false
    }

}
