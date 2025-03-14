//
//  MovieReview.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/25/25.
//

import Foundation

struct MovieReview: Codable {
    let id, page: Int
    let reviews: [Review]
    let totalPages, totalResults: Int

    enum CodingKeys: String, CodingKey {
        case id, page
        case reviews = "results"
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

struct Review: Codable, Equatable, Hashable {
    let author: String
    let authorDetails: AuthorDetails?
    let content, createdAt, id, updatedAt: String
    let url: String

    enum CodingKeys: String, CodingKey {
        case author
        case authorDetails = "author_details"
        case content
        case createdAt = "created_at"
        case id
        case updatedAt = "updated_at"
        case url
    }
    
    static func ==(lhs: Review, rhs: Review) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct AuthorDetails: Codable {
    let name, username: String
    let avatarPath: String?
    let rating: Double?

    enum CodingKeys: String, CodingKey {
        case name, username
        case avatarPath = "avatar_path"
        case rating
    }
}
