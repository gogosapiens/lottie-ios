//
//  AnimationFontProvider.swift
//  lottie-ios-iOS
//
//  Created by ILLIA HARKAVY on 2/12/20.
//

import Foundation

/**
 Text provider is a protocol that is used to supply text to `AnimationView`.
 */
public protocol AnimationFontProvider: AnyObject {
    func fontFor(keypathName: String, sourceFontName: String, size: CGFloat) -> UIFont
}

/// Default text provider. Uses text in the animation file
public final class DefaultFontProvider: AnimationFontProvider {
    public func fontFor(keypathName: String, sourceFontName: String, size: CGFloat) -> UIFont {
        return UIFont(name: sourceFontName, size: size) ?? UIFont.systemFont(ofSize: size)
    }
    public init() {}
}

