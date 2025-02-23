//
//  MainTabInteractor.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/24/25.
//

import Foundation

protocol MainTabInteractor: AnyObject {
    var presenter: MainTabPresenter? { get set }
}

class MainTabInteractorImpl: MainTabInteractor {
    weak var presenter: (any MainTabPresenter)?
}
