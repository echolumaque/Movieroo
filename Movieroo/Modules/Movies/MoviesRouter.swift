//
//  MoviesRouter.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/24/25.
//

import UIKit
import Swinject

typealias MoviesEntryPoint = MoviesView & UIViewController

protocol MoviesRouter {
    var view: MoviesEntryPoint? { get }
    
    func showMovieDetail(for movie: MovieResult)
    func showGenreSheet()
}

class MoviesRouterImpl: MoviesRouter {
    let container: Resolver
    var moviesViewController: MoviesEntryPoint? // Private strong reference to keep the view alive during assembly.
    weak var view: (any MoviesEntryPoint)? { moviesViewController } // Publicly, we expose a weak reference.
    
    init(container: Resolver) {
        self.container = container
    }
    
    func showMovieDetail(for movie: MovieResult) {
        let movieDetail = container.resolve(MovieDetailRouter.self, argument: movie)?.view
        let movieDetailVC = UINavigationController(rootViewController: movieDetail ?? UIViewController())
        moviesViewController?.present(movieDetailVC, animated: true)
    }
    
    func showGenreSheet() {
        let selectGenreVC = SelectGenresSheet()
        selectGenreVC.delegate = moviesViewController?.presenter as? SelectGenresDelegate
        selectGenreVC.genreInfosDataSource = moviesViewController?.presenter as? SelectGenresDataSource
        let navVC = UINavigationController(rootViewController: selectGenreVC)
        navVC.isModalInPresentation = true // Prevent the interactive dismissal (by slidng down)
        if let sheet = navVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.preferredCornerRadius = 16
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        navVC.navigationBar.standardAppearance = appearance
        navVC.navigationBar.scrollEdgeAppearance = appearance
        
        moviesViewController?.present(navVC, animated: true)
        
    }
}
