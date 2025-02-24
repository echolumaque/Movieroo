//
//  MovieDetailRouter.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/24/25.
//

import UIKit

typealias MovieDetailEntryPoint = MovieDetailView & UIViewController

protocol MovieDetailRouter {
    var view: MovieDetailEntryPoint? { get }
    static func start(movieId: Int) -> MovieDetailRouter
}

class MovieDetailRouterImpl: MovieDetailRouter {
    private var movieDetailViewController: MovieDetailEntryPoint?
    
    weak var view: (any MovieDetailEntryPoint)? {
        return movieDetailViewController
    }
    
    static func start(movieId: Int) -> any MovieDetailRouter {
        let view = MovieDetailViewController(movieId: movieId)
        let interactor = MovieDetailInteractorImpl()
        let presenter = MovieDetailPresenterImpl()
        let router = MovieDetailRouterImpl()
        
        view.presenter = presenter
        
        interactor.presenter = presenter
        
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        
        router.movieDetailViewController = view
        return router
    }
}
