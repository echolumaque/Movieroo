//
//  MovieDetailRouter.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/24/25.
//

import UIKit

typealias MovieDetailEntryPoint = MovieDetailView & UIViewController

protocol MovieDetailRouter {
    var view: MovieDetailEntryPoint? { get }
}

class MovieDetailRouterImpl: MovieDetailRouter {
    var movieDetailViewController: MovieDetailEntryPoint? // Private strong reference to keep the view alive during assembly.
    weak var view: (any MovieDetailEntryPoint)? { movieDetailViewController } // Publicly, we expose a weak reference.
}
