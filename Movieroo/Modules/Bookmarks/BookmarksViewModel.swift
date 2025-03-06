//
//  BookmarksViewModel.swift
//  Movieroo
//
//  Created by Echo Lumaque on 3/6/25.
//

import Foundation

class BookmarksViewModel {
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
}
