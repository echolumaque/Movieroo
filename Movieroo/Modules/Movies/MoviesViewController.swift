//
//  MoviesViewController.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/24/25.
//

import UIKit

protocol MoviesView: AnyObject {
    var presenter: MoviesPresenter? { get set }
    func update(result: Result<Movie, NetworkingError>)
}

class MoviesViewController: UIViewController, MoviesView {
    var movie: Movie!
    
    var collectionView: UICollectionView!
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
        collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UIHelper.createVerticalCompositionalLayout(
                itemSize: size,
                groupSize: size,
                interGroupSpacing: 20
            )
        )
        
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
        collectionView.register(MovieCell.self, forCellWithReuseIdentifier: MovieCell.reuseID)
        
        view.addSubview(collectionView)
        collectionView.pinToEdges(of: view)
    }
    
    private func fetchTrendingMovies() {
        Task {
            showLoadingView()
            await presenter?.fetchTrendingMovies()
        }
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, MovieResult>(collectionView: collectionView) { collectionView, indexPath, movie in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.reuseID, for: indexPath) as? MovieCell
            cell?.set(movie: movie)
            
            return cell
        }
    }
    
    override func updateContentUnavailableConfiguration(using state: UIContentUnavailableConfigurationState) {
        if let movie, !movie.movieResults.isEmpty {
            contentUnavailableConfiguration = nil
        } else {
            var config = UIContentUnavailableConfiguration.empty()
            config.image = UIImage(systemName: "video.slash.fill")
            config.text = "No movies"
            config.secondaryText = "There are no movies. Please try again later."
            contentUnavailableConfiguration = config
        }
    }
    
    func update(result: Result<Movie, NetworkingError>) {
        dismissLoadingView()
        DispatchQueue.main.async {
            switch result {
            case .success(let movie):
                self.movie = movie
                self.updateDataSource(movieResult: movie.movieResults)
                self.setNeedsUpdateContentUnavailableConfiguration()
                
            case .failure(_):
                self.setNeedsUpdateContentUnavailableConfiguration()
            }
        }
    }
    
    private func updateDataSource(movieResult: [MovieResult]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, MovieResult>()
        snapshot.appendSections([.main])
        snapshot.appendItems(movie.movieResults)
        DispatchQueue.main.async { self.dataSource.apply(snapshot, animatingDifferences: true) }
    }
}

extension MoviesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}

extension MoviesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter?.showMovieDetail(for: movie.movieResults[indexPath.item])
    }
}

#Preview {
    MoviesViewController()
}
