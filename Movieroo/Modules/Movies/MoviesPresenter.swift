//
//  MoviesPresenter.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/24/25.
//

import UIKit

protocol MoviesPresenter: AnyObject {
    var router: MoviesRouter? { get set }
    var interactor: MoviesInteractor? { get set }
    var view: MoviesView? { get set }
    
    var page: Int { get set }
    var hasTriggeredSecondToLastVisible: Bool { get set }
    var movieResults: [MovieResult] { get set }
    var filteredMovieResults: [MovieResult] { get set }
    var genreInfos: [GenreToggle] { get set }
    
    func fetchTrendingMovies(page: Int) async
    func didFetchedMovies(result: Result<Movie, NetworkingError>)
    func showMovieDetail(for movie: MovieResult)
    
    func showGenreSheet()
}

class MoviesPresenterImpl: MoviesPresenter, SelectGenresDelegate, SelectGenresDataSource {
    var router: (any MoviesRouter)?
    var interactor: MoviesInteractor?
    weak var view: (any MoviesView)?
    
    var page: Int = 1
    var hasTriggeredSecondToLastVisible: Bool = false
    var movieResults: [MovieResult] = []
    var filteredMovieResults: [MovieResult] = []
    var filteredMovieResultsByGenre: [MovieResult] = []
    
    var genreInfos: [GenreToggle] = [
        GenreToggle(id: 28, name: "Action", isEnabled: true),
        GenreToggle(id: 12, name: "Adventure", isEnabled: true),
        GenreToggle(id: 16, name: "Animation", isEnabled: true),
        GenreToggle(id: 35, name: "Comedy", isEnabled: true),
        GenreToggle(id: 80, name: "Crime", isEnabled: true),
        GenreToggle(id: 99, name: "Documentary", isEnabled: true),
        GenreToggle(id: 18, name: "Drama", isEnabled: true),
        GenreToggle(id: 10751, name: "Family", isEnabled: true),
        GenreToggle(id: 14, name: "Fantasy", isEnabled: true),
        GenreToggle(id: 36, name: "History", isEnabled: true),
        GenreToggle(id: 27, name: "Horror", isEnabled: true),
        GenreToggle(id: 10402, name: "Music", isEnabled: true),
        GenreToggle(id: 9648, name: "Mystery", isEnabled: true),
        GenreToggle(id: 10749, name: "Romance", isEnabled: true),
        GenreToggle(id: 878, name: "Science Fiction", isEnabled: true),
        GenreToggle(id: 10770, name: "TV Movie", isEnabled: true),
        GenreToggle(id: 53, name: "Thriller", isEnabled: true),
        GenreToggle(id: 10752, name: "War", isEnabled: true),
        GenreToggle(id: 37, name: "Western", isEnabled: true),
    ]
    
    func fetchTrendingMovies(page: Int) async {
        await interactor?.getTrendingMovies(page: page)
    }
    
    func didFetchedMovies(result: Result<Movie, NetworkingError>) {
        switch result {
        case .success(let movie): movieResults.append(contentsOf: movie.movieResults)
        case .failure(_): break
        }
        
        view?.updateDataSource(movieResult: movieResults)
    }
    
    func showMovieDetail(for movie: MovieResult) {
        router?.showMovieDetail(for: movie)
    }
    
    func showGenreSheet() {
        router?.showGenreSheet()
    }
    //action science fiction adventure
    func onGenreSelected(genreInfo: (genre: GenreToggle, isEnabled: Bool)) {
        let resultsToUse = (view?.isSearching ?? false) ? filteredMovieResults : movieResults
        let enabledGenreIDs = genreInfos.filter { $0.isEnabled }.map { $0.id }
        let moviesToUse = resultsToUse.filter { movie in
            movie.genreIDS.contains { enabledGenreIDs.contains($0) }
        }
        
        view?.updateDataSource(movieResult: moviesToUse)
    }
}
