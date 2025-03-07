//
//  BookmarksViewModel.swift
//  Movieroo
//
//  Created by Echo Lumaque on 3/6/25.
//

import Foundation

class BookmarksViewModel: ObservableObject {
    private let persistenceManagerClass: PersistenceManagerClass
    
    @Published private(set) var favorites: [MovieResult] = []
    @Published var selectedMovieResult: MovieResult?
    
    init(persistenceManagerClass: PersistenceManagerClass) {
        self.persistenceManagerClass = persistenceManagerClass
    }
    
    func onAppear() {
        getFavorites()
    }
    
    private func getFavorites() {
        favorites = persistenceManagerClass.getFavorites()
    }
    
    func upsertFavorite(index: Int) {
        let isAdded = persistenceManagerClass.upsertFavorite(movie: favorites[index])
        if !isAdded { favorites.remove(at: index) }
    }
}
