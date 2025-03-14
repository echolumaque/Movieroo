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
    func fetchMovieReviews(for id: Int, page: Int) async throws(NetworkingError) -> MovieReview
}

class MovieDetailInteractorImpl: MovieDetailInteractor {
    private let networkManager: NetworkManager
    weak var presenter: (any MovieDetailPresenter)?
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func fetchMovieDetails(for id: Int) async throws(NetworkingError) -> WrappedMovieDetail {
        do {
            let movieDetailUrl = "\(Configuration.NetworkCall.baseUrl.rawValue)/movie/\(id)?language=en-US"
            let movieCertificationUrl = "\(Configuration.NetworkCall.baseUrl.rawValue)/movie/\(id)/release_dates"
            
            async let fetchedMovieDetail: MovieDetail = try networkManager.baseNetworkCall(for: movieDetailUrl)
            async let fetchedMovieReview: MovieReview = try fetchMovieReviews(for: id, page: 1)
            async let fetchedMovieCertification: MovieCertification = try networkManager.baseNetworkCall(for: movieCertificationUrl)
            async let fetchedMovieRecommendations: Movie = try fetchMovieRecommendations(for: id, page: 1)
            async let fetchedMovieVideo: MovieVideo = try networkManager.baseNetworkCall(for: "\(Configuration.NetworkCall.baseUrl.rawValue)/movie/\(id)/videos?language=en-US")
            
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
        let fetchedMovieReview: Movie = try await networkManager.baseNetworkCall(for: movieRecommendationsUrl)
        
        return fetchedMovieReview
    }
    
    func fetchMovieReviews(for id: Int, page: Int) async throws(NetworkingError) -> MovieReview {
        let movieReviewsUrl = "\(Configuration.NetworkCall.baseUrl.rawValue)/movie/\(id)/reviews?language=en-US&page=\(page)"
        let fetchedMovieReview: MovieReview = try await networkManager.baseNetworkCall(for: movieReviewsUrl)
        
        return fetchedMovieReview
    }
}
