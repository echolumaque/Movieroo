//
//  MovieCertification.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/25/25.
//

import Foundation

// MARK: - MovieCertification
struct MovieCertification: Codable {
    let id: Int
    let resultElement: [ResultElement]
    
    enum CodingKeys: String, CodingKey {
        case id
        case resultElement = "results"
    }
}

// MARK: - Result
struct ResultElement: Codable {
    let iso3166_1: String
    let releaseDates: [ReleaseDateElement]

    enum CodingKeys: String, CodingKey {
        case iso3166_1 = "iso_3166_1"
        case releaseDates = "release_dates"
    }
}

// MARK: - ReleaseDateElement
struct ReleaseDateElement: Codable {
    let certification: String
    let descriptors: [String]
    let iso639_1: String
    let type: Int

    enum CodingKeys: String, CodingKey {
        case certification, descriptors
        case iso639_1 = "iso_639_1"
        case type
    }
}
