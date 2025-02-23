//
//  SceneDelegate.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/23/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
//        let mainTabRouter = MainTabRouterImpl.start()
//        let initialVC = mainTabRouter.entry
//        let window = UIWindow(windowScene: windowScene)
//        window.rootViewController = initialVC
//        self.window = window
//        window.makeKeyAndVisible()
        
        let router = MainTabRouterImpl.start()
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.rootViewController = router.view
        window?.makeKeyAndVisible()
    }
}
