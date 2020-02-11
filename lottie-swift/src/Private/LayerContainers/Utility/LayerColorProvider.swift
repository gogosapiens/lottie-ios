//
//  LayerColorProvider.swift
//  lottie-ios-iOS
//
//  Created by ILLIA HARKAVY on 2/10/20.
//

import Foundation

/// Connects a LottieTextProvider to a group of text layers
final class LayerColorProvider {
    
    var colorProvider: AnimationColorProvider {
        didSet {
            reloadColors()
        }
    }
    
    fileprivate(set) var colorLayers: [CompositionLayer]
    
    init(colorProvider: AnimationColorProvider) {
        self.colorProvider = colorProvider
        self.colorLayers = []
        reloadColors()
    }

    func addColorLayers(_ layers: [CompositionLayer]) {
        colorLayers += layers
    }
        
    func reloadColors() {
        colorLayers.forEach {
            $0.colorProvider = colorProvider
        }
    }
}
