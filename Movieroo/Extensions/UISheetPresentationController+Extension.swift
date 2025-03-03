//
//  UISheetPresentationController+Extension.swift
//  Movieroo
//
//  Created by Echo Lumaque on 3/4/25.
//

import UIKit

extension UISheetPresentationController {
    func configureMediumSheet() {
        detents = [.medium()]
        prefersGrabberVisible = true
        preferredCornerRadius = 16
        prefersScrollingExpandsWhenScrolledToEdge = false
    }
}
