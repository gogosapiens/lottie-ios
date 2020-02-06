//
//  LayerImageProvider.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/25/19.
//

import Foundation
import AVFoundation

/// Connects a LottieImageProvider to a group of image layers
final class LayerImageProvider {
    
    var imageProvider: AnimationImageProvider {
        didSet {
            reloadImages()
        }
    }
    
    fileprivate(set) var imageLayers: [ImageCompositionLayer]
    let imageAssets: [String : ImageAsset]
    
    init(imageProvider: AnimationImageProvider, assets: [String : ImageAsset]?) {
        self.imageProvider = imageProvider
        self.imageLayers = [ImageCompositionLayer]()
        if let assets = assets {
            self.imageAssets = assets
        } else {
            self.imageAssets = [:]
        }
        reloadImages()
    }
    
    func addImageLayers(_ layers: [ImageCompositionLayer]) {
        for layer in layers {
            if imageAssets[layer.imageReferenceID] != nil {
                /// Found a linking asset in our asset library. Add layer
                imageLayers.append(layer)
            }
        }
    }
    
    func reloadImages() {
        for imageLayer in imageLayers {
            if let asset = imageAssets[imageLayer.imageReferenceID] {
                if let assetResource = imageProvider.imageForAsset(asset: asset) {
                    switch assetResource {
                    case .video(let url):
                        let player = AVPlayer(url: url)
                        player.actionAtItemEnd = .none
                        NotificationCenter.default.addObserver(self, selector: #selector(videoDidPlayToEndTime(_:)), name: .AVPlayerItemDidPlayToEndTime, object: nil)
                        imageLayer.playerLayer.player = player
                        imageLayer.image = nil
                    case .image(let image):
                        imageLayer.image = image
                        imageLayer.playerLayer.player = nil
                    }
                }
            }
        }
    }
    
    func pausePlayers() {
        for imageLayer in imageLayers {
            if let player = imageLayer.playerLayer.player {
                player.pause()
            }
        }
    }
    
    func stopPlayers() {
        for imageLayer in imageLayers {
            if let player = imageLayer.playerLayer.player {
                player.seek(to: .zero)
                player.pause()
            }
        }
    }
    
    func playPlayers() {
        for imageLayer in imageLayers {
            if let player = imageLayer.playerLayer.player {
                player.play()
            }
        }
    }
    
    func seekPlayersTo(_ time: CMTime) {
        for imageLayer in imageLayers {
            if let player = imageLayer.playerLayer.player {
                player.seek(to: time)
            }
        }
    }
    
    @objc func videoDidPlayToEndTime(_ notification: NSNotification) {
        for imageLayer in imageLayers {
            if imageLayer.playerLayer.player?.currentItem == notification.object as? AVPlayerItem {
                imageLayer.playerLayer.player?.seek(to: .zero)
            }
        }
    }
}
