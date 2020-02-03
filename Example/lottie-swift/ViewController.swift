//
//  ViewController.swift
//  lottie-swift
//
//  Created by buba447 on 01/07/2019.
//  Copyright (c) 2019 buba447. All rights reserved.
//

import UIKit
import Lottie

class ViewController: UIViewController {

    @IBOutlet weak var animationView: AnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animationView.loopMode = .loop
        animationView.backgroundBehavior = .pauseAndRestore
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !animationView.isAnimationPlaying {
            animationView.play()
        }
    }
}
