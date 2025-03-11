//
//  BookmarkedMovieDetailViewController.swift
//  Movieroo
//
//  Created by Echo Lumaque on 3/7/25.
//

import UIKit
import WebKit

class BookmarkedMovieDetailViewController: BindableViewController {
    weak var dismissDelegate: DismissDelegate?
    private let networkManager: NetworkManager
    private let vm: BookmarkedMovieDetailViewModel
    
    private let horizontalPadding: CGFloat = 16
    private let verticalPadding: CGFloat = 8
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let heroView = UIView()
    private let posterImageView = MovierooImageView()
    private let trailerView = WKWebView()
    
    private let movieTitle = DynamicLabel(font: UIFont.preferredFont(for: .title1, weight: .bold), numberOfLines: 2)
    
    private let movieSubtitles = DynamicLabel(
        textColor: .secondaryLabel,
        font: UIFont.preferredFont(forTextStyle: .subheadline),
        minimumScaleFactor: 0.75
    )
    
    private let overview = DynamicLabel(font: UIFont.preferredFont(forTextStyle: .body), numberOfLines: 0)
    
    private let ratingDivider = Divider()
    
    private let recommendationLabel = DynamicLabel(textColor: .secondaryLabel, font: UIFont.preferredFont(for: .title3, weight: .bold))
    
    private var recommendationCollectionView: HorizontalCompositionalUICollectionView!
    private var recommendationDataSource: UICollectionViewDiffableDataSource<Section, MovieResult>!
    private let collectionViewDivider = Divider()
    
    private let reviewTableView = DynamicTableView()
    private var reviewDataSource: UITableViewDiffableDataSource<Section, Review>!
    
    init(networkManager: NetworkManager, vm: BookmarkedMovieDetailViewModel) {
        self.networkManager = networkManager
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureScrollView()
        configureHeroView()
        configureTitle()
        configureSubtitle()
        configureOverview()
        configureRecommendationsHeader()
        configureRecommendations()
        configureReviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task { [weak self] in await self?.vm.onAppear() }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        dismissDelegate?.onDismiss()
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        bind(vm.$isFavoriteMovie) { [weak self] in
            self?.navigationItem.rightBarButtonItems?[0].image = UIImage(systemName: $0 ? "bookmark.fill" : "bookmark")
        }
        
        bind(vm.$wrappedMovieDetail) { [weak self] wrappedMovieDetail in
            guard let wrappedMovieDetail else { return }
            self?.setProperties(wrappedMovieDetail: wrappedMovieDetail)
        }
        
        bind(vm.$movieRecommendations) { [weak self] in
            var snapshot = NSDiffableDataSourceSnapshot<Section, MovieResult>()
            snapshot.appendSections([.main])
            snapshot.appendItems($0)
            DispatchQueue.main.async { self?.recommendationDataSource.apply(snapshot, animatingDifferences: true) }
        }
        
        bind(vm.$movieReviews) { [weak self] in
            var snapshot = NSDiffableDataSourceSnapshot<Section, Review>()
            snapshot.appendSections([.main])
            snapshot.appendItems($0)
            DispatchQueue.main.async { self?.reviewDataSource.apply(snapshot, animatingDifferences: true) }
        }
    }
    
    private func setProperties(wrappedMovieDetail: WrappedMovieDetail) {
        // MARK: - Navigation bar
        var rightBarButtonItems: [UIBarButtonItem] = []
        let bookmarkIcon = vm.isFavoriteMovie ? "bookmark.fill" : "bookmark"
        let bookmarkButton = UIBarButtonItem(image: UIImage(systemName: bookmarkIcon), primaryAction: UIAction { [weak self] _ in
            guard let self else { return }
            vm.upsertFavoriteMovie()
        })
        rightBarButtonItems.append(bookmarkButton)
        
        if let homePageUrl = URL(string: wrappedMovieDetail.movieDetail.homepage) {
            let homePageButton = UIBarButtonItem(image: UIImage(systemName: "iphone.badge.play"), primaryAction: UIAction { [weak self] _ in
                self?.presentSafariVC(with: homePageUrl)
            })
            
            rightBarButtonItems.append(homePageButton)
        }
        
        navigationItem.rightBarButtonItems = rightBarButtonItems
        
        // MARK: - Hero
        let hasYoutubeVideo = wrappedMovieDetail.movieVideo.hasYoutubeVideo
        let filteredVideos = wrappedMovieDetail.movieVideo.videos.filter { $0.site == "YouTube" && $0.type == "Trailer" }
        if hasYoutubeVideo && !filteredVideos.isEmpty {
            if let randomUrl = filteredVideos.randomElement(), let ytVideoUrl = URL(string: "https://www.youtube.com/embed/\(randomUrl.key)") {
                trailerView.load(URLRequest(url: ytVideoUrl))
            }
        } else {
            Task { [weak self] in
                self?.posterImageView.contentMode = .scaleAspectFit
                self?.posterImageView.image = await self?.networkManager.downloadImage(from: "https://image.tmdb.org/t/p/w1280\(wrappedMovieDetail.movieDetail.backdropPath).jpg")
            }
        }
       
        heroView.addSubview(hasYoutubeVideo ? trailerView : posterImageView)
        if hasYoutubeVideo { trailerView.pinToEdges(of: heroView) }
        else { posterImageView.pinToEdges(of: heroView) }
        
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
    
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        title = "Movie Details"
    }
    
    private func configureScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.pinToEdges(of: view)
        contentView.pinToEdges(of: scrollView)
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        
        contentView.addSubviews(
            heroView,
            movieTitle,
            movieSubtitles,
            overview
        )
    }
    
    private func configureHeroView() {
        heroView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            heroView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            heroView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            heroView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            heroView.heightAnchor.constraint(equalTo: heroView.widthAnchor, multiplier: 2.0/3.0)
        ])
    }
    
    private func configureTitle() {
        NSLayoutConstraint.activate([
            movieTitle.topAnchor.constraint(equalTo: heroView.bottomAnchor, constant: verticalPadding),
            movieTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            movieTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
        ])
    }
    
    private func configureSubtitle() {
        NSLayoutConstraint.activate([
            movieSubtitles.topAnchor.constraint(equalTo: movieTitle.bottomAnchor, constant: verticalPadding),
            movieSubtitles.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            movieSubtitles.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
        ])
    }
    
    private func configureOverview() {
        let overviewDivider = Divider()
        contentView.addSubview(overviewDivider)
        
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
    
    private func configureRecommendationsHeader() {
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
    
    private func configureRecommendations() {
        let collectionLayoutSize = NSCollectionLayoutSize(widthDimension: .absolute(154), heightDimension: .fractionalHeight(1.0))
        recommendationCollectionView = HorizontalCompositionalUICollectionView(
            itemSize: collectionLayoutSize,
            groupSize: collectionLayoutSize,
            interGroupSpacing: 20,
            horizontalCompositionalDelegate: self
        )
        recommendationCollectionView.delegate = self
        recommendationCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
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
        
        let recommendationCell = UICollectionView.CellRegistration<RecommendationCell, MovieResult> { [weak self] cell, indexPath, movieResult in
            guard let self else { return }
            cell.set(movieResult: movieResult, networkManager: networkManager)
        }
        
        recommendationDataSource = UICollectionViewDiffableDataSource(collectionView: recommendationCollectionView) { collectionView, indexPath, movieResult in
            return collectionView.dequeueConfiguredReusableCell(using: recommendationCell, for: indexPath, item: movieResult)
        }
    }
    
    private func configureReviews() {
        contentView.addSubview(reviewTableView)
        reviewTableView.translatesAutoresizingMaskIntoConstraints = false
        reviewTableView.estimatedRowHeight = 80
        reviewTableView.rowHeight = UITableView.automaticDimension
        reviewTableView.delegate = self
        reviewTableView.tableFooterView = UIView(frame: .zero)
        reviewTableView.register(ReviewCell.self, forCellReuseIdentifier: ReviewCell.reuseID)
        reviewTableView.isScrollEnabled = false

        NSLayoutConstraint.activate([
            reviewTableView.topAnchor.constraint(equalTo: collectionViewDivider.bottomAnchor, constant: verticalPadding),
            reviewTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            reviewTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
            reviewTableView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -verticalPadding)
        ])
        
        reviewDataSource = UITableViewDiffableDataSource(tableView: reviewTableView) { [weak self] tableView, indexPath, review in
            guard let self else { return nil }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: ReviewCell.reuseID, for: indexPath) as? ReviewCell
            cell?.set(review: review, networkManager: networkManager)
            cell?.selectionStyle = .none
            cell?.delegate = self
            
            return cell
        }
    }
    
    @objc private func getMoreReviews() {
        vm.reviewsPage += 1
        Task { [weak self] in try await self?.vm.fetchMovieReviews() }
    }
}

extension BookmarkedMovieDetailViewController: UICollectionViewDelegate, HorizontalCompositionalUICollectionViewDelegate {
    func collectionViewDidInvalidateVisibleItems(visibleItems: [any NSCollectionLayoutVisibleItem], contentOffset: CGPoint, environment: any NSCollectionLayoutEnvironment) {
        guard recommendationCollectionView.numberOfSections > 0 else { return }
        let totalItems = recommendationCollectionView.numberOfItems(inSection: 0)
        guard totalItems > 0 else { return }
        
        let targetIndexPath = IndexPath(item: totalItems - 1, section: 0)
        if recommendationCollectionView.indexPathsForVisibleItems.contains(targetIndexPath) {
            guard !vm.hasTriggeredLastVisibleRecommendation, vm.recommendationsPage > 0, vm.recommendationsPage <= 500 else {
                vm.hasTriggeredLastVisibleRecommendation = false
                return
            }
            
            vm.recommendationsPage += 1
            vm.hasTriggeredLastVisibleRecommendation = true
            Task { [weak self] in try await self?.vm.fetchMovieRecommendations() }
            
        } else {
            vm.hasTriggeredLastVisibleRecommendation = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedMovie = vm.movieRecommendations[indexPath.item]
        vm.movieRecommendations.removeAll()
        vm.movieReviews.removeAll()
        vm.selectedMovie = selectedMovie
        Task { [weak self] in try await self?.vm.fetchMovieDetails() }
    }
}

extension BookmarkedMovieDetailViewController: UITableViewDelegate, ReviewCellDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let seeMoreReviewsBtn = UIButton()
        seeMoreReviewsBtn.configuration = .filled()
        seeMoreReviewsBtn.configuration?.cornerStyle = .medium
        seeMoreReviewsBtn.configuration?.baseBackgroundColor = .systemPurple
        seeMoreReviewsBtn.configuration?.baseForegroundColor = .white
        seeMoreReviewsBtn.configuration?.title = "See more reviews"
        seeMoreReviewsBtn.addTarget(self, action: #selector(getMoreReviews), for: .touchUpInside)
        
        return seeMoreReviewsBtn
    }
    
    func reviewCellDidPerformAction() {
        reviewTableView.beginUpdates()
        reviewTableView.endUpdates()
    }
}
