//
//  ViewController.swift
//  lottie-swift
//
//  Created by buba447 on 01/07/2019.
//  Copyright (c) 2019 buba447. All rights reserved.
//

import UIKit
import AVFoundation
import Lottie

class ViewController: UIViewController {

    @IBOutlet weak var animationView: AnimationView!
    
    var pickedAssetResources = [String: AssetResource]()
    var defaultTexts = [String: String]()
    var customTexts = [String: String]()
    var currentPickingAssetResourceID: String?
    var colors = [#colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1), #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let animation = Animation.filepath(Bundle.main.url(forResource: "animation6", withExtension: "json")!.path)

        animationView.animation = animation
        
        animationView.loopMode = .loop
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.textProvider = self
        animationView.imageProvider = self
        animationView.colorProvider = self
        animationView.reloadImages()
        animationView.delegate = self
        animationView.textEditingDelegate = self
        
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
            self.colors = [#colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1), #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)]
            self.animationView.reloadColors()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !animationView.isAnimationPlaying {
            animationView.play()
        }
    }
}

extension ViewController: AnimationViewDelegate {
    
    func animationView(_ animationView: AnimationView, didTapAssetWithReferenceID imageReferenceID: String) {
        animationView.pause()
        currentPickingAssetResourceID = imageReferenceID
        let picker = UIImagePickerController()
        picker.modalPresentationStyle = .fullScreen
        picker.delegate = self
        picker.sourceType = .savedPhotosAlbum
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .savedPhotosAlbum)!
        picker.videoExportPreset = AVAssetExportPresetPassthrough
        picker.allowsEditing = false
        present(picker, animated: true)
    }
    
    func animationView(_ animationView: AnimationView, didTapTextWithKeypathName textKeypathName: String) {
        print(textKeypathName)
    }
}

extension ViewController: AnimationTextProvider {
    
    func textFor(keypathName: String, sourceText: String) -> String {
        defaultTexts[keypathName] = sourceText
        return customTexts[keypathName] ?? sourceText
    }
}

extension ViewController: AnimationImageProvider {
    
    func imageForAsset(asset: ImageAsset) -> AssetResource? {
        return pickedAssetResources[asset.id] ?? .image(#imageLiteral(resourceName: "placeholder").cgImage!)
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let assetResourceID = currentPickingAssetResourceID else {
            return
        }
        if let url = info[.mediaURL] as? NSURL {
            pickedAssetResources[assetResourceID] = .video(url as URL)
            animationView.reloadImages()
        } else if let image = info[.originalImage] as? UIImage {
            pickedAssetResources[assetResourceID] = .image(image.cgImage!)
            animationView.reloadImages()
        }
        picker.dismiss(animated: true)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension ViewController: AnimationViewTextEditingDelegate {
    
    func animationView(_ animationView: AnimationView, didDeleteBackwardForKeypathName keypathName: String) {
        if customTexts[keypathName] == nil {
            customTexts[keypathName] = defaultTexts[keypathName]
        }
        customTexts[keypathName] = String(customTexts[keypathName]!.dropLast())
    }
    func animationView(_ animationView: AnimationView, didInsertText text: String, forKeypathName keypathName: String) {
        if customTexts[keypathName] == nil {
            customTexts[keypathName] = defaultTexts[keypathName]
        }
        customTexts[keypathName] = String(customTexts[keypathName]!.appending(text))
    }
    func animationView(_ animationView: AnimationView, didEndEditingTextWithKeypathName keypathName: String) {
        guard let text = customTexts[keypathName] else {
            return
        }
        if text.isEmpty {
            customTexts[keypathName] = defaultTexts[keypathName]
            animationView.reloadTexts()
        }
    }
    
    public func insertText(_ text: String, forKeypathName keypathName: String) {
        
    }
    public func deleteBackwardForKeypathName(_ keypathName: String) {
        
    }
}

extension ViewController: AnimationColorProvider {
    func colorForIndex(_ index: Int) -> CGColor {
        return colors[index].cgColor
    }
}
