//
//  CategoryTableViewCell.swift
//  lottie-swift_Example
//
//  Created by ILLIA HARKAVY on 3/10/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import Lottie

protocol CategoryTableViewCellDelegate: class {
    func categoryTableViewCell(_ cell: CategoryTableViewCell, didSelectItemAt indexPath: IndexPath)
}

class CategoryTableViewCell: ReusableTableViewCell {

    var animations: [Animation]!
    weak var imageProvider: AnimationImageProvider!
    weak var delegate: CategoryTableViewCellDelegate?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        collectionView.indexPathsForVisibleItems.map({ collectionView.cellForItem(at: $0) }).forEach { cell in
            guard let cell = cell as? AnimationCollectionViewCell else {
                return
            }
            if selected, !collectionView.isDecelerating, !collectionView.isDragging, !collectionView.isTracking {
                cell.animationView.play()
            } else {
                cell.animationView.stop()
            }
        }
    }

}

extension CategoryTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return animations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(AnimationCollectionViewCell.self, for: indexPath)
        let animation = animations[indexPath.row]
        cell.animationView.imageProvider = imageProvider
        cell.animationView.animation = animation
        return cell
    }
}

extension CategoryTableViewCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? AnimationCollectionViewCell else {
            return
        }
        if isSelected, !cell.animationView.isAnimationPlaying {
//            cell.animationView.play()
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        collectionView.indexPathsForVisibleItems.map({ collectionView.cellForItem(at: $0) }).forEach { cell in
            guard let cell = cell as? AnimationCollectionViewCell else {
                return
            }
            if isSelected {
                cell.animationView.play()
            } else {
                cell.animationView.pause()
            }
        }
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        collectionView.indexPathsForVisibleItems.map({ collectionView.cellForItem(at: $0) }).forEach { cell in
            guard let cell = cell as? AnimationCollectionViewCell else {
                return
            }
            cell.animationView.pause()
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.categoryTableViewCell(self, didSelectItemAt: indexPath)
    }
}
