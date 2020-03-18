//
//  UICollectionView+Reusable.swift
//  Lightroom
//
//  Created by ILLIA HARKAVY on 11/11/19.
//  Copyright © 2019 Lightroom Filters. All rights reserved.
//

import UIKit

extension UICollectionView {
    func register(_ cells: ReusableCollectionViewCell.Type...) {
        cells.forEach { cell in
            register(UINib(nibName: cell.identifier, bundle: nil), forCellWithReuseIdentifier: cell.identifier)
        }
    }
    func dequeue<T: ReusableCollectionViewCell>(_ cell: T.Type, withIdentifier identifier: String = T.identifier, for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! T
    }
}

class ReusableCollectionViewCell: UICollectionViewCell {
    static var identifier: String { return String(describing: self) }
}
