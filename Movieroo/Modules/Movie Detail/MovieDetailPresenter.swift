//
//  MovieDetailPresenter.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/24/25.
//

import Foundation

protocol MovieDetailPresenter: AnyObject {
    var router: MovieDetailRouter? { get set }
    var interactor: MovieDetailInteractor? { get set }
    var view: MovieDetailView? { get set }
    
//    var movieDetail: MovieDetail? { get set }
//    var movieReview: MovieReview? { get set }
    
    func fetchMovieDetail(for id: Int) async throws(NetworkingError)
    func fetchMovieReview(for id: Int) async throws(NetworkingError)
    func fetchMovieCertification(for id: Int) async throws(NetworkingError)
}

class MovieDetailPresenterImpl: MovieDetailPresenter {
    var router: (any MovieDetailRouter)?
    var interactor: (any MovieDetailInteractor)?
    weak var view: (any MovieDetailView)?
    
    var movieDetail: MovieDetail?
    var movieReview: MovieReview?
    
    func fetchMovieDetail(for id: Int) async throws(NetworkingError) {
        guard let interactor else {
            view?.updateMovieDetail(.failure(.otherError(message: "MovieDetailInteractor is nil")))
            return
        }
        
        let detail = try await interactor.fetchMovieDetail(for: id)
//        movieDetail = detail
        view?.updateMovieDetail(.success(detail))
    }
    
    func fetchMovieReview(for id: Int) async throws(NetworkingError) {
        guard let interactor else {
            view?.updateMovieDetail(.failure(.otherError(message: "MovieDetailInteractor is nil")))
            return
        }
        
        let review = try await interactor.fetchReview(for: id)
//        movieReview = review
        view?.updateMovieReview(.success(review))
    }
    
    func fetchMovieCertification(for id: Int) async throws(NetworkingError) {
        guard let interactor else {
            view?.updateMovieDetail(.failure(.otherError(message: "MovieDetailInteractor is nil")))
            return
        }
        
        let movieCertification = try await interactor.fetchMovieCertification(for: id)
//        movieReview = review
        view?.updateMovieCertification(.success(movieCertification))
    }
}
