//
//  BookmarksViewController.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/24/25.
//

import UIKit

class BookmarksViewController: BindableViewController {
    private var favoritesCollectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, MovieResult>!
    weak var dismissDelegate: DismissDelegate?
    private let vm: BookmarksViewModel
    
    init(vm: BookmarksViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureVC()
        configureCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        vm.onAppear()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        dismissDelegate?.onDismiss()
    }
    
    private func configureVC() {
        view.backgroundColor = .systemBackground
        title = "Bookmarks"
    }
    
    private func configureCollectionView() {
        favoritesCollectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UIHelper.listLayout(
                interGroupSpacing: 20,
                trailingAction: collectionViewTrailingAction
            )
        )
        favoritesCollectionView.delegate = self
        view.addSubview(favoritesCollectionView)
        favoritesCollectionView.pinToEdges(of: view)
        
        let favoriteCell = UICollectionView.CellRegistration<MovieCell, MovieResult> { cell, _, movie in cell.set(movie: movie) }
        dataSource = UICollectionViewDiffableDataSource<Section, MovieResult>(collectionView: favoritesCollectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: favoriteCell, for: indexPath, item: item)
        }
    }
    
    private func collectionViewTrailingAction(indexPath: IndexPath) -> UISwipeActionsConfiguration {
        let removeFromFavoritesActionHandler: UIContextualAction.Handler = { [weak self] action, view, completion in
            guard let self else {
                completion(false)
                return
            }
            vm.upsertFavorite(index: indexPath.item)
//            completion(true)
        }
        let removeFromFavoritesAction = UIContextualAction(style: .destructive, title: "Delete", handler: removeFromFavoritesActionHandler)
        removeFromFavoritesAction.image = UIImage(systemName: "trash.fill")
        
        return UISwipeActionsConfiguration(actions: [removeFromFavoritesAction])
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        bind(vm.$favorites) { [weak self] movies in
            guard let self else { return }
            var snapshot = NSDiffableDataSourceSnapshot<Section, MovieResult>()
            snapshot.appendSections([.main])
            snapshot.appendItems(movies)
            dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
}

extension BookmarksViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        vm.selectedMovieResult = vm.favorites[indexPath.item]
    }
}
