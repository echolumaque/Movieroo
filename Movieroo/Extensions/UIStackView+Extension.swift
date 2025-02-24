//
//  UIStackView+Extension.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/24/25.
//

import UIKit

extension UIStackView {
    func addArrangedSubviews(_ views: UIView...) {
        for view in views { addArrangedSubview(view) }
    }
}
