//
//  SelectGenresSheet.swift
//  Movieroo
//
//  Created by Echo Lumaque on 3/4/25.
//

import UIKit

class SelectGenresSheet: UIViewController {
    private var toggleChanged: ((Bool) -> Void)?
    private let genresTableView = DynamicTableView()
    private var dataSource: UITableViewDiffableDataSource<Section, GenreToggle>!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(toggleChanged: ((Bool) -> Void)?) {
        self.init(nibName: nil, bundle: nil)
        self.toggleChanged = toggleChanged
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        title = "Select visible genres"
        genresTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(genresTableView)
        NSLayoutConstraint.activate([
            genresTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            genresTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            genresTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            genresTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        genresTableView.estimatedRowHeight = 80
        genresTableView.rowHeight = UITableView.automaticDimension
        genresTableView.tableFooterView = UIView(frame: .zero)
        genresTableView.register(GenreCell.self, forCellReuseIdentifier: GenreCell.reuseID)
        
        dataSource = UITableViewDiffableDataSource(tableView: genresTableView) { tableView, indexPath, genreToggle in
            let cell = tableView.dequeueReusableCell(withIdentifier: GenreCell.reuseID, for: indexPath) as? GenreCell
            cell?.set(genreToggle: genreToggle, toggleChanged: self.toggleChanged)
            
            return cell
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, GenreToggle>()
        snapshot.appendSections([.main])
        snapshot.appendItems([
            GenreToggle(id: 28, name: "Action"),
            GenreToggle(id: 12, name: "Adventure"),
            GenreToggle(id: 16, name: "Animation"),
            GenreToggle(id: 35, name: "Comedy"),
            GenreToggle(id: 80, name: "Crime"),
            GenreToggle(id: 99, name: "Documentary"),
            GenreToggle(id: 18, name: "Drama"),
            GenreToggle(id: 10751, name: "Family"),
            GenreToggle(id: 14, name: "Fantasy"),
            GenreToggle(id: 36, name: "History"),
            GenreToggle(id: 27, name: "Horror"),
            GenreToggle(id: 10402, name: "Music"),
            GenreToggle(id: 9648, name: "Mystery"),
            GenreToggle(id: 10749, name: "Romance"),
            GenreToggle(id: 878, name: "Science Fiction"),
            GenreToggle(id: 10770, name: "TV Movie"),
            GenreToggle(id: 53, name: "Thriller"),
            GenreToggle(id: 10752, name: "War"),
            GenreToggle(id: 37, name: "Western"),
        ])
        
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: false)
        }
    }
    
    private func toggleChanged(newValue: Bool) {
        self.toggleChanged?(newValue)
    }
}

#Preview {
    let vc = SelectGenresSheet()
    vc.configure()
    return vc
}

struct GenreToggle: Equatable, Hashable {
    let id: Int
    let name: String
}
