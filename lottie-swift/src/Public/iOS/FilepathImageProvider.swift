//
//  FilepathImageProvider.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 2/1/19.
//

import Foundation
#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit

/**
 Provides an image for a lottie animation from a provided Bundle.
 */
public class FilepathImageProvider: AnimationImageProvider {
    
    let filepath: URL
    
    /**
     Initializes an image provider with a specific filepath.
     
     - Parameter filepath: The absolute filepath containing the images.
     
     */
    public init(filepath: String) {
        self.filepath = URL(fileURLWithPath: filepath)
    }
    
    public init(filepath: URL) {
        self.filepath = filepath
    }
    
    public func imageForAsset(asset: ImageAsset) -> AssetResource? {
        
        if asset.name.hasPrefix("data:"),
            let url = URL(string: asset.name),
            let data = try? Data(contentsOf: url),
            let image = UIImage(data: data),
            let cgImage = image.cgImage {
            fatalError("SHIT")
            return .image(cgImage)
        }
        
        let directPath = filepath.appendingPathComponent(asset.name).path
        if FileManager.default.fileExists(atPath: directPath) {
            return AssetResource(url: URL(fileURLWithPath: directPath))
        }
        
        let pathWithDirectory = filepath.appendingPathComponent(asset.directory).appendingPathComponent(asset.name).path
        if FileManager.default.fileExists(atPath: pathWithDirectory) {
            return AssetResource(url: URL(fileURLWithPath: pathWithDirectory))
        }
        
        return nil
    }
    
}
#endif
