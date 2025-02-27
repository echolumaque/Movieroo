//
//  MovieDetailPresenter.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/24/25.
//

import UIKit

protocol MovieDetailPresenter: AnyObject {
    var router: MovieDetailRouter? { get set }
    var interactor: MovieDetailInteractor? { get set }
    var view: MovieDetailView? { get set }
    var wrappedMovieDetail: WrappedMovieDetail? { get set }
    
    var page: Int { get set }
    var hasTriggeredLastVisible: Bool { get set }
    var movieRecommendations: [MovieResult] { get set }
    
    func fetchMovieDetails(for id: Int) async throws(NetworkingError)
    func fetchMovieRecommendations(for id: Int, page: Int) async throws(NetworkingError)
}

class MovieDetailPresenterImpl: MovieDetailPresenter {
    var router: (any MovieDetailRouter)?
    var interactor: (any MovieDetailInteractor)?
    weak var view: (any MovieDetailView)?
    var wrappedMovieDetail: WrappedMovieDetail?
    
    var page: Int = 1
    var hasTriggeredLastVisible: Bool = false
    var movieRecommendations: [MovieResult] = []
    
    func fetchMovieDetails(for id: Int) async throws(NetworkingError) {
        guard let interactor else {
            view?.updateMovieDetails(.failure(.otherError(message: "Interactor is nil")))
            wrappedMovieDetail = nil
            return
        }
        
        let wrappedMovieDetail = try await interactor.fetchMovieDetails(for: id)
        self.wrappedMovieDetail = wrappedMovieDetail
        movieRecommendations.append(contentsOf: wrappedMovieDetail.movieRecommendations)
        view?.updateMovieDetails(.success(wrappedMovieDetail))
    }
    
    func fetchMovieRecommendations(for id: Int, page: Int) async throws(NetworkingError) {
        let movieRecommendations = try await interactor?.fetchMovieRecommendations(for: id, page: page)
        let movieResults = movieRecommendations?.movieResults ?? []
        self.movieRecommendations.append(contentsOf: movieResults)
        if !movieResults.isEmpty {
            view?.updateRecommendationDataSource()
        }
    }
}
