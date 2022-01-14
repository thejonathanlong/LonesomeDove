//
//  AppDelegate.swift
//  LonesomeDove
//  Created on 10/19/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return AppLifeCycleManager.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return AppLifeCycleManager.shared.application(application, configurationForConnecting: connectingSceneSession, options: options)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        AppLifeCycleManager.shared.application(application, didDiscardSceneSessions: sceneSessions)
    }
}
