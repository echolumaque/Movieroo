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
    
    var wrappedMovieDetail: WrappedMovieDetail? { get set }
    
    func fetchMovieDetals(for id: Int) async throws(NetworkingError)
}

class MovieDetailPresenterImpl: MovieDetailPresenter {
    var router: (any MovieDetailRouter)?
    var interactor: (any MovieDetailInteractor)?
    weak var view: (any MovieDetailView)?
    var wrappedMovieDetail: WrappedMovieDetail?
    
    func fetchMovieDetals(for id: Int) async throws(NetworkingError) {
        guard let interactor else {
            view?.updateMovieDetails(.failure(.otherError(message: "Interactor is nil")))
            wrappedMovieDetail = nil
            return
        }
        
        let wrappedMovieDetail = try await interactor.fetchMovieDetauls(for: id)
        self.wrappedMovieDetail = wrappedMovieDetail
        view?.updateMovieDetails(.success(wrappedMovieDetail))
    }
}
