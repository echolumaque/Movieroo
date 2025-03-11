//
//  BookmarksCoordinator.swift
//  Movieroo
//
//  Created by Echo Lumaque on 3/7/25.
//

import Combine
import UIKit
import Swinject

class BookmarksCoordinator: Coordinator {
    var cancellables = Set<AnyCancellable>()
    var childCoordinators: [Coordinator] = []
    var rootViewController = UINavigationController()
    var onFinished: (() -> Void)?
    private let bookmarksVM: BookmarksViewModel
    
    private let networkManager: NetworkManager
    private let persistenceManager: PersistenceManager
    
    init(networkManager: NetworkManager, persistenceManager: PersistenceManager) {
        self.networkManager = networkManager
        self.persistenceManager = persistenceManager
        self.bookmarksVM = BookmarksViewModel(persistenceManager: persistenceManager)
    }
    
    func start() {
        let bookmarksVC = BookmarksViewController(networkManager: networkManager, vm: bookmarksVM)
        bookmarksVC.tabBarItem = UITabBarItem(title: "Bookmarks", image: UIImage(systemName: "bookmark.fill"), tag: 1)
        bookmarksVC.dismissDelegate = self
        rootViewController.setViewControllers([bookmarksVC], animated: true)
        
        bookmarksVM.$selectedMovieResult
            .compactMap { $0 }
            .sink { [weak self] in self?.gotoMovieDetail(selectedMovie: $0) }
            .store(in: &cancellables)
    }
    
    func gotoMovieDetail(selectedMovie: MovieResult) {
        let vc = BookmarkedMovieDetailCoordinator(
            networkManager: networkManager,
            persistenceManager: persistenceManager,
            selectedMovie: selectedMovie
        )
        vc.onFinished = { [weak self]  in
            guard let self, let firstIndex = childCoordinators.firstIndex(where: { $0 === vc }) else { return }
            childCoordinators.remove(at: firstIndex)
        }
        
        childCoordinators.append(vc)
        vc.start()
        rootViewController.pushViewController(vc.viewController, animated: true)
    }
}

extension BookmarksCoordinator: DismissDelegate {
    func onDismiss() {
        onFinished?()
    }
}
