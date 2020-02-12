//
//  LayerFontProvider.swift
//  lottie-ios-iOS
//
//  Created by ILLIA HARKAVY on 2/12/20.
//

import Foundation

/// Connects a LottieTextProvider to a group of text layers
final class LayerFontProvider {
    
    var fontProvider: AnimationFontProvider {
        didSet {
            reloadTexts()
        }
    }
    
    fileprivate(set) var textLayers: [TextCompositionLayer]
    
    init(fontProvider: AnimationFontProvider) {
        self.fontProvider = fontProvider
        self.textLayers = []
        reloadTexts()
    }

    func addTextLayers(_ layers: [TextCompositionLayer]) {
        textLayers += layers
    }
        
    func reloadTexts() {
        textLayers.forEach {
            $0.fontProvider = fontProvider
        }
    }
}
