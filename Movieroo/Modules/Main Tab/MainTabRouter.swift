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
    
    static func start() -> MainTabRouter {
        let router = MainTabRouterImpl()
        let view = MainTabViewController()
        let presenter = MainTabPresenterImpl()
        let interactor = MainTabInteractorImpl()
        
        view.presenter = presenter
        view.viewControllers = [createMoviesVC(), createBookmarksVC()]
        
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
        
        return UINavigationController(rootViewController: moviesVC ?? UIViewController())
    }
    
    private static func createBookmarksVC() -> UINavigationController{
        let bookmarksVC = BookmarksViewController()
        bookmarksVC.tabBarItem = UITabBarItem(title: "Bookmarks", image: UIImage(systemName: "bookmark.fill"), tag: 1)
        
        return UINavigationController(rootViewController: bookmarksVC)
    }
}
