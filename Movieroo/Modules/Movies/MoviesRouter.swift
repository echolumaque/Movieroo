//
//  MoviesRouter.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/24/25.
//

import UIKit

typealias MoviesEntryPoint = MoviesView & UIViewController

protocol MoviesRouter {
    var view: MoviesEntryPoint? { get }
    static func start() -> MoviesRouter
    func showMovieDetail(for movie: MovieResult)
}

class MoviesRouterImpl: MoviesRouter {
    // Private strong reference to keep the view alive during assembly.
    private var moviesViewController: MoviesEntryPoint?
    
    // Publicly, we expose a weak reference.
    weak var view: (any MoviesEntryPoint)? {
        return moviesViewController
    }
    
    static func start() -> any MoviesRouter {
        let view = MoviesViewController()
        let interactor = MoviesInteractorImpl()
        let presenter = MoviesPresenterImpl()
        let router = MoviesRouterImpl()
        
        view.presenter = presenter
        
        interactor.presenter = presenter
        
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        
        router.moviesViewController = view
        return router
    }
    
    func showMovieDetail(for movie: MovieResult) {
        let movieDetail = MovieDetailRouterImpl.start(movieId: movie.id)
        let movieDetailView = movieDetail.view
        
        let movieDetailVC = UINavigationController(rootViewController: movieDetailView ?? UIViewController())
        moviesViewController?.present(movieDetailVC, animated: true)
    }
}
