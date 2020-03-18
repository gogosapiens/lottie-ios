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

class EditViewController: UIViewController {

    @IBOutlet weak var animationView: AnimationView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var animation: Animation!
    var defaultAssetResources: [String: AssetResource] = [
        "img_0.png": .image(#imageLiteral(resourceName: "img_0").cgImage!),
        "img_1.png": .image(#imageLiteral(resourceName: "img_1").cgImage!),
        "img_2.png": .image(#imageLiteral(resourceName: "img_2").cgImage!),
        "img_3.png": .image(#imageLiteral(resourceName: "img_3").cgImage!)
    ]
    var pickedAssetResources = [String: AssetResource]()
    var defaultTexts = [String: String]()
    var customTexts = [String: String]()
    var currentPickingAssetResourceID: String?
    var colorPalettes: [ColorPalette] = [
        [#colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1).lottieColorValue, #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).lottieColorValue, #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).lottieColorValue],
        [#colorLiteral(red: 0.4979559183, green: 0, blue: 0.7701239586, alpha: 1).lottieColorValue, #colorLiteral(red: 0.2869204879, green: 0, blue: 0.7715654969, alpha: 1).lottieColorValue, #colorLiteral(red: 0, green: 0.3361636996, blue: 0.7679021955, alpha: 1).lottieColorValue],
        [#colorLiteral(red: 0, green: 0.754439652, blue: 0.546407342, alpha: 1).lottieColorValue, #colorLiteral(red: 0, green: 0.7544339895, blue: 0, alpha: 1).lottieColorValue, #colorLiteral(red: 0.6414628625, green: 0.7437676787, blue: 0, alpha: 1).lottieColorValue]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        try! AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)

        animationView.animation = animation
        
        animationView.loopMode = .loop
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.textProvider = self
        animationView.fontProvider = self
        animationView.imageProvider = self
        animationView.reloadImages()
        animationView.delegate = self
        animationView.textEditingDelegate = self
        
        segmentedControl.selectedSegmentIndex = 0
        animationView.colorPalette = colorPalettes[0]
        
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(panValueChanged(_:)))
        animationView.addGestureRecognizer(recognizer)
        animationView.logHierarchyKeypaths()
    }
    
    var textOffset: CGPoint = .zero
    
    @objc func panValueChanged(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: animationView)
        let offset = CGPoint(x: textOffset.x - translation.x, y: textOffset.y - translation.y)
        switch sender.state {
        case .changed:
            animationView.setValueProvider(PointValueProvider(offset), keypath: AnimationKeypath(keypath: "You are.Transform.Anchor Point"))
        case .ended:
            textOffset = offset
        default:
            break
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !animationView.isAnimationPlaying {
            animationView.play()
        }
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        animationView.colorPalette = colorPalettes[sender.selectedSegmentIndex]
    }
    
    @IBAction func selectMultipleButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func exportButtonTapped(_ sender: UIButton) {
//        let url = Bundle.main.url(forResource: "video", withExtension: "mp4")!
//        VideoEditor().makeBirthdayCard(animation: animationView.animation!, videoURL: url) { url in
//            print(url)
//        }
    }
}

extension EditViewController: AnimationViewDelegate {
    
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

extension EditViewController: AnimationTextProvider {
    
    func textFor(keypathName: String, sourceText: String) -> String {
        defaultTexts[keypathName] = sourceText
        return customTexts[keypathName] ?? sourceText
    }
}

extension EditViewController: AnimationImageProvider {
    
    func imageForAsset(asset: ImageAsset) -> AssetResource? {
        print(#function, asset.id)
        return pickedAssetResources[asset.id] ?? defaultAssetResources[asset.name] ?? .image(#imageLiteral(resourceName: "placeholder").cgImage!)
    }
}

extension EditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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

extension EditViewController: AnimationViewTextEditingDelegate {
    
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
}

extension EditViewController: AnimationFontProvider {
    
    func fontFor(keypathName: String, sourceFontName: String, size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .bold)
    }
}
