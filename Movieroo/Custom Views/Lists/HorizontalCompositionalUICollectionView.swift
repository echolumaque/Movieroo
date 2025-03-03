//
//  HorizontalCompositionalUICollectionView.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/28/25.
//

import UIKit

protocol HorizontalCompositionalUICollectionViewDelegate: AnyObject {
    func collectionViewDidInvalidateVisibleItems(
        visibleItems: [NSCollectionLayoutVisibleItem],
        contentOffset: CGPoint,
        environment: NSCollectionLayoutEnvironment
    )
}

class HorizontalCompositionalUICollectionView: UICollectionView {
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(
        itemSize: NSCollectionLayoutSize,
        groupSize: NSCollectionLayoutSize,
        interGroupSpacing: CGFloat,
        horizontalCompositionalDelegate: HorizontalCompositionalUICollectionViewDelegate
    ) {
        let layout = UIHelper.createHorizontalCompositionalLayout(
            itemSize: itemSize,
            groupSize: groupSize,
            interGroupSpacing: interGroupSpacing,
            visibleItemsInvalidationHandler: horizontalCompositionalDelegate.collectionViewDidInvalidateVisibleItems
        )
        
        self.init(frame: .zero, collectionViewLayout: layout)
    }
}
