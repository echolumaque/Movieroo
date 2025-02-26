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
    
    private let moviePoster = UIImageView(image: UIImage(systemName: "popcorn.fill"))
    private let titleLabel = DynamicLabel(font: UIFont.preferredFont(for: .title1, weight: .bold), minimumScaleFactor: 0.5, numberOfLines: 2)
    private let overviewLabel = DynamicLabel(font: UIFont.preferredFont(forTextStyle: .body), minimumScaleFactor: 0.9, numberOfLines: 5)
    private let miscInfoView = UIStackView()
    
    private let releaseDateIcon = UIImageView(image: UIImage(systemName: "popcorn.fill"))
    private let releaseDateLabel = DynamicLabel(textColor: .secondaryLabel, font: UIFont.preferredFont(forTextStyle: .footnote))
    
    private let starRatingModel = StarRatingModel(rating: 0, maxRating: 5)
    var starsView: StarsView { StarsView(model: starRatingModel) }
    
    private let voteCountLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(movie: MovieResult) {
        if let posterPath = movie.posterPath {
            Task {
                moviePoster.image = await NetworkManager.shared.downloadImage(from: "https://image.tmdb.org/t/p/w92\(posterPath)")
            }
        } else {
            moviePoster.tintColor = .systemPurple
        }
        titleLabel.text = movie.title
        overviewLabel.text = movie.overview
        releaseDateLabel.text = movie.releaseDate.formatDateToLocale
        starRatingModel.rating = movie.voteAverage / 2
        voteCountLabel.text = "(\(movie.voteCount.commaRepresentation))"
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
        titleLabel.lineBreakMode = .byTruncatingTail
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: moviePoster.trailingAnchor, constant: horizontalPadding),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -horizontalPadding)
        ])
    }
    
    private func configureOverviewLabel() {
        addSubview(overviewLabel)
        overviewLabel.lineBreakMode = .byTruncatingTail
        
        NSLayoutConstraint.activate([
            overviewLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: verticalPadding),
            overviewLabel.leadingAnchor.constraint(equalTo: moviePoster.trailingAnchor, constant: horizontalPadding),
            overviewLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -horizontalPadding),
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
            miscInfoView.topAnchor.constraint(greaterThanOrEqualTo: overviewLabel.bottomAnchor, constant: verticalPadding),
            miscInfoView.topAnchor.constraint(greaterThanOrEqualTo: moviePoster.bottomAnchor, constant: verticalPadding),
            miscInfoView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: horizontalPadding),
            miscInfoView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -horizontalPadding),
            miscInfoView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func configureReleaseMiscInfoComponent() {
        let releaseComponent = UIView()
        releaseComponent.translatesAutoresizingMaskIntoConstraints = false
        releaseComponent.addSubviews(releaseDateIcon, releaseDateLabel)

        releaseDateIcon.translatesAutoresizingMaskIntoConstraints = false
        releaseDateIcon.tintColor = .secondaryLabel
        

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
                                     title: "The Gorge The Gorge The Gorge The Gorge The Gorge",
                                     originalTitle: "The Gorge",
                                     overview: "Two highly trained operatives grow close from a distance after being sent to guard opposite sides of a mysterious gorge. When an evil below emerges, they must work together to survive what lies within. Two highly trained operatives grow close from a distance after being sent to guard opposite sides of a mysterious gorge. When an evil below emerges, they must work together to survive what lies within.",
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
