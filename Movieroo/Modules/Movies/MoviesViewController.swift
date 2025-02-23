//
//  MoviesViewController.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/24/25.
//

import UIKit

protocol MoviesView: AnyObject {
    var presenter: MoviesPresenter? { get set }
    func update(movie: Movie)
    func update(error: NetworkingError)
}

class MoviesViewController: UIViewController, MoviesView {
    var presenter: MoviesPresenter?
    
    let label = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(label)
        label.numberOfLines = 4
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            label.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        Task {
            await presenter?.fetchTrendingMovies()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        label.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        label.center = view.center
    }
    
    func update(movie: Movie) {
        DispatchQueue.main.async {
            self.label.text = "\(movie.movieResults.count)"
        }
    }
    
    func update(error: NetworkingError) {
        DispatchQueue.main.async {
            self.label.text = error.localizedDescription
        }
    }
}
