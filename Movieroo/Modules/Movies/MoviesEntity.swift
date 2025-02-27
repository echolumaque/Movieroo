//
//  MoviesEntity.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/24/25.
//

import Foundation

struct Movie: Codable, Hashable {
    let page: Int
    let movieResults: [MovieResult]
    let totalPages, totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page
        case movieResults = "results"
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

struct MovieResult: Codable {
    let uuid = UUID()
    
    let backdropPath: String?
    let id: Int
    let title, originalTitle, overview: String
    let posterPath: String?
    let adult: Bool
    let genreIDS: [Int]
    let popularity: Double
    let releaseDate: String
    let video: Bool
    let voteAverage: Double
    let voteCount: Int

    enum CodingKeys: String, CodingKey {
        case backdropPath = "backdrop_path"
        case id, title
        case originalTitle = "original_title"
        case overview
        case posterPath = "poster_path"
        case adult
        case genreIDS = "genre_ids"
        case popularity
        case releaseDate = "release_date"
        case video
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}

extension MovieResult: Hashable {
    static func ==(lhs: MovieResult, rhs: MovieResult) -> Bool { lhs.uuid == rhs.uuid }
    func hash(into hasher: inout Hasher) { hasher.combine(uuid) }
}
