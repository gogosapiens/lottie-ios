//
//  TextCompositionLayer.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/25/19.
//

import Foundation
import CoreGraphics
import QuartzCore
import CoreText

/// Needed for NSMutableParagraphStyle...
#if os(OSX)
import AppKit
#else
import UIKit
#endif

class DisabledTextLayer: CATextLayer {
    override func action(forKey event: String) -> CAAction? {
        return nil
    }
}

extension TextJustification {
    var textAlignment: NSTextAlignment {
        switch self {
        case .left:
            return .left
        case .right:
            return .right
        case .center:
            return .center
        }
    }
    
    var caTextAlignement: CATextLayerAlignmentMode {
        switch self {
        case .left:
            return .left
        case .right:
            return .right
        case .center:
            return .center
        }
    }
    
}

final class TextCompositionLayer: CompositionLayer {
    
    let animatorNodes: [TextAnimatorNode]
    let textDocument: KeyframeInterpolator<TextDocument>?
    let interpolatableAnchorPoint: KeyframeInterpolator<Vector3D>?
    let interpolatableScale: KeyframeInterpolator<Vector3D>?
    
    let textLayer: DisabledTextLayer = DisabledTextLayer()
    let textStrokeLayer: DisabledTextLayer = DisabledTextLayer()
    var textProvider: AnimationTextProvider
    var fontProvider: AnimationFontProvider
    
    init(textLayer: TextLayerModel, textProvider: AnimationTextProvider, fontProvider: AnimationFontProvider) {
        var animatorNodes = [TextAnimatorNode]()
        for animator in textLayer.animators {
            animatorNodes.append(TextAnimatorNode(parentNode: animatorNodes.last, textAnimator: animator))
        }
        self.animatorNodes = animatorNodes
        self.textDocument = KeyframeInterpolator(keyframes: textLayer.text.keyframes)
        
        self.textProvider = textProvider
        self.fontProvider = fontProvider
        
        // TODO: this has to be somewhere that can be interpolated
        // TODO: look for inspiration from other composite layer
        self.interpolatableAnchorPoint = KeyframeInterpolator(keyframes: textLayer.transform.anchorPoint.keyframes)
        self.interpolatableScale = KeyframeInterpolator(keyframes: textLayer.transform.scale.keyframes)
        
        super.init(layer: textLayer, size: .zero)
        contentsLayer.addSublayer(self.textLayer)
        contentsLayer.addSublayer(self.textStrokeLayer)
        self.textLayer.masksToBounds = false
        self.textStrokeLayer.masksToBounds = false
        self.textLayer.isWrapped = true
        self.textStrokeLayer.isWrapped = true
        animatorNodes.forEach({ childKeypaths.append($0.textAnimatorProperties) })
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(layer: Any) {
        /// Used for creating shadow model layers. Read More here: https://developer.apple.com/documentation/quartzcore/calayer/1410842-init
        guard let layer = layer as? TextCompositionLayer else {
            fatalError("init(layer:) Wrong Layer Class")
        }
        self.animatorNodes = []
        self.textDocument = nil
        
        self.textProvider = DefaultTextProvider()
        self.fontProvider = DefaultFontProvider()
        
        self.interpolatableAnchorPoint = nil
        self.interpolatableScale = nil
        
        super.init(layer: layer)
        animatorNodes.forEach({ childKeypaths.append($0.textAnimatorProperties) })
    }
    
    override func displayContentsWithFrame(frame: CGFloat, forceUpdates: Bool) {
        guard let textDocument = textDocument else { return }
        
        textLayer.contentsScale = self.renderScale
        textStrokeLayer.contentsScale = self.renderScale
        
        let documentUpdate = textDocument.hasUpdate(frame: frame)
        let animatorUpdate = animatorNodes.map({ $0.updateContents(frame, forceLocalUpdate: forceUpdates) }).contains(true)
        guard documentUpdate == true || animatorUpdate == true || forceUpdates else { return }
        
        let text = textDocument.value(frame: frame) as! TextDocument
        let anchorPoint = interpolatableAnchorPoint?.value(frame: frame) as! Vector3D
        
        interpolatableScale?.value(frame: frame)
        
        animatorNodes.forEach({ $0.rebuildOutputs(frame: frame) })
        
        let fillColor = animatorNodes.compactMap({ $0.textOutputNode.fillColor }).last ?? text.fillColorData?.cgColorValue ?? UIColor.clear.cgColor
        let strokeColor = animatorNodes.compactMap({ $0.textOutputNode.strokeColor }).last ?? text.strokeColorData?.cgColorValue
        let strokeWidth = animatorNodes.compactMap({ $0.textOutputNode.strokeWidth }).last ?? CGFloat(text.strokeWidth ?? 0)
        let tracking = (CGFloat(text.fontSize) * (animatorNodes.compactMap({ $0.textOutputNode.tracking }).last ?? CGFloat(text.tracking))) / 1000.0
        
        let matrix = animatorNodes.compactMap({ $0.textOutputNode.xform }).last ?? CATransform3DIdentity
        
        let font = fontProvider.fontFor(keypathName: self.keypathName, sourceFontName: text.fontFamily, size: CGFloat(text.fontSize))
        
        let textString = textProvider.textFor(keypathName: self.keypathName, sourceText: text.text)
        
        var attributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: fillColor,
            NSAttributedString.Key.kern: tracking,
        ]
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = text.justification.textAlignment
//        paragraphStyle.lineSpacing = 0
//        paragraphStyle.maximumLineHeight = CGFloat(text.lineHeight)
//        paragraphStyle.minimumLineHeight = CGFloat(text.lineHeight)
        attributes[NSAttributedString.Key.paragraphStyle] = paragraphStyle as NSParagraphStyle
        
        let baseAttributedString = NSAttributedString(string: textString, attributes: attributes )
        
        if let strokeColor = strokeColor {
            textStrokeLayer.isHidden = false
            attributes[NSAttributedString.Key.strokeColor] = strokeColor
            attributes[NSAttributedString.Key.strokeWidth] = strokeWidth
        } else {
            textStrokeLayer.isHidden = true
        }
        
        let attributedString: NSAttributedString = NSAttributedString(string: textString, attributes: attributes )
        
//        let framesetter = CTFramesetterCreateWithAttributedString(attributedString)
//        let constraintSize = CGSize(width: text.textFrameSize != nil ? CGFloat(text.textFrameSize!.x) : self.frame.width, height: 10000)
//
//        let framasetterSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRange(location: 0,length: 0), nil, constraintSize, nil)
        let width = text.textFrameSize != nil ? CGFloat(text.textFrameSize!.x) : self.frame.width
        let height = attributedString.height(withConstrainedWidth: width)
        let size = CGSize(width: width, height: height)
        
        //print("Size:", size)
        //print("FrameSize:", text.textFrameSize!)
        print("ascender", font.ascender)
        print("descender", font.descender)
        let baselinePosition = font.ascender
        let textAnchor: CGPoint
        if text.textFrameSize != nil {
            textAnchor = CGPoint(x: 0, y: -font.descender)
        } else {
            switch text.justification {
            case .left:
                textAnchor = CGPoint(x: 0, y: baselinePosition)
            case .right:
                textAnchor = CGPoint(x: size.width, y: baselinePosition)
            case .center:
                textAnchor = CGPoint(x: size.width * 0.5, y: baselinePosition)
            }
        }
//        textLayer.borderColor = UIColor.blue.cgColor
        let anchor = textAnchor + anchorPoint.pointValue
        print("🔷",anchorPoint.pointValue)
        let normalizedAnchor = CGPoint(x: anchor.x.remap(fromLow: 0, fromHigh: size.width, toLow: 0, toHigh: 1),
                                       y: anchor.y.remap(fromLow: 0, fromHigh: size.height, toLow: 0, toHigh: 1))
        
        if textStrokeLayer.isHidden == false {
            if text.strokeOverFill ?? false {
                textStrokeLayer.removeFromSuperlayer()
                contentsLayer.addSublayer(textStrokeLayer)
            } else {
                textLayer.removeFromSuperlayer()
                contentsLayer.addSublayer(textLayer)
            }
            textStrokeLayer.anchorPoint = normalizedAnchor
            textStrokeLayer.opacity = Float(animatorNodes.compactMap({ $0.textOutputNode.opacity }).last ?? 1)
            textStrokeLayer.transform = CATransform3DIdentity
            textStrokeLayer.frame = CGRect(origin: .zero, size: size)
            textStrokeLayer.position = text.textFramePosition?.pointValue ?? CGPoint.zero
            textStrokeLayer.transform = matrix
            textStrokeLayer.string = attributedString
            textStrokeLayer.alignmentMode = text.justification.caTextAlignement
        }
        
        textLayer.anchorPoint = normalizedAnchor
        textLayer.opacity = Float(animatorNodes.compactMap({ $0.textOutputNode.opacity }).last ?? 1)
        textLayer.transform = CATransform3DIdentity
        textLayer.frame = CGRect(origin: .zero, size: size)
        textLayer.position = text.textFramePosition?.pointValue ?? CGPoint.zero
        textLayer.transform = matrix
        textLayer.string = baseAttributedString
        textLayer.alignmentMode = text.justification.caTextAlignement
    }
    
    override func updateRenderScale() {
        super.updateRenderScale()
        textLayer.contentsScale = self.renderScale
    }
}
