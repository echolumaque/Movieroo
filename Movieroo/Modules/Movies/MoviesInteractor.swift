//
//  MoviesInteractor.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/24/25.
//

import Foundation

protocol MoviesInteractor: AnyObject {
    var presenter: MoviesPresenter? { get set }
    func getTrendingMovies(page: Int) async
}

class MoviesInteractorImpl: MoviesInteractor {
    weak var presenter: (any MoviesPresenter)?
    
    func getTrendingMovies(page: Int) async {
        guard page > 0, page <= 500 else { return }
        do {
            let constructedUrl = "https://api.themoviedb.org/3/discover/movie?include_adult=false&include_video=false&language=en-US&page=\(page)&sort_by=vote_count.desc&vote_average.gte=8&vote_count.gte=100"
            let fetchedMovie: Movie = try await NetworkManager.shared.baseNetworkCall(for: constructedUrl)
            presenter?.didFetchedMovies(result: .success(fetchedMovie))
        } catch {
            presenter?.didFetchedMovies(result: .failure(error))
        }
    }
}
//500
