//
//  DynamicLabel.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/25/25.
//

import UIKit

class DynamicLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(
        textColor: UIColor = .label,
        font: UIFont = UIFont.preferredFont(for: .title3, weight: .bold),
        adjustsFontForContentSizeCategory: Bool = true,
        adjustsFontSizeToFitWidth: Bool = true,
        minimumScaleFactor: CGFloat = 0.75,
        numberOfLines: Int = 0
    ) {
        self.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        self.textColor = textColor
        self.font = font
        self.adjustsFontForContentSizeCategory = adjustsFontForContentSizeCategory
        self.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
        self.minimumScaleFactor = minimumScaleFactor
        self.numberOfLines = numberOfLines
    }
}
