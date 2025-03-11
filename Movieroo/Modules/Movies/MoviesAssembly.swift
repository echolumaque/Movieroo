//
//  MoviesAssembly.swift
//  Movieroo
//
//  Created by Echo Lumaque on 3/11/25.
//

import Foundation
import Swinject

class MoviesAssembly: Assembly {
    func assemble(container: Container) {
        container.register(MoviesRouter.self) { resolver in
            let view = MoviesViewController(container: resolver)
            let router = MoviesRouterImpl(container: resolver)
            let interactor = MoviesInteractorImpl(networkManager: resolver.resolve(NetworkManager.self)!)
            let presenter = MoviesPresenterImpl()
            
            view.tabBarItem = UITabBarItem(title: "Movies", image: UIImage(systemName: "popcorn.fill"), tag: 0)
            view.navigationItem.title = "Movieroo"
            view.presenter = presenter

            interactor.presenter = presenter
            
            presenter.view = view
            presenter.interactor = interactor
            presenter.router = router
            
            router.moviesViewController = view
            return router
        }
    }
}
