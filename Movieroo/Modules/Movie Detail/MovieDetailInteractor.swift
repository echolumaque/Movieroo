//
//  MovieInteractor.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/24/25.
//

import Foundation

protocol MovieDetailInteractor: AnyObject {
    var presenter: MovieDetailPresenter? { get set }
    func fetchMovieDetauls(for id: Int) async throws(NetworkingError) -> WrappedMovieDetail
}

class MovieDetailInteractorImpl: MovieDetailInteractor {
    weak var presenter: (any MovieDetailPresenter)?
    
    func fetchMovieDetauls(for id: Int) async throws(NetworkingError) -> WrappedMovieDetail {
        do {
            let movieDetailUrl = "https://api.themoviedb.org/3/movie/\(id)?language=en-US"
            let movieReviewUrl = "https://api.themoviedb.org/3/movie/\(id)/reviews?language=en-US&page=1"
            let movieCertificationUrl = "https://api.themoviedb.org/3/movie/\(id)/release_dates"
            
            async let fetchedMovieDetail: MovieDetail = try NetworkManager.shared.baseNetworkCall(for: movieDetailUrl)
            async let fetchedMovieReview: MovieReview = try NetworkManager.shared.baseNetworkCall(for: movieReviewUrl)
            async let fetchedMovieCertification: MovieCertification = try NetworkManager.shared.baseNetworkCall(for: movieCertificationUrl)
            
            let (movieDetail, movieReview, movieCertificaiton) = try await (fetchedMovieDetail, fetchedMovieReview, fetchedMovieCertification)
            let wrappedMovieDetail = WrappedMovieDetail(
                movieDetail: movieDetail,
                movieReview: movieReview,
                movieCertification: movieCertificaiton
            )
            
            return wrappedMovieDetail
        } catch {
            print("Error in MovieDetailInteractor: \(error)")
            if let networkingError = error as? NetworkingError {
                throw networkingError
            } else {
                throw .otherError(innerError: error)
            }
        }
    }
}
