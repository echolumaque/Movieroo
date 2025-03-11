//
//  MoviesViewController.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/24/25.
//

import UIKit
import Swinject

protocol MoviesView: AnyObject {
    var presenter: MoviesPresenter? { get set }
    func updateDataSource(movieResult: [MovieResult])
    var isSearching: Bool { get set }
}

class MoviesViewController: UIViewController, MoviesView {
    let container: Resolver
    var presenter: MoviesPresenter?
    var isSearching = false
    var movieCollectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, MovieResult>!
    
    init(container: Resolver) {
        self.container = container
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        configureSearchController()
        configureCollectionView()
        fetchTrendingMovies()
    }
    
    override func updateContentUnavailableConfiguration(using state: UIContentUnavailableConfigurationState) {
        guard let presenter else {
            contentUnavailableConfiguration = nil
            return
        }
        
        if presenter.movieResults.isEmpty {
            var config = UIContentUnavailableConfiguration.empty()
            config.image = UIImage(systemName: "video.slash.fill")
            config.text = "No movies"
            config.secondaryText = "There are no movies. Please try again later."
            contentUnavailableConfiguration = config
        } else if isSearching && presenter.filteredMovieResults.isEmpty {
            contentUnavailableConfiguration = UIContentUnavailableConfiguration.search()
        } else {
            contentUnavailableConfiguration = nil
        }
    }
    
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), primaryAction: UIAction { [weak self] _ in
            guard let self else { return }
            presenter?.showGenreSheet()
        })
    }
    
    private func configureSearchController() {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search for a movie"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func configureCollectionView() {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
        movieCollectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UIHelper.createVerticalCompositionalLayout(
                itemSize: size,
                groupSize: size,
                interGroupSpacing: 20
            )
        )
        
        movieCollectionView.delegate = self
        view.addSubview(movieCollectionView)
        movieCollectionView.pinToEdges(of: view)
        
        let movieCell = UICollectionView.CellRegistration<MovieCell, MovieResult> { [weak self] cell, indexPath, movie in
            guard let self else { return }
            cell.set(movie: movie, networkManager: container.resolve(NetworkManager.self))
        }
        dataSource = UICollectionViewDiffableDataSource<Section, MovieResult>(collectionView: movieCollectionView) { collectionView, indexPath, movie in
            return collectionView.dequeueConfiguredReusableCell(using: movieCell, for: indexPath, item: movie)
        }
    }
    
    func updateDataSource(movieResult: [MovieResult]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, MovieResult>()
        snapshot.appendSections([.main])
        snapshot.appendItems(movieResult)
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: true)
            self.setNeedsUpdateContentUnavailableConfiguration()
        }
        
    }
    
    private func fetchTrendingMovies() {
        showLoadingView()
        Task { [weak self] in await self?.presenter?.fetchTrendingMovies(page: self?.presenter?.page ?? -1) }
        dismissLoadingView()
    }
}

extension MoviesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let presenter else { return }
        guard let filter = searchController.searchBar.text, !filter.isEmpty else {
            isSearching = false
            presenter.filteredMovieResults.removeAll()
            updateDataSource(movieResult: presenter.movieResults)
            return
        }
        
        isSearching = true
        presenter.filteredMovieResults = presenter.movieResults.filter { $0.title.containsInsensitive(filter) }
        updateDataSource(movieResult: presenter.filteredMovieResults)
        setNeedsUpdateContentUnavailableConfiguration()
    }
}

extension MoviesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let presenter else { return }
        presenter.showMovieDetail(for: presenter.movieResults[indexPath.item])
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let presenter, !isSearching else { return }
        guard movieCollectionView.numberOfSections > 0 else { return }
        let totalItems = movieCollectionView.numberOfItems(inSection: 0)
        guard totalItems > 1 else { return }
        
        let targetIndexPath = IndexPath(item: totalItems - 1, section: 0)
        if movieCollectionView.indexPathsForVisibleItems.contains(targetIndexPath) {
            guard !presenter.hasTriggeredSecondToLastVisible, presenter.page > 0, presenter.page <= 500 else {
                presenter.hasTriggeredSecondToLastVisible = false
                return
            }
            
            presenter.page += 1
            presenter.hasTriggeredSecondToLastVisible = true
            fetchTrendingMovies()
        } else {
            presenter.hasTriggeredSecondToLastVisible = false
        }
    }
}

#Preview {
    MoviesViewController(container: Container())
}
