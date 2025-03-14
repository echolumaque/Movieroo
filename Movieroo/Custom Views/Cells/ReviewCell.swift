//
//  ReviewCell.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/25/25.
//

import UIKit
import SwiftUI

protocol ReviewCellDelegate: AnyObject {
    func reviewCellDidPerformAction()
}

class ReviewCell: UITableViewCell {
    static let reuseID = "ReviewCell"
    var isContentExpanded = false
    weak var delegate: ReviewCellDelegate?
    
    private let horizontalPadding: CGFloat = 16
    private let verticalPadding: CGFloat = 8
    
    private let authorAvatar = UIImageView()
    private let authorNameLabel = DynamicLabel(font: UIFont.preferredFont(for: .title3, weight: .bold), numberOfLines: 1)

    private let starRatingModel = StarRatingModel(rating: 3.6, maxRating: 5)
    private var starsView: StarsView {
        StarsView(model: starRatingModel)
    }
    
    private let reviewDateLabel = DynamicLabel(font: UIFont.preferredFont(for: .callout, weight: .regular), numberOfLines: 1)
    let contentLabel = DynamicLabel(
        font: UIFont.preferredFont(for: .body, weight: .regular),
        minimumScaleFactor: 1.0,
        numberOfLines: 5
    )
    private let seeMoreOrLessBtn = UIButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(review: Review, networkManager: NetworkManager?) {
        if let avatarPath = review.authorDetails?.avatarPath {
            Task { [weak self] in
                self?.authorAvatar.image = await networkManager?.downloadImage(from: "https://image.tmdb.org/t/p/w45\(avatarPath)")
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
        configureSeeMoreOrLessBtn()
    }
    
    private func configureAvatar() {
        contentView.addSubview(authorAvatar)
        authorAvatar.translatesAutoresizingMaskIntoConstraints = false
        authorAvatar.clipsToBounds = true
        authorAvatar.layer.cornerRadius = 45 / 2
        authorAvatar.layer.borderColor = UIColor.systemPurple.cgColor
        authorAvatar.layer.borderWidth = 2
        authorAvatar.image = UIImage(systemName: "person.fill")?.withRenderingMode(.alwaysTemplate)
        authorAvatar.tintColor = .systemPurple
        
        NSLayoutConstraint.activate([
            authorAvatar.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: verticalPadding),
            authorAvatar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            authorAvatar.widthAnchor.constraint(equalToConstant: 45),
            authorAvatar.heightAnchor.constraint(equalToConstant: 45)
            
        ])
    }
    
    private func configureAuthorName() {
        contentView.addSubview(authorNameLabel)
        
        NSLayoutConstraint.activate([
            authorNameLabel.topAnchor.constraint(equalTo: authorAvatar.topAnchor),
            authorNameLabel.leadingAnchor.constraint(equalTo: authorAvatar.trailingAnchor, constant: horizontalPadding),
            authorNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
            
        ])
    }
    
    private func configureReviewDate() {
        contentView.addSubview(reviewDateLabel)
        
        NSLayoutConstraint.activate([
            reviewDateLabel.topAnchor.constraint(equalTo: authorNameLabel.bottomAnchor),
            reviewDateLabel.leadingAnchor.constraint(equalTo: authorAvatar.trailingAnchor, constant: horizontalPadding),
            reviewDateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    private func configureStarRating() {
        let hostedStarsView = UIHostingController(rootView: starsView)
        contentView.addSubview(hostedStarsView.view)
        hostedStarsView.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hostedStarsView.view.centerYAnchor.constraint(equalTo: authorNameLabel.centerYAnchor),
            hostedStarsView.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
        ])
    }
    
    private func configureContent() {
        contentView.addSubview(contentLabel)
        NSLayoutConstraint.activate([
            contentLabel.topAnchor.constraint(equalTo: authorAvatar.bottomAnchor, constant: verticalPadding),
            contentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    private func configureSeeMoreOrLessBtn() {
        contentView.addSubview(seeMoreOrLessBtn)
        seeMoreOrLessBtn.translatesAutoresizingMaskIntoConstraints = false
        seeMoreOrLessBtn.configuration = .tinted()
        seeMoreOrLessBtn.configuration?.cornerStyle = .medium
        seeMoreOrLessBtn.configuration?.baseBackgroundColor = .systemPurple
        seeMoreOrLessBtn.configuration?.baseForegroundColor = .systemPurple
        seeMoreOrLessBtn.configuration?.title = "See more"
        seeMoreOrLessBtn.addTarget(self, action: #selector(updateContentLabel), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            seeMoreOrLessBtn.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: verticalPadding + 4),
            seeMoreOrLessBtn.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            seeMoreOrLessBtn.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -(verticalPadding + 4))
        ])
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // Convert the point to the button's coordinate system
        let buttonPoint = seeMoreOrLessBtn.convert(point, from: self)
        
        // If the point is within the button, return the button
        if seeMoreOrLessBtn.bounds.contains(buttonPoint) {
            return seeMoreOrLessBtn
        }
        
        // Otherwise, default to the standard hit testing
        return super.hitTest(point, with: event)
    }
    
    @objc func updateContentLabel() {
        isContentExpanded.toggle()
        contentLabel.numberOfLines = isContentExpanded ? 0 : 5
        contentLabel.lineBreakMode = isContentExpanded ? .byWordWrapping : .byTruncatingTail
        seeMoreOrLessBtn.configuration?.title = "See \(isContentExpanded ? "less" : "more")"
        
        delegate?.reviewCellDidPerformAction()
    }
}

#Preview {
    let cell = ReviewCell()
    cell.set(review: WrappedMovieDetail.test.movieReview.reviews.first!, networkManager: NetworkManagerImpl())
    
    return cell
}
