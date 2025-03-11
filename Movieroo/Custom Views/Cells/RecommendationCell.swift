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
    
    func set(movieResult: MovieResult, networkManager: NetworkManager?) {
        if let posterPath = movieResult.posterPath {
            Task { [weak self] in
                self?.posterView.image = await networkManager?.downloadImage(from: "https://image.tmdb.org/t/p/w185\(posterPath)")
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
        
        titleLabel.textAlignment = .center
        
        let starsView = UIHostingController(rootView: starsView)
        starsView.view.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubviews(posterView, titleLabel, starsView.view, ratingLabel)
        NSLayoutConstraint.activate([
            posterView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
            posterView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
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
    let cell = RecommendationCell()
    cell.set(movieResult: WrappedMovieDetail.test.movieRecommendations.first!, networkManager: NetworkManagerImpl())
    
    return cell
}
