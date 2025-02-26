//
//  RecommendationCell.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/26/25.
//

import UIKit
import SwiftUI

class RecommendationCell: UICollectionViewCell {
    static let reuseID = "RecommendationCell"
    private var movieDetail: MovieDetail!
    private let horizontalPadding: CGFloat = 20
    private let verticalPadding: CGFloat = 8
    
    private let posterView = MovierooImageView()
    
    private let titleLabel = DynamicLabel(font: UIFont.preferredFont(for: .title2, weight: .semibold), numberOfLines: 1)
    
    private let ratingLabel = DynamicLabel(textColor: .secondaryLabel, font: UIFont.preferredFont(for: .body, weight: .regular), numberOfLines: 1)
    
    private var starsRatingModel = StarRatingModel(rating: 3.5, maxRating: 5)
    private var starsView: StarsView {
        StarsView(model: starsRatingModel)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(movieDetail: MovieDetail) {
        self.init(frame: .zero)
        self.movieDetail = movieDetail
    }
    
    func set(movieResult: MovieResult) {
        if let posterPath = movieResult.posterPath {
            Task {
                posterView.image = await NetworkManager.shared.downloadImage(from: "https://image.tmdb.org/t/p/w185\(posterPath)")
            }
        }
        
        titleLabel.text = movieResult.title
        ratingLabel.text = "(\(movieResult.voteCount.commaRepresentation))"
        starsRatingModel.rating = movieResult.voteAverage / 2
    }
    
    private func configure() {
        posterView.translatesAutoresizingMaskIntoConstraints = false
        posterView.contentMode = .scaleAspectFit
        posterView.clipsToBounds = true
        posterView.layer.cornerRadius = 10
        if Environment.isForPreview {
            Task {
                posterView.image = await NetworkManager.shared.downloadImage(from: "https://image.tmdb.org/t/p/w154\(movieDetail.posterPath)")
            }
        }
        
        titleLabel.textAlignment = .center
        
        if Environment.isForPreview { titleLabel.text = "Mufasa" }
        if Environment.isForPreview { ratingLabel.text = "141" }
        
        let starsView = UIHostingController(rootView: starsView)
        starsView.view.translatesAutoresizingMaskIntoConstraints = false
        
        addSubviews(posterView, titleLabel, starsView.view, ratingLabel)
        NSLayoutConstraint.activate([
            posterView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            posterView.leadingAnchor.constraint(equalTo: leadingAnchor),
            posterView.trailingAnchor.constraint(equalTo: trailingAnchor),
            posterView.widthAnchor.constraint(equalToConstant: 154),
            posterView.heightAnchor.constraint(equalTo: posterView.widthAnchor, multiplier: 3.0 / 2.0),
            
            titleLabel.topAnchor.constraint(equalTo: posterView.bottomAnchor, constant: verticalPadding),
            titleLabel.centerXAnchor.constraint(equalTo: posterView.centerXAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: posterView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: posterView.trailingAnchor),
            
            starsView.view.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            starsView.view.leadingAnchor.constraint(equalTo: posterView.leadingAnchor),
            starsView.view.centerYAnchor.constraint(equalTo: ratingLabel.centerYAnchor),
            
            ratingLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: verticalPadding),
            ratingLabel.leadingAnchor.constraint(equalTo: starsView.view.trailingAnchor, constant: 4),
            ratingLabel.trailingAnchor.constraint(equalTo: posterView.trailingAnchor)
        ])
    }
}

#Preview {
    RecommendationCell(movieDetail: MovieDetail(adult: false, backdropPath: "/cVh8Af7a9JMOJl75ML3Dg2QVEuq.jpg", belongsToCollection: Movieroo.BelongsToCollection(id: 762512, name: "The Lion King (Reboot) Collection", posterPath: "/dGpIRn4Nqi63JO1RlKxjcPbQSAw.jpg", backdropPath: "/jIgM7YNVft0YGeXsqrh3oG5TWLx.jpg"), budget: 200000000, genres: [Movieroo.Genre(id: 12, name: "Adventure"), Movieroo.Genre(id: 10751, name: "Family"), Movieroo.Genre(id: 16, name: "Animation")], homepage: "https://movies.disney.com/mufasa-the-lion-king", id: 762509, imdbID: "tt13186482", originCountry: ["US"], originalLanguage: "en", originalTitle: "Mufasa: The Lion King", overview: "Mufasa, a cub lost and alone, meets a sympathetic lion named Taka, the heir to a royal bloodline. The chance meeting sets in motion an expansive journey of a group of misfits searching for their destiny.", popularity: 724.285, posterPath: "/9bXHaLlsFYpJUutg4E6WXAjaxDi.jpg", productionCompanies: [Movieroo.ProductionCompany(id: 2, logoPath: Optional("/wdrCwmRnLFJhEoH8GSfymY85KHT.png"), name: "Walt Disney Pictures", originCountry: "US")], productionCountries: [Movieroo.ProductionCountry(iso3166_1: "US", name: "United States of America")], releaseDate: "2024-12-18", revenue: 688700870, runtime: 118, spokenLanguages: [Movieroo.SpokenLanguage(englishName: "English", iso639_1: "en", name: "English")], status: "Released", tagline: "The story of an orphan who would be king.", title: "Mufasa: The Lion King", video: false, voteAverage: 7.448, voteCount: 1345))
}
