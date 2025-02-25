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
    
    convenience init(review: Review) {
        self.init(style: .default, reuseIdentifier: "ReviewCell")
        set(review: review)
    }
    
    func set(review: Review) {
        if let avatarPath = review.authorDetails?.avatarPath {
            Task {
                authorAvatar.image =  await NetworkManager.shared.downloadImage(from: "https://image.tmdb.org/t/p/w45\(avatarPath)")
            }
        }
        
        authorNameLabel.text = review.author
        
        reviewDateLabel.text = review.updatedAt.formatISO8601DateToLocale
        
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
    ReviewCell(
        review: Review(
            author: "r96sk",
            authorDetails: Movieroo.AuthorDetails(
                name: "",
                username: "r96sk",
                avatarPath: Optional(
                    "/mwR7rFHoDcobAx1i61I3skzMW3U.jpg"
                ),
                rating: 8
            ),
            content: "Rubbish poster aside, <em>\'Mufasa: The Lion King\'</em> is a success.\r\n\r\n\nI can\'t overlook that poster, how amateur can you get - it genuinely looks like something I\'d whip up seconds before the deadline. Thankfully, the movie itself is very good, it\'s one I enjoyed quite a bit. The animation is class, the lions look amazingly majestic. I will say the white ones look a bit iffy, but that\'s nothing even close to a big issue.\r\n\r\nThe voice cast are all perfectly good. Aaron Pierre, Kelvin Harrison Jr. (only now realising his character wasn\'t called Tucker... bit embarrassing on my part), John Kani et al. all merit props. The standouts for me, however, are Mads Mikkelsen and Lennie James - two actors I do love watching (or listening to, in this case), admittedly.\r\n\r\nMusic-wise, it\'s not the strongest - I can\'t recall any of the songs, to be honest. That\'s not actually a terrible thing though, as it means none of the musical numbers grated on me either - and that\'s always a win in my books. Elsewhere, Timon & Pumbaa are unamusing and wasted, but at the same time are unnecessarily forced into this prequel/sequel.\r\n\r\nObviously, this still falls far adrift of the beloved original animated film. Nevertheless, I\'ll hold it in higher esteem than the 2019 remake, even if I didn\'t overly mind that one to be fair. Oh, lastly, nice touch dedicating this to James Earl Jones at the get-go - was expecting it at the end.",
            createdAt: "2024-12-23T18:13:28.704Z",
            id: "6769a84846a5a438790b24d1",
            updatedAt: "2024-12-23T18:13:28.807Z",
            url: "https://www.themoviedb.org/review/6769a84846a5a438790b24d1"
        )
    )
}
