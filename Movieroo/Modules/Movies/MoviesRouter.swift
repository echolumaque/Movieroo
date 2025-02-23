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
}

class MoviesRouterImpl: MoviesRouter {
    // Private strong reference to keep the view alive during assembly.
    private var moviesViewController: MoviesEntryPoint?
    
    // Publicly, we expose a weak reference.
    weak var view: (any MoviesEntryPoint)? {
        return moviesViewController
    }
    
    static func start() -> any MoviesRouter {
        let router = MoviesRouterImpl()
        let view = MoviesViewController()
        let presenter = MoviesPresenterImpl()
        let interactor = MoviesInteractorImpl()
        
        router.moviesViewController = view
        
        view.presenter = presenter
        
        interactor.presenter = presenter
        
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        return router
    }
}
