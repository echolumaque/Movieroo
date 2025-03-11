//
//  BookmarkedMovieDetailViewModel.swift
//  Movieroo
//
//  Created by Echo Lumaque on 3/7/25.
//

import Foundation

class BookmarkedMovieDetailViewModel: ObservableObject {
    private let networkManager: NetworkManager
    private let persistenceManager: PersistenceManager
    private let selectedMovie: MovieResult
    
    @Published var hasTriggeredLastVisibleRecommendation = false
    @Published var recommendationsPage = 1
    @Published var isFavoriteMovie = false
    @Published var movieRecommendations: [MovieResult] = []
    @Published var movieReviews: [Review] = []
    @Published var reviewsPage = 1
    @Published var wrappedMovieDetail: WrappedMovieDetail?

    init(networkManager: NetworkManager, persistenceManager: PersistenceManager, selectedMovie: MovieResult) {
        self.networkManager = networkManager
        self.persistenceManager = persistenceManager
        self.selectedMovie = selectedMovie
    }
    
    func onAppear() async {
        isFavoriteMovie = persistenceManager.checkIfIsFavorite(movie: selectedMovie)
        try? await fetchMovieDetails()
    }
    
    private func fetchMovieDetails() async throws(NetworkingError) {
        do {
            let id = selectedMovie.id
            let movieDetailUrl = "\(Configuration.NetworkCall.baseUrl.rawValue)/movie/\(id)?language=en-US"
            let movieCertificationUrl = "\(Configuration.NetworkCall.baseUrl.rawValue)/movie/\(id)/release_dates"
            
            async let fetchedMovieDetail: MovieDetail = try networkManager.baseNetworkCall(for: movieDetailUrl)
            async let fetchedMovieReview: MovieReview = fetchMovieReviews()
            async let fetchedMovieCertification: MovieCertification = try networkManager.baseNetworkCall(for: movieCertificationUrl)
            async let fetchedMovieRecommendations: Movie = fetchMovieRecommendations()
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
            
            wrappedMovieDetail = WrappedMovieDetail(
                movieDetail: movieDetail,
                movieReview: movieReview,
                movieCertification: movieCertificaiton,
                movieRecommendations: movieRecommendations.movieResults,
                movieVideo: movieVideo
            )
        } catch {
            print("Error in MovieDetailInteractor: \(error)")
            if let networkingError = error as? NetworkingError {
                throw networkingError
            } else {
                throw .otherError(innerError: error)
            }
        }
    }
    
    func fetchMovieRecommendations() async throws(NetworkingError) -> Movie {
        let movieRecommendationsUrl = "\(Configuration.NetworkCall.baseUrl.rawValue)/movie/\(selectedMovie.id)/recommendations?language=en-US&page=\(recommendationsPage)"
        let recommendations: Movie = try await networkManager.baseNetworkCall(for: movieRecommendationsUrl)
        movieRecommendations.append(contentsOf: recommendations.movieResults)
        return recommendations
    }
    
    func fetchMovieReviews() async throws(NetworkingError) -> MovieReview {
        let movieReviewsUrl = "\(Configuration.NetworkCall.baseUrl.rawValue)/movie/\(selectedMovie.id)/reviews?language=en-US&page=\(reviewsPage)"
        let review: MovieReview = try await networkManager.baseNetworkCall(for: movieReviewsUrl)
        movieReviews.append(contentsOf: review.reviews)
        return review
    }
    
    func upsertFavoriteMovie() {
        isFavoriteMovie = persistenceManager.upsertFavorite(movie: selectedMovie)
    }
}
