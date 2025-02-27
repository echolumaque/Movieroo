//
//  MovieInteractor.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/24/25.
//

import Foundation

protocol MovieDetailInteractor: AnyObject {
    var presenter: MovieDetailPresenter? { get set }
    func fetchMovieDetails(for id: Int) async throws(NetworkingError) -> WrappedMovieDetail
    func fetchMovieRecommendations(for id: Int, page: Int) async throws(NetworkingError) -> Movie
}

class MovieDetailInteractorImpl: MovieDetailInteractor {
    weak var presenter: (any MovieDetailPresenter)?
    
    func fetchMovieDetails(for id: Int) async throws(NetworkingError) -> WrappedMovieDetail {
        do {
            let movieDetailUrl = "\(Configuration.NetworkCall.baseUrl.rawValue)/movie/\(id)?language=en-US"
            let movieReviewUrl = "\(Configuration.NetworkCall.baseUrl.rawValue)/movie/\(id)/reviews?language=en-US&page=1"
            let movieCertificationUrl = "\(Configuration.NetworkCall.baseUrl.rawValue)/movie/\(id)/release_dates"
            
            async let fetchedMovieDetail: MovieDetail = try NetworkManager.shared.baseNetworkCall(for: movieDetailUrl)
            async let fetchedMovieReview: MovieReview = try NetworkManager.shared.baseNetworkCall(for: movieReviewUrl)
            async let fetchedMovieCertification: MovieCertification = try NetworkManager.shared.baseNetworkCall(for: movieCertificationUrl)
            async let fetchedMovieRecommendations: Movie = try fetchMovieRecommendations(for: id, page: 1)
            async let fetchedMovieVideo: MovieVideo = try NetworkManager.shared.baseNetworkCall(for: "\(Configuration.NetworkCall.baseUrl.rawValue)/movie/\(id)/videos?language=en-US")
            
            let (
                movieDetail,
                movieReview,
                movieCertificaiton,
                movieRecommendations,
                movieVideo
            ) = try await (
                fetchedMovieDetail,
                fetchedMovieReview,
                fetchedMovieCertification,
                fetchedMovieRecommendations,
                fetchedMovieVideo
            )
            let wrappedMovieDetail = WrappedMovieDetail(
                movieDetail: movieDetail,
                movieReview: movieReview,
                movieCertification: movieCertificaiton,
                movieRecommendations: movieRecommendations.movieResults,
                movieVideo: movieVideo
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
    
    func fetchMovieRecommendations(for id: Int, page: Int) async throws(NetworkingError) -> Movie {
        let movieRecommendationsUrl = "\(Configuration.NetworkCall.baseUrl.rawValue)/movie/\(id)/recommendations?language=en-US&page=\(page)"
        let fetchedMovieReview: Movie = try await NetworkManager.shared.baseNetworkCall(for: movieRecommendationsUrl)
        
        return fetchedMovieReview
    }
}
