//
//  MainTabRouter.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/24/25.
//

import UIKit

typealias MainTabEntryPoint = MainTabView & UITabBarController

protocol MainTabRouter {
    var view: MainTabEntryPoint? { get }
    static func start() -> MainTabRouter
}

class MainTabRouterImpl: MainTabRouter {
    weak var view: (any MainTabEntryPoint)?
    
    // Store child coordinators to manage their lifecycle. (Refer to bookmarks as this is using MVVM-C rather tha VIPER)
    private var childCoordinators: [Coordinator] = []

    
    static func start() -> MainTabRouter {
        let view = MainTabViewController()
        let interactor = MainTabInteractorImpl()
        let presenter = MainTabPresenterImpl()
        let router = MainTabRouterImpl()
        
        view.presenter = presenter
        view.viewControllers = [createMoviesVC(), createBookmarksVC(router: router)]
        
        interactor.presenter = presenter
        
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        
        router.view = view
        return router
    }
    
    private static func createMoviesVC() -> UINavigationController {
        let moviesModule = MoviesRouterImpl.start()
        let moviesVC = moviesModule.view
        moviesVC?.tabBarItem = UITabBarItem(title: "Movies", image: UIImage(systemName: "popcorn.fill"), tag: 0)
        moviesVC?.navigationItem.title = "Movieroo"
        
        return UINavigationController(rootViewController: moviesVC ?? UIViewController())
    }
    
    private static func createBookmarksVC(router: MainTabRouterImpl) -> UINavigationController {
        let persistenceManagerClass = PersistenceManagerClass()
        let bookmarksCoordinator = BookmarksCoordinator(persistenceManagerClass: persistenceManagerClass)
        
        bookmarksCoordinator.onFinished = {
            guard let coordinatorIndex = router.childCoordinators.firstIndex(where: { $0 === bookmarksCoordinator }) else { return }
            
            router.childCoordinators.remove(at: coordinatorIndex)
            print("removed in the children")
        }
        router.childCoordinators.append(bookmarksCoordinator)
        bookmarksCoordinator.start()
        
        return bookmarksCoordinator.rootViewController
    }
}
