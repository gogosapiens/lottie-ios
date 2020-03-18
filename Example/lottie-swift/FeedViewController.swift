//
//  FeedViewController.swift
//  lottie-swift_Example
//
//  Created by ILLIA HARKAVY on 3/10/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import Lottie

class FeedViewController: UIViewController {
    
    var categories: [Category]!
    
    var defaultAssetResources: [String: AssetResource] = [
        "img_0.png": .image(#imageLiteral(resourceName: "img_0").cgImage!),
        "img_1.png": .image(#imageLiteral(resourceName: "img_1").cgImage!),
        "img_2.png": .image(#imageLiteral(resourceName: "img_2").cgImage!),
        "img_3.png": .image(#imageLiteral(resourceName: "img_3").cgImage!)
    ]
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let animation = Animation.filepath(Bundle.main.url(forResource: "sport_preview", withExtension: "json")!.path)!
        categories = [
            Category(title: "Summer", animations: Array(repeating: animation, count: 10)),
            Category(title: "Poop", animations: Array(repeating: animation, count: 10)),
            Category(title: "Table", animations: Array(repeating: animation, count: 10)),
            Category(title: "Wall Street", animations: Array(repeating: animation, count: 10)),
            Category(title: "Dunno", animations: Array(repeating: animation, count: 10)),
            Category(title: "Whatever", animations: Array(repeating: animation, count: 10)),
        ]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateFocusedCell()
    }
    
    func updateFocusedCell() {
        let point = view.convert(view.center, to: tableView)
        if let focusedIndexPath = tableView.indexPathForRow(at: point), focusedIndexPath != tableView.indexPathForSelectedRow {
            tableView.selectRow(at: focusedIndexPath, animated: false, scrollPosition: .none)
        }
    }

    struct Category {
        let title: String
        let animations: [Animation]
    }
    
}

extension FeedViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(CategoryTableViewCell.self, for: indexPath)
        let category = categories[indexPath.row]
        
        cell.animations = category.animations
        cell.titleLabel.text = category.title
        cell.imageProvider = self
        cell.collectionView.contentOffset = .zero
        cell.delegate = self
        
        return cell
    }
}

extension FeedViewController: UITableViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPathForSelectedRow, animated: false)
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateFocusedCell()
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            updateFocusedCell()
        }
    }
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print(scrollView.isDecelerating)
//        if !scrollView.isTracking {
//            updateFocusedCell()
//        }
//    }
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        print(velocity)
//    }
}

extension FeedViewController: AnimationImageProvider {
    
    func imageForAsset(asset: ImageAsset) -> AssetResource? {
        return defaultAssetResources[asset.name] ?? .image(#imageLiteral(resourceName: "placeholder").cgImage!)
    }
}

extension FeedViewController: CategoryTableViewCellDelegate {
    func categoryTableViewCell(_ cell: CategoryTableViewCell, didSelectItemAt indexPath: IndexPath) {
        let categoryIndexPath = tableView.indexPath(for: cell)!
        let animation = categories[categoryIndexPath.row].animations[indexPath.row]
        let vc = EditViewController.instantiate()
        vc.animation = animation
        navigationController?.pushViewController(vc, animated: true)
    }
}
