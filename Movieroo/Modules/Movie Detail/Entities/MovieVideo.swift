//
//  MovieVideo.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/28/25.
//

import Foundation

struct MovieVideo: Codable {
    let id: Int
    let videos: [Video]
    var hasYoutubeVideo: Bool { videos.contains { $0.site == "YouTube" } }
    
    enum CodingKeys: String, CodingKey {
        case id
        case videos = "results"
    }
}

struct Video: Codable {
    let name, key: String
    let site: String
    let size: Int
    let type: String
    let official: Bool
    let publishedAt, id: String

    enum CodingKeys: String, CodingKey {
        case name, key, site, size, type, official
        case publishedAt = "published_at"
        case id
    }
}
