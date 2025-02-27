//
//  ReviewCell.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/25/25.
//

import UIKit
import SwiftUI

class ReviewCell: UITableViewCell {
    static let reuseID = "ReviewCell"
    private let horizontalPadding: CGFloat = 16
    private let verticalPadding: CGFloat = 8
    
    private let authorAvatar = UIImageView()
    private let authorNameLabel = DynamicLabel(font: UIFont.preferredFont(for: .title3, weight: .bold), numberOfLines: 1)

    private let starRatingModel = StarRatingModel(rating: 3.6, maxRating: 5)
    private var starsView: StarsView {
        StarsView(model: starRatingModel)
    }
    
    private let reviewDateLabel = DynamicLabel(font: UIFont.preferredFont(for: .callout, weight: .regular), numberOfLines: 1)
    private let contentLabel = DynamicLabel(font: UIFont.preferredFont(for: .body, weight: .regular))
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(review: Review) {
        if let avatarPath = review.authorDetails?.avatarPath {
            Task {
                authorAvatar.image = await NetworkManager.shared.downloadImage(from: "https://image.tmdb.org/t/p/w45\(avatarPath)")
            }
        }
        
        authorNameLabel.text = review.author
        
        reviewDateLabel.text = review.createdAt.formatISO8601DateToLocale
        
        var correctRating: CGFloat
        if let rating = review.authorDetails?.rating { correctRating = CGFloat(rating / 2) }
        else { correctRating = 0 }
        starRatingModel.rating = correctRating
        
        let attributedString = AttributedString(review.content)
        contentLabel.attributedText = NSAttributedString(attributedString)
    }
    
    private func configure() {
        configureAvatar()
        configureAuthorName()
        configureReviewDate()
        configureStarRating()
        configureContent()
    }
    
    private func configureAvatar() {
        addSubview(authorAvatar)
        authorAvatar.translatesAutoresizingMaskIntoConstraints = false
        authorAvatar.clipsToBounds = true
        authorAvatar.layer.cornerRadius = 45 / 2
        authorAvatar.layer.borderColor = UIColor.systemPurple.cgColor
        authorAvatar.layer.borderWidth = 2
        authorAvatar.image = UIImage(systemName: "person.fill")?.withRenderingMode(.alwaysTemplate)
        authorAvatar.tintColor = .systemPurple
        
        NSLayoutConstraint.activate([
            authorAvatar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: verticalPadding),
            authorAvatar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: horizontalPadding),
            authorAvatar.widthAnchor.constraint(equalToConstant: 45),
            authorAvatar.heightAnchor.constraint(equalToConstant: 45)
            
        ])
    }
    
    private func configureAuthorName() {
        addSubview(authorNameLabel)
        
        NSLayoutConstraint.activate([
            authorNameLabel.topAnchor.constraint(equalTo: authorAvatar.topAnchor),
            authorNameLabel.leadingAnchor.constraint(equalTo: authorAvatar.trailingAnchor, constant: horizontalPadding),
            authorNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
            
        ])
    }
    
    private func configureReviewDate() {
        addSubview(reviewDateLabel)
        
        NSLayoutConstraint.activate([
            reviewDateLabel.topAnchor.constraint(equalTo: authorNameLabel.bottomAnchor),
            reviewDateLabel.leadingAnchor.constraint(equalTo: authorAvatar.trailingAnchor, constant: horizontalPadding),
            reviewDateLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -horizontalPadding)
        ])
    }
    
    private func configureStarRating() {
        let hostedStarsView = UIHostingController(rootView: starsView)
        addSubview(hostedStarsView.view)
        hostedStarsView.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hostedStarsView.view.centerYAnchor.constraint(equalTo: authorNameLabel.centerYAnchor),
            hostedStarsView.view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -horizontalPadding),
            
        ])
    }
    
    private func configureContent() {
        addSubview(contentLabel)
        
        NSLayoutConstraint.activate([
            contentLabel.topAnchor.constraint(equalTo: authorAvatar.bottomAnchor, constant: verticalPadding),
            contentLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: horizontalPadding),
            contentLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -horizontalPadding),
            contentLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -verticalPadding)
        ])
    }
}

#Preview {
    let cell = ReviewCell()
    cell.set(review: WrappedMovieDetail.test.movieReview.reviews.first!)
    
    return cell
}
