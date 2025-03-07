//
//  BookmarkedMovieDetailCoordinator.swift
//  Movieroo
//
//  Created by Echo Lumaque on 3/7/25.
//

import UIKit

class BookmarkedMovieDetailCoordinator: Coordinator {
    var onFinished: (() -> Void)?
    var viewController: UIViewController!
    private let vm: BookmarkedMovieDetailViewModel
    
    init(networkManager: NetworkManagerClass, persistenceManager: PersistenceManagerClass, selectedMovie: MovieResult) {
        vm = BookmarkedMovieDetailViewModel(
            networkManager: networkManager,
            persistenceManager: persistenceManager,
            selectedMovie: selectedMovie
        )
    }
    
    func start() {
        let vc = BookmarkedMovieDetailViewController(vm: vm)
        vc.dismissDelegate = self
        vc.hidesBottomBarWhenPushed = true
        viewController = vc
    }
}

extension BookmarkedMovieDetailCoordinator: DismissDelegate {
    func onDismiss() {
        onFinished?()
    }
}
