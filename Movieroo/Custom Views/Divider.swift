//
//  Divider.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/25/25.
//

import UIKit

class Divider: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .separator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
