//
//  BookmarksCoordinator.swift
//  Movieroo
//
//  Created by Echo Lumaque on 3/7/25.
//

import Combine
import UIKit

class BookmarksCoordinator: Coordinator {
    var cancellables = Set<AnyCancellable>()
    var rootViewController = UINavigationController()
    var onFinished: (() -> Void)?
    private let bookmarksVM: BookmarksViewModel
    
    init(persistenceManagerClass: PersistenceManagerClass) {
        self.bookmarksVM = BookmarksViewModel(persistenceManagerClass: persistenceManagerClass)
    }
    
    func start() {
        let bookmarksVC = BookmarksViewController(vm: bookmarksVM)
        bookmarksVC.tabBarItem = UITabBarItem(title: "Bookmarks", image: UIImage(systemName: "bookmark.fill"), tag: 1)
        bookmarksVC.dismissDelegate = self
        rootViewController.setViewControllers([bookmarksVC], animated: true)
        
        bookmarksVM.$selectedMovieResult
            .compactMap { $0 }
            .sink { [weak self] selectedMovie in self?.gotoMovieDetail(selectedMovie: selectedMovie) }
            .store(in: &cancellables)
    }
    
    func gotoMovieDetail(selectedMovie: MovieResult) {
        print("selected movie: \(selectedMovie.title)")
        bookmarksVM.selectedMovieResult = nil
    }
}

extension BookmarksCoordinator: DismissDelegate {
    func onDismiss() {
        onFinished?()
    }
}
