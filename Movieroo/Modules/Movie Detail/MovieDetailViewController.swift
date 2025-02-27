//
//  MovieDetailViewController.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/24/25.
//

import UIKit
import SwiftUI

protocol MovieDetailView: AnyObject {
    var presenter: MovieDetailPresenter? { get set }
    func updateMovieDetails(_ result: Result<WrappedMovieDetail, NetworkingError>)
}

class MovieDetailViewController: UIViewController, MovieDetailView {
    var presenter: (any MovieDetailPresenter)?
    
    private let horizontalPadding: CGFloat = 16
    private let verticalPadding: CGFloat = 8
    
    private var movieId: Int!
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let posterImageView = MovierooImageView()
    
    private let movieTitle = DynamicLabel(font: UIFont.preferredFont(for: .title1, weight: .bold), numberOfLines: 2)
    
    private let movieSubtitles = DynamicLabel(
        textColor: .secondaryLabel,
        font: UIFont.preferredFont(forTextStyle: .subheadline),
        minimumScaleFactor: 0.75
    )
    
    private let overview = DynamicLabel(font: UIFont.preferredFont(forTextStyle: .body), numberOfLines: 0)
    
    private let ratingDivider = Divider()
    
    private let recommendationLabel = DynamicLabel(textColor: .secondaryLabel, font: UIFont.preferredFont(for: .title3, weight: .bold))
    
    private var recommendationCollectionView: UICollectionView!
    private var recommendationDataSource: UICollectionViewDiffableDataSource<Section, MovieResult>!
    private let collectionViewDivider = Divider()
    private let reviewTableView = DynamicTableView()
    
//    init(
//        movieDetail: MovieDetail? = nil,
//        movieReview: MovieReview? = nil,
//        movieCertification: MovieCertification? = nil,
//        movieRecommendations: [MovieResult] = []
//    ) {
//        super.init(nibName: nil, bundle: nil)
//        self.movieDetail = movieDetail
//        self.movieReview = movieReview
//        self.movieCertification = movieCertification
//        self.movieRecommendations = movieRecommendations
//    }
    
    init(movieId: Int) {
        super.init(nibName: nil, bundle: nil)
        self.movieId = movieId
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureScrollView()
        configurePosterView()
        configureTitle()
        configureSubtitle()
        configureOverview()
        configureRecommendationsHeader()
        configureRecommendations()
        configureReviews()
        if Environment.isForPreview { return }
        getMovieDetailAndReview()
    }
    
    func set(wrappedMovieDetail: WrappedMovieDetail) {
        // MARK: - Homepage
        if let homePageUrl = URL(string: wrappedMovieDetail.movieDetail.homepage) {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "iphone.badge.play"), primaryAction: UIAction { [weak self] _ in
                self?.presentSafariVC(with: homePageUrl)
            })
        }
        
        // MARK: - Poster
        Task {
            posterImageView.image = await NetworkManager.shared.downloadImage(from: "https://image.tmdb.org/t/p/w1280\(wrappedMovieDetail.movieDetail.backdropPath).jpg")
        }
        
        // MARK: - Title
        movieTitle.text = wrappedMovieDetail.movieDetail.title
        
        // MARK: - Subtitle
        let genres = wrappedMovieDetail.movieDetail.genres.map { $0.name }.joined(separator: ", ")
        let certification = wrappedMovieDetail.movieCertification
            .resultElement
            .first(where: { $0.iso3166_1 == "US" })?
            .releaseDates.first?
            .certification ?? ""
        
        var parsedString: [String] = []
        if !certification.isEmpty { parsedString.append(certification) }
        parsedString.append(contentsOf: [genres, wrappedMovieDetail.movieDetail.runtime.timeString])
        
        movieSubtitles.text = parsedString.joined(separator: " • ")
        
        // MARK: - Overview
        overview.text = wrappedMovieDetail.movieDetail.overview
        
        DispatchQueue.main.async {
            self.reviewTableView.reloadData()
            self.reviewTableView.invalidateIntrinsicContentSize()
        }
    }
    
    func configureViewController() {
        view.backgroundColor = .systemBackground
        title = "Movie Details"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissVC))
    }
    
    func configureScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.pinToEdges(of: view)
        contentView.pinToEdges(of: scrollView)
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        
        contentView.addSubviews(
            posterImageView,
            movieTitle,
            movieSubtitles,
            overview
        )
    }
    
    func configurePosterView() {
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        posterImageView.contentMode = .scaleAspectFit
//        if Environment.isForPreview {
//            Task {
//                posterImageView.image = await NetworkManager.shared.downloadImage(from: "https://image.tmdb.org/t/p/w1280\(movieDetail.backdropPath).jpg")
//            }
//        }

        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            posterImageView.heightAnchor.constraint(equalTo: posterImageView.widthAnchor, multiplier: 2.0/3.0)
        ])
    }
    
    func configureTitle() {
        movieTitle.translatesAutoresizingMaskIntoConstraints = false
//        if Environment.isForPreview { movieTitle.text = movieDetail.title }
        
        NSLayoutConstraint.activate([
            movieTitle.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: verticalPadding),
            movieTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            movieTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
        ])
    }
    
    func configureSubtitle() {
        movieSubtitles.translatesAutoresizingMaskIntoConstraints = false
//        if Environment.isForPreview {
//            let genres = movieDetail.genres.map { $0.name }.joined(separator: ", ")
//            let certification = movieCertification
//                .resultElement
//                .first(where: { $0.iso3166_1 == "US" })?
//                .releaseDates.first?
//                .certification ?? ""
//            
//            movieSubtitles.text = "\(certification) • \(genres) • \(movieDetail.runtime.timeString)"
//        }
        
        NSLayoutConstraint.activate([
            movieSubtitles.topAnchor.constraint(equalTo: movieTitle.bottomAnchor, constant: verticalPadding),
            movieSubtitles.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            movieSubtitles.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
        ])
    }
    
    func configureOverview() {
        let overviewDivider = Divider()
        contentView.addSubview(overviewDivider)
        
//        if Environment.isForPreview { overview.text = movieDetail.overview  }
        
        NSLayoutConstraint.activate([
            overviewDivider.topAnchor.constraint(equalTo: movieSubtitles.bottomAnchor, constant: verticalPadding),
            overviewDivider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            overviewDivider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
            overviewDivider.heightAnchor.constraint(equalToConstant: 0.5),
            
            overview.topAnchor.constraint(equalTo: overviewDivider.bottomAnchor, constant: verticalPadding),
            overview.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            overview.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding)
        ])
    }
    
    func configureRecommendationsHeader() {
        let recommendationDivider = Divider()
        recommendationLabel.text = "Also Watch:"
        
        contentView.addSubviews(recommendationDivider, recommendationLabel)
        NSLayoutConstraint.activate([
            recommendationDivider.topAnchor.constraint(equalTo: overview.bottomAnchor, constant: verticalPadding),
            recommendationDivider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            recommendationDivider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
            recommendationDivider.heightAnchor.constraint(equalToConstant: 0.5),
            
            recommendationLabel.topAnchor.constraint(equalTo: recommendationDivider.bottomAnchor, constant: verticalPadding),
            recommendationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            recommendationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
        ])
    }
    
    func configureRecommendations() {
        let collectionLayoutSize = NSCollectionLayoutSize(widthDimension: .absolute(154), heightDimension: .fractionalHeight(1.0))
        recommendationCollectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UIHelper.createHorizontalCompositionalLayout(
                itemSize: collectionLayoutSize,
                groupSize: collectionLayoutSize,
                interGroupSpacing: 20
            )
        )
        recommendationCollectionView.translatesAutoresizingMaskIntoConstraints = false
        recommendationCollectionView.register(RecommendationCell.self, forCellWithReuseIdentifier: RecommendationCell.reuseID)
        
        contentView.addSubviews(recommendationCollectionView, collectionViewDivider)
        NSLayoutConstraint.activate([
            recommendationCollectionView.topAnchor.constraint(equalTo: recommendationLabel.bottomAnchor, constant: verticalPadding),
            recommendationCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            recommendationCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
            recommendationCollectionView.heightAnchor.constraint(equalToConstant: 300),
            
            collectionViewDivider.topAnchor.constraint(equalTo: recommendationCollectionView.bottomAnchor, constant: verticalPadding),
            collectionViewDivider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            collectionViewDivider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
            collectionViewDivider.heightAnchor.constraint(equalToConstant: 0.5)
        ])
        
        configureRecommendationDataSource()
    }
    
    func configureReviews() {
        contentView.addSubview(reviewTableView)
        reviewTableView.translatesAutoresizingMaskIntoConstraints = false
        reviewTableView.estimatedRowHeight = 80
        reviewTableView.rowHeight = UITableView.automaticDimension
        reviewTableView.delegate = self
        reviewTableView.dataSource = self
        reviewTableView.tableFooterView = UIView(frame: .zero)
        reviewTableView.register(ReviewCell.self, forCellReuseIdentifier: ReviewCell.reuseID)
        reviewTableView.isScrollEnabled = false

        NSLayoutConstraint.activate([
            reviewTableView.topAnchor.constraint(equalTo: collectionViewDivider.bottomAnchor, constant: verticalPadding),
            reviewTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            reviewTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            reviewTableView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -verticalPadding)
        ])
    }
    
    private func configureRecommendationDataSource() {
        recommendationDataSource = UICollectionViewDiffableDataSource<Section, MovieResult>(collectionView: recommendationCollectionView) { collectionView, indexPath, movieResult in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendationCell.reuseID, for: indexPath) as? RecommendationCell
            cell?.set(movieResult: movieResult)
            
            return cell
        }
    }
    
    private func updateRecommendationDataSource(movieRecommendations: [MovieResult]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, MovieResult>()
        snapshot.appendSections([.main])
        snapshot.appendItems(movieRecommendations)
        recommendationDataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func getMovieDetailAndReview() {
        Task { try await presenter?.fetchMovieDetals(for: movieId) }
    }
    
    func updateMovieDetails(_ result: Result<WrappedMovieDetail, NetworkingError>) {
        switch result {
        case .success(let wrappedMovieDetail):
            DispatchQueue.main.async {
                self.set(wrappedMovieDetail: wrappedMovieDetail)
                self.updateRecommendationDataSource(movieRecommendations: wrappedMovieDetail.movieRecommendations)
            }
            
        case .failure(let failure):
            print("Network error: \(failure)")
        }
    }
}

extension MovieDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Environment.isForPreview {
            return WrappedMovieDetail.test.movieReview.reviews.count
        } else {
            
            guard let presenter, let wrappedMovieDetail = presenter.wrappedMovieDetail else {
                return 0
            }
            
            return wrappedMovieDetail.movieReview.reviews.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if Environment.isForPreview {
            let reviews = WrappedMovieDetail.test.movieReview.reviews
            let cell = tableView.dequeueReusableCell(withIdentifier: ReviewCell.reuseID) as! ReviewCell
            let review = reviews[indexPath.row]
            cell.set(review: review)
            
            return cell
        } else {
            guard let presenter, let wrappedMovieDetail = presenter.wrappedMovieDetail else {
                return UITableViewCell(frame: .zero)
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: ReviewCell.reuseID) as! ReviewCell
            let review = wrappedMovieDetail.movieReview.reviews[indexPath.row]
            cell.set(review: review)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let presenter, let wrappedMovieDetail = presenter.wrappedMovieDetail else { return }
        
        let reviewUrl = wrappedMovieDetail.movieReview.reviews[indexPath.row].url
        presentSafariVC(with: URL(string: reviewUrl)!)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

#Preview {
    let vc = MovieDetailViewController(movieId: 27205)
    vc.viewDidLoad()
    vc.updateMovieDetails(.success(WrappedMovieDetail.test))
    
    return vc
}
