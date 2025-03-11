//
//  MainTabAssembly.swift
//  Movieroo
//
//  Created by Echo Lumaque on 3/11/25.
//

import Foundation
import Swinject

class MainTabAssembly: Assembly {
    func assemble(container: Container) {
        container.register(MainTabRouter.self) { resolver in
            let view = MainTabViewController()
            let interactor = MainTabInteractorImpl()
            let presenter = MainTabPresenterImpl()
            let router = MainTabRouterImpl()
            
            view.presenter = presenter
            view.viewControllers = [
                router.createMoviesVC(container: resolver),
                router.createBookmarksVC(router: router, container: resolver)
            ]
            
            interactor.presenter = presenter
            
            presenter.view = view
            presenter.interactor = interactor
            presenter.router = router
            
            router.view = view
            return router
        }
    }
}
