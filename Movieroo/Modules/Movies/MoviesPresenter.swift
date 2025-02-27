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
    
    var movieResults: [MovieResult] { get set }
    
    func fetchTrendingMovies(page: Int) async
    func didFetchedMovies(result: Result<Movie, NetworkingError>)
    func showMovieDetail(for movie: MovieResult)
}

class MoviesPresenterImpl: MoviesPresenter {
    var router: (any MoviesRouter)?
    var interactor: MoviesInteractor?
    weak var view: (any MoviesView)?
    var movieResults: [MovieResult] = []
    
    func fetchTrendingMovies(page: Int) async {
        await interactor?.getTrendingMovies(page: page)
    }
    
    func didFetchedMovies(result: Result<Movie, NetworkingError>) {
        switch result {
        case .success(let movie): movieResults.append(contentsOf: movie.movieResults)
        case .failure(_): break
        }
        
        view?.updateUI()
    }
    
    func showMovieDetail(for movie: MovieResult) {
        router?.showMovieDetail(for: movie)
    }
}
