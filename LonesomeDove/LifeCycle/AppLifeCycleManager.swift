//
//  AppLifeCycleManager.swift
//  LonesomeDove
//  Created on 10/22/21.
//

import UIKit
import SwiftUI
import SwiftUIFoundation
import os

class AppLifeCycleManager {

    static let shared = AppLifeCycleManager()

    var window: UIWindow?

    lazy var state = AppState(dataStoreDelegate: self)

    var store: AppStore?

    var router: RouteController

    var logger = Logger(subsystem: "com.LonesomeDove", category: "LonesomeDove")

    init(router: RouteController = Router.shared) {
        self.router = router
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        store = AppStore(initialState: state,
                                  reducer: appReducer,
                                  middlewares: [
                                    dataStoreMiddleware(service: state.dataStore),
                                    mediaMiddleware(),
                                    loggingMiddleware(service: logger)
                                  ])
        logger.log(level: .debug, "Application directory: \(NSHomeDirectory())")

        store?.dispatch(.sticker(.fetchStickers))

        return true
    }
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) { }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        if let store = store {
            window = UIWindow(windowScene: windowScene)
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.darkBackground
            let storyCardListView = StoryCardListView(viewModel: StoryCardListViewModel(store: store))
            let rootViewController = HostedViewController(contentView: storyCardListView.environmentObject(store), backgroundView: backgroundView)
            window?.rootViewController = rootViewController
            router.rootViewController = rootViewController
            window?.makeKeyAndVisible()
            store.dispatch(.recording(.requestMicrophoneAccess))
        } else {
            // If for some reason we don't have a store, then create one and start over.
            store = AppStore(initialState: state, reducer: appReducer, middlewares: [dataStoreMiddleware(service: state.dataStore)])
            self.scene(scene, willConnectTo: session, options: connectionOptions)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) { }

    func sceneDidBecomeActive(_ scene: UIScene) { }

    func sceneWillResignActive(_ scene: UIScene) {
        // Save changes in the application's managed object context when the application transitions to the background.
        store?.dispatch(.dataStore(.save))
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        store?.dispatch(.storyCard(.updateStoryList))
    }

    func sceneDidEnterBackground(_ scene: UIScene) { }
}

extension AppLifeCycleManager: DataStoreDelegate {

    func failed(with error: Error) {
        store?.dispatch(.failure(error))
    }
}
