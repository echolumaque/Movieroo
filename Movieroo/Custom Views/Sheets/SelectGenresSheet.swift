//
//  SelectGenresSheet.swift
//  Movieroo
//
//  Created by Echo Lumaque on 3/4/25.
//

import UIKit

protocol SelectGenresDelegate: AnyObject {
    func onGenreSelected(genreInfo: (genre: GenreToggle, isEnabled: Bool))
}

protocol SelectGenresDataSource: AnyObject {
    var genreInfos: [GenreToggle] { get set }
}

class SelectGenresSheet: UIViewController {
    private var toggleChanged: ((Bool) -> Void)?
    private let genresTableView = DynamicTableView()
    
    weak var delegate: SelectGenresDelegate?
    weak var genreInfosDataSource: SelectGenresDataSource?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(toggleChanged: ((Bool) -> Void)?) {
        self.init(nibName: nil, bundle: nil)
        self.toggleChanged = toggleChanged
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Select visible genres"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", primaryAction: UIAction { [weak self] _ in
            self?.dismiss(animated: true)
        })
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        genresTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(genresTableView)
        NSLayoutConstraint.activate([
            genresTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            genresTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            genresTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            genresTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        genresTableView.dataSource = self
        genresTableView.estimatedRowHeight = 80
        genresTableView.rowHeight = UITableView.automaticDimension
        genresTableView.tableFooterView = UIView(frame: .zero)
        genresTableView.register(GenreCell.self, forCellReuseIdentifier: GenreCell.reuseID)
    }
    
    private func toggleChanged(genreInfo: (GenreToggle, Bool)) {
        guard let firstIndex = genreInfosDataSource?.genreInfos.firstIndex(where: { $0.id == genreInfo.0.id }) else { return }
        genreInfosDataSource?.genreInfos[firstIndex].isEnabled = genreInfo.1
        delegate?.onGenreSelected(genreInfo: genreInfo)
    }
}

extension SelectGenresSheet: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        genreInfosDataSource?.genreInfos.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GenreCell.reuseID, for: indexPath) as! GenreCell
        let genreToggle = (genreInfosDataSource?.genreInfos ?? [])[indexPath.row]
        cell.set(genreToggle: genreToggle, toggleChanged: toggleChanged)
        cell.selectionStyle = .none
        
        return cell
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
    var isEnabled: Bool
}
