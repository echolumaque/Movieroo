//
//  MovierooImageView.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/27/25.
//

import UIKit

class MovierooImageView: UIImageView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init() {
        self.init(frame: .zero)
        image = UIImage(systemName: "popcorn.fill")
        tintColor = .systemPurple
    }
}
