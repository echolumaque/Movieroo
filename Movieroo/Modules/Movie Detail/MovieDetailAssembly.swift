//
//  MovieDetailAssembly.swift
//  Movieroo
//
//  Created by Echo Lumaque on 3/11/25.
//

import Foundation
import Swinject

class MovieDetailAssembly: Assembly {
    func assemble(container: Container) {
        container.register(MovieDetailRouter.self) { (resolver, movie: MovieResult) in
            let view = MovieDetailViewController(movie: movie, container: resolver)
            let router = MovieDetailRouterImpl()
            let interactor = MovieDetailInteractorImpl(networkManager: resolver.resolve(NetworkManager.self)!)
            let presenter = MovieDetailPresenterImpl()
            
            view.presenter = presenter
            
            interactor.presenter = presenter
            
            presenter.view = view
            presenter.interactor = interactor
            presenter.router = router
            
            router.movieDetailViewController = view
            return router
        }
    }
}
