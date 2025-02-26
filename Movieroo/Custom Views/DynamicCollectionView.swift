//
//  DynamicCollectionView.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/26/25.
//

import UIKit

//class SelfSizingCollectionView: UICollectionView {
//    override var intrinsicContentSize: CGSize {
//        return contentSize
//    }
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        if bounds.size != intrinsicContentSize {
//            invalidateIntrinsicContentSize()
//        }
//    }
//}

class SelfSizingCollectionView: UICollectionView {
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        isScrollEnabled = false
    }

    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
    }

    override var intrinsicContentSize: CGSize {
        return contentSize
    }
}
