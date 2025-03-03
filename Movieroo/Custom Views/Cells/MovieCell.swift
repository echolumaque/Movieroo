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
    private let titleLabel = DynamicLabel(
        font: UIFont.preferredFont(for: .title1,  weight: .bold),
        minimumScaleFactor: 0.5,
        numberOfLines: 2
    )
    
    private let overviewLabel = DynamicLabel(
        font: UIFont.preferredFont(forTextStyle: .body),
        minimumScaleFactor: 0.9,
        numberOfLines: 5
    )
    private let miscInfoView = UIStackView()
    
    private let releaseDateIcon = UIImageView(image: UIImage(systemName: "popcorn.fill"))
    private let releaseDateLabel = DynamicLabel(textColor: .secondaryLabel, font: UIFont.preferredFont(forTextStyle: .footnote))
    
    private let starRatingModel = StarRatingModel(rating: 0, maxRating: 5)
    private var starsView: StarsView { StarsView(model: starRatingModel) }
    
    private let voteCountLabel = DynamicLabel(
        textColor: .secondaryLabel,
        font: UIFont.preferredFont(forTextStyle: .footnote),
        numberOfLines: 1
    )
    
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
        contentView.addSubview(moviePoster)
        moviePoster.translatesAutoresizingMaskIntoConstraints = false
        moviePoster.layer.cornerRadius = 4
        moviePoster.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            moviePoster.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: verticalPadding),
            moviePoster.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            moviePoster.widthAnchor.constraint(equalToConstant: 92)
        ])
    }
    
    private func configureTitle() {
        contentView.addSubview(titleLabel)
        titleLabel.lineBreakMode = .byTruncatingTail
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: moviePoster.trailingAnchor, constant: horizontalPadding),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding)
        ])
    }
    
    private func configureOverviewLabel() {
        contentView.addSubview(overviewLabel)
        overviewLabel.lineBreakMode = .byTruncatingTail
        
        NSLayoutConstraint.activate([
            overviewLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: verticalPadding),
            overviewLabel.leadingAnchor.constraint(equalTo: moviePoster.trailingAnchor, constant: horizontalPadding),
            overviewLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
        ])
    }
    
    private func configureMiscInfoView() {
        contentView.addSubview(miscInfoView)
        miscInfoView.axis = .horizontal
        miscInfoView.distribution = .equalSpacing
        miscInfoView.translatesAutoresizingMaskIntoConstraints = false
        
        configureReleaseMiscInfoComponent()
        configureRatingMiscInfoComponent()
        
        NSLayoutConstraint.activate([
            miscInfoView.topAnchor.constraint(greaterThanOrEqualTo: overviewLabel.bottomAnchor, constant: verticalPadding),
            miscInfoView.topAnchor.constraint(greaterThanOrEqualTo: moviePoster.bottomAnchor, constant: verticalPadding),
            miscInfoView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            miscInfoView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
            miscInfoView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
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
    let cell = MovieCell()
    cell.set(movie: WrappedMovieDetail.test.movieRecommendations.first!)
    
    return cell
}
