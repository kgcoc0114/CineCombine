//
//  SearchResultLayoutType.swift
//  CineCombine
//
//  Created by KarenChiu on 2024/11/14.
//

import Foundation
import UIKit

enum SearchResultLayoutType: Int, Codable {
    case list = 0
    case card = 1

    var buttonIcon: UIImage? {
        switch self {
        case .list:
            return UIImage(systemName: "square.fill.text.grid.1x2")
        case .card:
            return UIImage(systemName: "square.grid.2x2.fill")
        }
    }

    var layout: UICollectionViewCompositionalLayout {
        switch self {
        case .list:
            createListLayout()
        case .card:
            createCardLayout()
        }
    }

    var identifier: String {
        switch self {
        case .list:
            return "SearchResultListCollectionViewCell"
        case .card:
            return "SearchResultCardCollectionViewCell"
        }
    }
    
    private func createCardLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, environment in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                                  heightDimension: .estimated(10))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = .init(top: 3, leading: 3, bottom: 3, trailing: 3)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .estimated(10))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            return section
        }
    }

    private func createListLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, environment in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .estimated(150))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .estimated(150))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            return section
        }
    }
}
