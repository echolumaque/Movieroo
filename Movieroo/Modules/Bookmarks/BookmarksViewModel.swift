//
//  BookmarksViewModel.swift
//  Movieroo
//
//  Created by Echo Lumaque on 3/6/25.
//

import Foundation

class BookmarksViewModel: ObservableObject {
    private let persistenceManager: PersistenceManager
    
    @Published private(set) var favorites: [MovieResult] = []
    @Published var selectedMovieResult: MovieResult?
    
    init(persistenceManager: PersistenceManager) {
        self.persistenceManager = persistenceManager
    }
    
    func onAppear() {
        getFavorites()
    }
    
    private func getFavorites() {
        favorites = persistenceManager.getFavorites() 
    }
    
    func upsertFavorite(index: Int) {
        let isAdded = persistenceManager.upsertFavorite(movie: favorites[index])
        if !isAdded { favorites.remove(at: index) }
    }
}
