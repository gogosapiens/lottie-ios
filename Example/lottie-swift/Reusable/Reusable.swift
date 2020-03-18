//
//  ReusableCell.swift
//  MileGO
//
//  Created by ILLIA HARKAVY on 3/20/19.
//  Copyright © 2019 Kiryl Makarevich. All rights reserved.
//

import UIKit

protocol Reusable: class {
    static var identifier: String { get }
}
