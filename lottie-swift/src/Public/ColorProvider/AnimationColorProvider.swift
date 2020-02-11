//
//  AnimationColorProvider.swift
//  lottie-ios-iOS
//
//  Created by ILLIA HARKAVY on 2/10/20.
//

import Foundation

/**
 Text provider is a protocol that is used to supply color palete to `AnimationView`.
 */
public protocol AnimationColorProvider: AnyObject {
    
    func colorForIndex(_ index: Int) -> CGColor
}

extension AnimationColorProvider {
    
    func colorForSourceColor(_ color: Color) -> CGColor {
        switch (color.r, color.g, color.b) {
        case (0.999, 0, 0), (0.998992919922, 0, 0):
            return colorForIndex(0)
        case (0, 0.999, 0), (0, 0.998992919922, 0):
            return colorForIndex(1)
        case (0, 0, 0.999), (0, 0, 0.998992919922):
            return colorForIndex(2)
        default:
            return color.cgColorValue
        }
    }
}

/// Default text provider. Uses text in the animation file
public final class DefaultColorProvider: AnimationColorProvider {
    
    public func colorForIndex(_ index: Int) -> CGColor {
        return UIColor.white.cgColor
    }
    public init() {}
}
