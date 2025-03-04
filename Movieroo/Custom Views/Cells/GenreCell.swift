//
//  GenreCell.swift
//  Movieroo
//
//  Created by Echo Lumaque on 3/4/25.
//

import UIKit

class GenreCell: UITableViewCell {
    static let reuseID = "GenreCell"
    private var genreToggle: GenreToggle!
    private var toggleChanged: (((GenreToggle, Bool)) -> Void)!
    
    private let titleLabel = DynamicLabel(textColor: .label, font: UIFont.preferredFont(for: .body, weight: .regular))
    private let toggle = UISwitch()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(genreToggle: GenreToggle, toggleChanged: @escaping ((GenreToggle, Bool)) -> Void) {
        self.genreToggle = genreToggle
        self.toggleChanged = toggleChanged
        titleLabel.text = genreToggle.name
        toggle.isOn = genreToggle.isEnabled
    }
    
    private func configure() {
        let horizontalPadding: CGFloat = 20
        let verticalPadding: CGFloat = 12
        
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.onTintColor = .systemGreen
        toggle.addTarget(self, action: #selector(onChanged), for: .valueChanged)
        
        contentView.addSubviews(titleLabel, toggle)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: verticalPadding),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -verticalPadding),
            
            toggle.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            toggle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
            toggle.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -verticalPadding)
        ])
    }
    
    @objc private func onChanged() {
        toggleChanged?((genreToggle, toggle.isOn))
    }
}

#Preview {
    let cell = GenreCell()
    cell.set(genreToggle: GenreToggle(id: 1, name: "Rock", isEnabled: false), toggleChanged: { _ in })
    return cell
}
