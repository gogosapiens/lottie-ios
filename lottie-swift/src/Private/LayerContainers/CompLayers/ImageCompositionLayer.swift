//
//  ImageCompositionLayer.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/25/19.
//

import Foundation
import CoreGraphics
import QuartzCore
import AVFoundation

final class ImageCompositionLayer: CompositionLayer {
    
    var image: CGImage? = nil {
        didSet {
            if let image = image {
                contentsLayer.contents = image
            } else {
                contentsLayer.contents = nil
            }
        }
    }
    
    let imageReferenceID: String
    let playerLayer = AVPlayerLayer()
    
    init(imageLayer: ImageLayerModel, size: CGSize) {
        self.imageReferenceID = imageLayer.referenceID
        super.init(layer: imageLayer, size: size)
        contentsLayer.masksToBounds = true
        contentsLayer.contentsGravity = CALayerContentsGravity.resizeAspectFill
        
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.anchorPoint = .zero
        playerLayer.bounds = CGRect(origin: .zero, size: size)
        playerLayer.actions = [
          "opacity" : NSNull(),
          "transform" : NSNull(),
          "bounds" : NSNull(),
          "anchorPoint" : NSNull(),
          "sublayerTransform" : NSNull(),
          "hidden" : NSNull()
        ]
        contentsLayer.addSublayer(playerLayer)
        
//        if let maskLayer = maskLayer {
//          playerLayer.mask = maskLayer
//        }
    }
    
//    override func displayWithFrame(frame: CGFloat, forceUpdates: Bool) {
//        super.displayWithFrame(frame: frame, forceUpdates: forceUpdates)
//
//        let layerVisible = frame.isInRangeOrEqual(inFrame, outFrame)
//
//        playerLayer.transform = transformNode.globalTransform
//        playerLayer.opacity = transformNode.opacity
//        playerLayer.isHidden = !layerVisible
//    }
    
    override init(layer: Any) {
        /// Used for creating shadow model layers. Read More here: https://developer.apple.com/documentation/quartzcore/calayer/1410842-init
        guard let layer = layer as? ImageCompositionLayer else {
            fatalError("init(layer:) Wrong Layer Class")
        }
        self.imageReferenceID = layer.imageReferenceID
        self.image = nil
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
