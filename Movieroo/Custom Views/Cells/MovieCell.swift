//
//  MovieCell.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/24/25.
//

import UIKit
import SwiftUI

class MovieCell: UICollectionViewCell {
    static let reuseID = "MovieCell"
    private let horizontalPadding: CGFloat = 20
    private let verticalPadding: CGFloat = 8
    
    let moviePoster = UIImageView()
    let titleLabel = UILabel()
    let overviewLabel = UILabel()
    let miscInfoView = UIStackView()
    
    let releaseDateIcon = UIImageView(image: UIImage(systemName: "popcorn.fill"))
    let releaseDateLabel = UILabel()
    
    private let starRatingModel = StarRatingModel(rating: 0, maxRating: 5)
    var starsView: StarsView { StarsView(model: starRatingModel) }
    
    let voteCountLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(movie: MovieResult) {
        Task {
            moviePoster.image = await NetworkManager.shared.downloadImage(from: "https://image.tmdb.org/t/p/w92\(movie.posterPath)")
        }
        
        titleLabel.text = movie.originalTitle
        overviewLabel.text = movie.overview
        releaseDateLabel.text = movie.releaseDate.formatDateToLocale
        starRatingModel.rating = movie.voteAverage / 2
        voteCountLabel.text = "(\(movie.voteCount))"
    }
    
    private func configure() {
        configureMoviePoster()
        configureTitle()
        configureOverviewLabel()
        configureMiscInfoView()
    }
    
    private func configureMoviePoster() {
        addSubview(moviePoster)
        moviePoster.translatesAutoresizingMaskIntoConstraints = false
        moviePoster.layer.cornerRadius = 4
        moviePoster.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            moviePoster.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: verticalPadding),
            moviePoster.leadingAnchor.constraint(equalTo: leadingAnchor, constant: horizontalPadding),
            moviePoster.widthAnchor.constraint(equalToConstant: 92)
        ])
    }
    
    private func configureTitle() {
        addSubview(titleLabel)
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.9
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title1, compatibleWith: UITraitCollection(legibilityWeight: .bold))
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: moviePoster.trailingAnchor, constant: horizontalPadding),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -horizontalPadding)
        ])
    }
    
    private func configureOverviewLabel() {
        addSubview(overviewLabel)
        overviewLabel.numberOfLines = 5
        overviewLabel.adjustsFontSizeToFitWidth = true
        overviewLabel.minimumScaleFactor = 0.9
        overviewLabel.lineBreakMode = .byTruncatingTail
        overviewLabel.font = UIFont.preferredFont(forTextStyle: .body)
        overviewLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            overviewLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: verticalPadding),
            overviewLabel.leadingAnchor.constraint(equalTo: moviePoster.trailingAnchor, constant: horizontalPadding),
            overviewLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -horizontalPadding),
            overviewLabel.bottomAnchor.constraint(equalTo: moviePoster.bottomAnchor)
        ])
    }
    
    private func configureMiscInfoView() {
        addSubview(miscInfoView)
        miscInfoView.axis = .horizontal
        miscInfoView.distribution = .equalSpacing
        miscInfoView.translatesAutoresizingMaskIntoConstraints = false
        
        configureReleaseMiscInfoComponent()
        configureRatingMiscInfoComponent()
        
        NSLayoutConstraint.activate([
            miscInfoView.topAnchor.constraint(equalTo: moviePoster.bottomAnchor, constant: verticalPadding),
            miscInfoView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: horizontalPadding),
            miscInfoView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -horizontalPadding),
        ])
    }
    
    private func configureReleaseMiscInfoComponent() {
        let releaseComponent = UIView()
        releaseComponent.translatesAutoresizingMaskIntoConstraints = false
        releaseComponent.addSubviews(releaseDateIcon, releaseDateLabel)

        releaseDateIcon.translatesAutoresizingMaskIntoConstraints = false
        releaseDateIcon.tintColor = .secondaryLabel
        
        releaseDateLabel.translatesAutoresizingMaskIntoConstraints = false
        releaseDateLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        releaseDateLabel.textColor = .secondaryLabel

        NSLayoutConstraint.activate([
            releaseDateIcon.widthAnchor.constraint(equalToConstant: 20),
            releaseDateIcon.heightAnchor.constraint(equalToConstant: 20),
            releaseDateLabel.leadingAnchor.constraint(equalTo: releaseDateIcon.trailingAnchor, constant: 8),
            releaseDateLabel.centerYAnchor.constraint(equalTo: releaseDateIcon.centerYAnchor)
        ])
        
        miscInfoView.addArrangedSubview(releaseComponent)
    }
    
    private func configureRatingMiscInfoComponent() {
        voteCountLabel.textColor = .secondaryLabel
        voteCountLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        
        let hostedStarsView = UIHostingController(rootView: starsView)
        
        let voteComponent = UIStackView(arrangedSubviews: [hostedStarsView.view, voteCountLabel])
        voteComponent.axis = .horizontal
        voteComponent.spacing = 4
        voteComponent.translatesAutoresizingMaskIntoConstraints = false
        
        hostedStarsView.view.heightAnchor.constraint(equalToConstant: 20).isActive = true
        miscInfoView.addArrangedSubview(voteComponent)
    }
}

#Preview {
    let movieCell = MovieCell()
    
    movieCell.set(movie: MovieResult(backdropPath: Optional("/9nhjGaFLKtddDPtPaX5EmKqsWdH.jpg"),
                                     id: 950396,
                                     title: "The Gorge",
                                     originalTitle: "The Gorge",
                                     overview: "Two highly trained operatives grow close from a distance after being sent to guard opposite sides of a mysterious gorge. When an evil below emerges, they must work together to survive what lies within.",
                                     posterPath: "/7iMBZzVZtG0oBug4TfqDb9ZxAOa.jpg",
                                     adult: false,
                                     genreIDS: [10749, 878, 53],
                                     popularity: 897.524,
                                     releaseDate: "2025-02-13",
                                     video: false,
                                     voteAverage: 7.838,
                                     voteCount: 1196))
    
    return movieCell
}
