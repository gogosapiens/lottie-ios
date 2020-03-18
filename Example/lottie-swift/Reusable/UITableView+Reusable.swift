//
//  UITableView+ReusableCell.swift
//  MileGO
//
//  Created by ILLIA HARKAVY on 4/2/19.
//  Copyright © 2019 Kiryl Makarevich. All rights reserved.
//

import UIKit

extension UITableView {
    func register(_ cells: ReusableTableViewCell.Type...) {
        cells.forEach { cell in
            register(UINib(nibName: cell.identifier, bundle: nil),
                     forCellReuseIdentifier: cell.identifier)
        }
    }
    func dequeue<T: ReusableTableViewCell>(_ cell: T.Type, withIdentifier identifier: String = T.identifier, for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! T
    }
}

class ReusableTableViewCell: UITableViewCell {
    static var identifier: String { return String(describing: self) }
}
