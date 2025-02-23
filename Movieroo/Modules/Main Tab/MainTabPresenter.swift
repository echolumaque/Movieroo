//
//  MainTabPresenter.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/24/25.
//

import Foundation

protocol MainTabPresenter: AnyObject {
    var router: MainTabRouter? { get set }
    var interactor: MainTabInteractor? { get set }
    var view: MainTabView? { get set }
}

class MainTabPresenterImpl: MainTabPresenter {
    var router: (any MainTabRouter)?
    var interactor: (any MainTabInteractor)?
    weak var view: (any MainTabView)?
}
