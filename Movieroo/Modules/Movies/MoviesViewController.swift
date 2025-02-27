//
//  MoviesViewController.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/24/25.
//

import UIKit

protocol MoviesView: AnyObject {
    var presenter: MoviesPresenter? { get set }
    func updateUI()
}

class MoviesViewController: UIViewController, MoviesView {
    var movieCollectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, MovieResult>!
    
    var presenter: MoviesPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        configureViewController()
        configureSearchController()
        configureCollectionView()
        fetchTrendingMovies()
        configureDataSource()
    }
    
    override func updateContentUnavailableConfiguration(using state: UIContentUnavailableConfigurationState) {
        if let movieResults = presenter?.movieResults, !movieResults.isEmpty {
            contentUnavailableConfiguration = nil
        } else {
            var config = UIContentUnavailableConfiguration.empty()
            config.image = UIImage(systemName: "video.slash.fill")
            config.text = "No movies"
            config.secondaryText = "There are no movies. Please try again later."
            contentUnavailableConfiguration = config
        }
    }
    
    private func configureViewController() {
        view.backgroundColor = .systemBackground
    }
    
    private func configureSearchController() {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search for a category"
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
        movieCollectionView.register(MovieCell.self, forCellWithReuseIdentifier: MovieCell.reuseID)
        
        view.addSubview(movieCollectionView)
        movieCollectionView.pinToEdges(of: view)
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, MovieResult>(collectionView: movieCollectionView) { collectionView, indexPath, movie in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.reuseID, for: indexPath) as? MovieCell
            cell?.set(movie: movie)
            
            return cell
        }
    }
    
    private func updateDataSource(movieResult: [MovieResult]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, MovieResult>()
        snapshot.appendSections([.main])
        snapshot.appendItems(movieResult)
        DispatchQueue.main.async { self.dataSource.apply(snapshot, animatingDifferences: true) }
    }
    
    private func fetchTrendingMovies() {
        guard let presenter else { return }
        
        showLoadingView()
        Task { await presenter.fetchTrendingMovies(page: presenter.page) }
        dismissLoadingView()
    }
    
    func updateUI() {
        DispatchQueue.main.async {
            self.updateDataSource(movieResult: self.presenter?.movieResults ?? [])
            self.setNeedsUpdateContentUnavailableConfiguration()
        }
    }
}

extension MoviesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}

extension MoviesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let presenter else { return }
        presenter.showMovieDetail(for: presenter.movieResults[indexPath.item])
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let presenter else { return }
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
    MoviesViewController()
}
