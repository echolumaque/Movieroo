//
//  UIHelper.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/24/25.
//

import UIKit

struct UIHelper {
    static func createListFlowLayout(in view: UIView) -> UICollectionViewFlowLayout {
        let width = view.bounds.width
        let padding: CGFloat = 12
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        flowLayout.itemSize = CGSize(width: width, height: 250)
        
        return flowLayout
    }
    
    static func createVerticalCompositionalLayout(
        itemSize: NSCollectionLayoutSize,
        groupSize: NSCollectionLayoutSize,
        interGroupSpacing: CGFloat
    ) -> UICollectionViewCompositionalLayout {
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = interGroupSpacing
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    static func createHorizontalCompositionalLayout(
        itemSize: NSCollectionLayoutSize,
        groupSize: NSCollectionLayoutSize,
        interGroupSpacing: CGFloat
    ) -> UICollectionViewCompositionalLayout {
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        // Create the section with the group and enable horizontal scrolling
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = interGroupSpacing
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}
