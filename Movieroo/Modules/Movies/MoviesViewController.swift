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
//    func update(result: Result<[MovieResult], NetworkingError>)
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
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        fetchTrendingMovies()
//    }
    
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
        Task {
            showLoadingView()
            await presenter?.fetchTrendingMovies(page: page)
            dismissLoadingView()
        }
    }
    
    func updateUI() {
        DispatchQueue.main.async {
            self.updateDataSource(movieResult: self.presenter?.movieResults ?? [])
            self.setNeedsUpdateContentUnavailableConfiguration()
        }
    }
    
    private var hasTriggeredSecondToLastVisible = false
    private var page = 1
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
        guard movieCollectionView.numberOfSections > 0 else { return }
        // Get the total number of items in section 0.
        let totalItems = movieCollectionView.numberOfItems(inSection: 0)
        
        // Ensure there's at least 2 items, otherwise the second-to-last doesn't exist.
        guard totalItems > 1 else { return }
        
        // Calculate the target indexPath for the second-to-last item.
        let targetIndexPath = IndexPath(item: totalItems - 1, section: 0)
        
        // Check if the target indexPath is among the visible items.
        
        if movieCollectionView.indexPathsForVisibleItems.contains(targetIndexPath) {
            guard !hasTriggeredSecondToLastVisible, page > 0, page <= 500 else {
                hasTriggeredSecondToLastVisible = false
                return
            }
            
            page += 1
            hasTriggeredSecondToLastVisible = true
            fetchTrendingMovies()
        } else {
            // Optionally reset the flag if the target item scrolls offscreen.
            hasTriggeredSecondToLastVisible = false
        }
    }
}

#Preview {
    MoviesViewController()
}
