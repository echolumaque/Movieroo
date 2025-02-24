//
//  MovieInteractor.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/24/25.
//

import Foundation

protocol MovieDetailInteractor: AnyObject {
    var presenter: MovieDetailPresenter? { get set }
    func fetchMovieDetail(for id: Int) async throws(NetworkingError) -> MovieDetail
    func fetchReview(for id: Int) async throws(NetworkingError) -> MovieReview
    func fetchMovieCertification(for id: Int) async throws(NetworkingError) -> MovieCertification
}

class MovieDetailInteractorImpl: MovieDetailInteractor {
    weak var presenter: (any MovieDetailPresenter)?
    
    func fetchMovieDetail(for id: Int) async throws(NetworkingError) -> MovieDetail  {
        let constructerdUrl = "https://api.themoviedb.org/3/movie/\(id)?language=en-US"
        let fetchedDetail: MovieDetail = try await NetworkManager.shared.baseNetworkCall(for: constructerdUrl)
        
        return fetchedDetail
    }
    
    func fetchReview(for id: Int) async throws(NetworkingError) -> MovieReview {
        let constructerdUrl = "https://api.themoviedb.org/3/movie/\(id)/reviews?language=en-US&page=1"
        let fetchedReview: MovieReview = try await NetworkManager.shared.baseNetworkCall(for: constructerdUrl)
        
        return fetchedReview
    }
    
    func fetchMovieCertification(for id: Int) async throws(NetworkingError) -> MovieCertification {
        let constructedUrl = "https://api.themoviedb.org/3/movie/\(id)/release_dates"
        let fetchedCertification: MovieCertification = try await NetworkManager.shared.baseNetworkCall(for: constructedUrl)
        
        return fetchedCertification
    }
}
