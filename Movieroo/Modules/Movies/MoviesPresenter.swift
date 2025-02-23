//
//  MoviesPresenter.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/24/25.
//

import Foundation

protocol MoviesPresenter: AnyObject {
    var router: MoviesRouter? { get set }
    var interactor: MoviesInteractor? { get set }
    var view: MoviesView? { get set }
    
    func fetchTrendingMovies() async
    func didFetchedMovies(result: Result<Movie, NetworkingError>)
}

class MoviesPresenterImpl: MoviesPresenter {
    var router: (any MoviesRouter)?
    var interactor: MoviesInteractor?
    weak var view: (any MoviesView)?
    
    func fetchTrendingMovies() async {
        await interactor?.getTrendingMovies()
    }
    
    func didFetchedMovies(result: Result<Movie, NetworkingError>) {
        switch result {
        case .success(let movie):
            view?.update(movie: movie)
            
        case .failure(let error):
            view?.update(error: error)
        }
    }
}
