//
//  SceneDelegate.swift
//  LonesomeDove
//  Created on 10/19/21.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        AppLifeCycleManager.shared.scene(scene, willConnectTo: session, options: connectionOptions)
        window = AppLifeCycleManager.shared.window
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        AppLifeCycleManager.shared.sceneDidDisconnect(scene)
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        AppLifeCycleManager.shared.sceneDidBecomeActive(scene)
    }

    func sceneWillResignActive(_ scene: UIScene) {
        AppLifeCycleManager.shared.sceneWillResignActive(scene)
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        AppLifeCycleManager.shared.sceneWillEnterForeground(scene)
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        AppLifeCycleManager.shared.sceneDidEnterBackground(scene)
    }

}
