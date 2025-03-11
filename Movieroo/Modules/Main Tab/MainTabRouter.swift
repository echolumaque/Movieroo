//
//  MainTabRouter.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/24/25.
//

import UIKit
import Swinject

typealias MainTabEntryPoint = MainTabView & UITabBarController

protocol MainTabRouter {
    var view: MainTabEntryPoint? { get }
}

class MainTabRouterImpl: MainTabRouter {
    weak var view: (any MainTabEntryPoint)?
    
    // Store child coordinators to manage their lifecycle. (Refer to bookmarks as this is using MVVM-C rather tha VIPER)
    private var childCoordinators: [Coordinator] = []
    
    func createMoviesVC(container: Resolver) -> UINavigationController {
        let moviesVC = container.resolve(MoviesRouter.self)?.view
        return UINavigationController(rootViewController: moviesVC ?? UIViewController())
    }
    
    func createBookmarksVC(router: MainTabRouterImpl, container: Resolver) -> UINavigationController {
        guard let networkManager = container.resolve(NetworkManager.self),
              let persistenceManager = container.resolve(PersistenceManager.self) else { return UINavigationController() }
        
        let bookmarksCoordinator = BookmarksCoordinator(
            networkManager: networkManager,
            persistenceManager: persistenceManager
        )
        
        bookmarksCoordinator.onFinished = { 
            guard let coordinatorIndex = router.childCoordinators.firstIndex(where: { $0 === bookmarksCoordinator }) else { return }
            router.childCoordinators.remove(at: coordinatorIndex)
        }
        router.childCoordinators.append(bookmarksCoordinator)
        bookmarksCoordinator.start()
        
        return bookmarksCoordinator.rootViewController
    }
}
