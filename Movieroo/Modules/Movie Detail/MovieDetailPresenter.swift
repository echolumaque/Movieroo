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
    
    var recommendationsPage: Int { get set }
    var hasTriggeredLastVisible: Bool { get set }
    var movieRecommendations: [MovieResult] { get set }
    
    var reviewsPage: Int { get set }
    var movieReviews: [Review] { get set }
    
    func fetchMovieDetails(for id: Int) async throws(NetworkingError)
    func fetchMovieRecommendations(for id: Int) async throws(NetworkingError)
    func fetchMovieReviews(for id: Int) async throws(NetworkingError)
    
    func upsertFavoriteMovie(movie: MovieResult, persistenceManager: PersistenceManager?)
}

class MovieDetailPresenterImpl: MovieDetailPresenter {
    var router: (any MovieDetailRouter)?
    var interactor: (any MovieDetailInteractor)?
    weak var view: (any MovieDetailView)?
    var wrappedMovieDetail: WrappedMovieDetail?
    
    var recommendationsPage: Int = 1
    var hasTriggeredLastVisible: Bool = false
    var movieRecommendations: [MovieResult] = []
    
    var reviewsPage: Int = 1
    var movieReviews: [Review] = []
    
    func fetchMovieDetails(for id: Int) async throws(NetworkingError) {
        guard let interactor else {
            view?.updateMovieDetails(.failure(.otherError(message: "Interactor is nil")))
            wrappedMovieDetail = nil
            return
        }
        
        let wrappedMovieDetail = try await interactor.fetchMovieDetails(for: id)
        self.wrappedMovieDetail = wrappedMovieDetail
        movieRecommendations.append(contentsOf: wrappedMovieDetail.movieRecommendations)
        movieReviews.append(contentsOf: wrappedMovieDetail.movieReview.reviews)
        view?.updateMovieDetails(.success(wrappedMovieDetail))
    }
    
    func fetchMovieRecommendations(for id: Int) async throws(NetworkingError) {
        let movieRecommendations = try await interactor?.fetchMovieRecommendations(for: id, page: recommendationsPage)
        let movieResults = movieRecommendations?.movieResults ?? []
        self.movieRecommendations.append(contentsOf: movieResults)
        if !movieResults.isEmpty { view?.updateRecommendationDataSource() }
    }
    
    func fetchMovieReviews(for id: Int) async throws(NetworkingError) {
        let movieReviews = try await interactor?.fetchMovieReviews(for: id, page: reviewsPage)
        let reviews = movieReviews?.reviews ?? []
        self.movieReviews.append(contentsOf: reviews)
        if !reviews.isEmpty { view?.updateReviewDataSource() }
    }
    
    func upsertFavoriteMovie(movie: MovieResult, persistenceManager: PersistenceManager?) {
        let isAdded = persistenceManager?.upsertFavorite(movie: movie) ?? false
        (view as? UIViewController)?.navigationItem.rightBarButtonItems?[0].image = UIImage(systemName: isAdded ? "bookmark.fill" : "bookmark")
    }
}
