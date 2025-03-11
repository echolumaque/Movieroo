//
//  PersistenceManager.swift
//  Movieroo
//
//  Created by Echo Lumaque on 3/5/25.
//

import UIKit

protocol PersistenceManager {
    func checkIfIsFavorite(movie: MovieResult) -> Bool
    func getFavorites() -> [MovieResult]
    func upsertFavorite(movie: MovieResult) -> Bool
}

class PersistenceManagerImpl: PersistenceManager {
    private let userDefaults: UserDefaults
    
    init() {
        self.userDefaults = UserDefaults.standard
    }
    
    enum Keys { static let favorites = "favorites" }
    
    func checkIfIsFavorite(movie: MovieResult) -> Bool {
        guard let favoritesData = userDefaults.data(forKey: Keys.favorites),
              let favorites = try? favoritesData.decode(to: [MovieResult].self) else { return false }
        
        return favorites.contains(movie)
    }
    
    func getFavorites() -> [MovieResult] {
        guard let favoritesData = userDefaults.data(forKey: Keys.favorites),
              let favorites = try? favoritesData.decode(to: [MovieResult].self) else { return [] }
        
        return favorites
    }
    
    func upsertFavorite(movie: MovieResult) -> Bool {
        var favorites = getFavorites()
        guard !favorites.isEmpty else {
            userDefaults.set([movie].encode(), forKey: Keys.favorites)
            return true
        }
        
        var isAdded: Bool
        if favorites.contains(movie) {
            favorites.removeAll(where: { $0 == movie })
            isAdded = false
        } else {
            favorites.append(movie)
            isAdded = true
        }
        
        userDefaults.set(favorites.encode(), forKey: Keys.favorites)
        
        return isAdded
    }
}

//enum PersistenceManager {
//    static private let defaults = UserDefaults.standard
//    
//    enum Keys { static let favorites = "favorites" }
//    
//    static func checkIfIsFavorite(movie: MovieResult) -> Bool {
//        guard let favoritesData = defaults.data(forKey: Keys.favorites),
//              let favorites = try? favoritesData.decode(to: [MovieResult].self) else { return false }
//        
//        return favorites.contains(movie)
//    }
//    
//    static func getFavorites() -> [MovieResult] {
//        guard let favoritesData = defaults.data(forKey: Keys.favorites),
//              let favorites = try? favoritesData.decode(to: [MovieResult].self) else { return [] }
//        
//        return favorites
//    }
//    
//    static func upsertFavorite(movie: MovieResult) -> Bool {
//        var favorites = getFavorites()
//        guard !favorites.isEmpty else {
//            defaults.set([movie].encode(), forKey: Keys.favorites)
//            return true
//        }
//        
//        var isAdded: Bool
//        if favorites.contains(movie) {
//            favorites.removeAll(where: { $0 == movie })
//            isAdded = false
//        } else {
//            favorites.append(movie)
//            isAdded = true
//        }
//        
//        defaults.set(favorites.encode(), forKey: Keys.favorites)
//        
//        return isAdded
//    }
//}
