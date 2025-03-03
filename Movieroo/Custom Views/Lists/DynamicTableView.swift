//
//  DynamicTableView.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/25/25.
//

import UIKit

class DynamicTableView: UITableView {
    override var intrinsicContentSize: CGSize {
        return contentSize
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        if bounds.size != intrinsicContentSize {
            invalidateIntrinsicContentSize()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

