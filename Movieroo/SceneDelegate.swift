//
//  SceneDelegate.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/23/25.
//

import UIKit
import Swinject

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let container = Container()
        _ = Assembler(
            [
                ServicesAssembly(),
                MainTabAssembly(),
                MoviesAssembly(),
                MovieDetailAssembly()
            ],
            container: container)
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.rootViewController = container.resolve(MainTabRouter.self)?.view
        window?.makeKeyAndVisible()
        
        UINavigationBar.appearance().tintColor = .systemPurple
    }
}


