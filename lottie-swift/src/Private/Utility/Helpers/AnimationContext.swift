//
//  AnimationContext.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 2/1/19.
//

import Foundation
import CoreGraphics
import QuartzCore
import CoreMedia

/// A completion block for animations. `true` is passed in if the animation completed playing.
public typealias LottieCompletionBlock = (Bool) -> Void

struct AnimationContext {
    
    init(playFrom: CGFloat,
         playTo: CGFloat,
         closure: LottieCompletionBlock?) {
        self.playTo = playTo
        self.playFrom = playFrom
        self.closure = AnimationCompletionDelegate(completionBlock: closure)
    }
    
    var playFrom: CGFloat
    var playTo: CGFloat
    var closure: AnimationCompletionDelegate
    
}

enum AnimationContextState {
    case playing
    case cancelled
    case complete
}

class AnimationCompletionDelegate: NSObject, CAAnimationDelegate {
    
    init(completionBlock: LottieCompletionBlock?) {
        self.completionBlock = completionBlock
        super.init()
    }
    
    var animationLayer: AnimationContainer?
    var animationKey: String?
    var ignoreDelegate: Bool = false
    var animationState: AnimationContextState = .playing
    var loopMode: LottieLoopMode = .loop
    var startTimer: Timer?
    var loopTimer: Timer?
    
    let completionBlock: LottieCompletionBlock?
    
    public func animationDidStart(_ anim: CAAnimation) {
        guard ignoreDelegate == false else { return }
        if let animationLayer = animationLayer {
            startTimer = Timer.scheduledTimer(withTimeInterval: anim.duration - (CACurrentMediaTime() - anim.beginTime), repeats: false) { [unowned self] _ in
                self.loopTimer = Timer.scheduledTimer(withTimeInterval: anim.duration, repeats: true) { [weak self] timer in
                    guard self?.animationState == .playing else {
                        timer.invalidate()
                        return
                    }
                    animationLayer.seekPlayersTo(.zero)
                }
                animationLayer.seekPlayersTo(.zero)
            }
            animationLayer.seekPlayersTo(CMTime(seconds: CACurrentMediaTime() - anim.beginTime, preferredTimescale: 1000))
            animationLayer.playPlayers()
        }
    }
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard ignoreDelegate == false else { return }
        animationState = flag ? .complete : .cancelled
        if let animationLayer = animationLayer, let key = animationKey {
            animationLayer.removeAnimation(forKey: key)
            animationLayer.pausePlayers()
            startTimer?.invalidate()
            loopTimer?.invalidate()
            if flag {
                animationLayer.currentFrame = (anim as! CABasicAnimation).toValue as! CGFloat
            }
        }
        if let completionBlock = completionBlock {
            completionBlock(flag)
        }
    }
    
}
