//
//  AnimationCollectionViewCell.swift
//  lottie-swift_Example
//
//  Created by ILLIA HARKAVY on 3/10/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import Lottie

class AnimationCollectionViewCell: ReusableCollectionViewCell {
    
    @IBOutlet weak var animationView: AnimationView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        animationView.loopMode = .loop
        animationView.backgroundBehavior = .pauseAndRestore
//        animationView.textProvider = self
//        animationView.fontProvider = self
//        animationView.delegate = self
//        animationView.textEditingDelegate = self
    }
}
