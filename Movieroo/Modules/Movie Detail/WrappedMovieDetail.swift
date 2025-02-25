//
//  WrappedMovieDetail.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/25/25.
//

import Foundation

struct WrappedMovieDetail: Codable {
    let movieDetail: MovieDetail
    let movieReview: MovieReview
    let movieCertification: MovieCertification
}
