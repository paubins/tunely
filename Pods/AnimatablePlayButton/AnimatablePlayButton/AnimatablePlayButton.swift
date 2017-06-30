
//  AnimatablePlayButton.swift
//  AnimatablePlayButton
//
//  Created by suzuki keishi on 2015/12/01.
//  Copyright © 2015 suzuki_keishi. All rights reserved.
//

import UIKit

open class AnimatablePlayButton: UIButton {
    
    open var color: UIColor! = .white {
        didSet {
            pauseLeft.strokeColor = color.cgColor
            pauseLeftMover.strokeColor = color.cgColor
            pauseRight.strokeColor = color.cgColor
            pauseRightMover.strokeColor = color.cgColor
        }
    }
    open var bgColor: UIColor! = .black {
        didSet {
            backgroundColor = bgColor
            playTop.strokeColor = bgColor.cgColor
            playBottom.strokeColor = bgColor.cgColor
        }
    }
    
    fileprivate let pauseLeftSelectAnimation = CAKeyframeAnimation(keyPath: "transform")
    fileprivate let pauseRightSelectAnimation = CAKeyframeAnimation(keyPath: "transform")
    fileprivate let playTopSelectAnimation = CAKeyframeAnimation(keyPath: "transform")
    fileprivate let playBottomSelectAnimation = CAKeyframeAnimation(keyPath: "transform")
    fileprivate let pauseLeftDeSelectAnimation = CAKeyframeAnimation(keyPath: "transform")
    fileprivate let pauseRightDeSelectAnimation = CAKeyframeAnimation(keyPath: "transform")
    fileprivate let playTopDeSelectAnimation = CAKeyframeAnimation(keyPath: "transform")
    fileprivate let playBottomDeSelectAnimation = CAKeyframeAnimation(keyPath: "transform")
    
    fileprivate var pauseLeft: CAShapeLayer = CAShapeLayer()
    fileprivate var pauseLeftMover: CAShapeLayer = CAShapeLayer()
    fileprivate var pauseRight: CAShapeLayer = CAShapeLayer()
    fileprivate var pauseRightMover: CAShapeLayer = CAShapeLayer()
    fileprivate var playTop: CAShapeLayer = CAShapeLayer()
    fileprivate var playBottom: CAShapeLayer = CAShapeLayer()
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        setup()
        createLayers(frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
        createLayers(frame)
    }
    
    override public required init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        createLayers(frame)
    }
    
    convenience public init(origin: CGPoint, lengthOfSize: CGFloat){
        self.init(frame: CGRect(x: origin.x, y: origin.y, width: lengthOfSize, height: lengthOfSize))
    }
    
    convenience public init(lengthOfSize: CGFloat){
        self.init(frame: CGRect(x: 0, y: 0, width: lengthOfSize, height: lengthOfSize))
    }
    
    // MARK: - private
    fileprivate func setup(){
        clipsToBounds = true
        bgColor = .black
        color = .white
    }
    
    fileprivate func createLayers(_ frame: CGRect) {
        
        let pauseLineWidth:CGFloat = bounds.width/5
        let pauseLine:CGFloat = pauseLineWidth * 2
        let pausePadding:CGFloat = (bounds.height/5)
        let pauseHeight = bounds.height-(pausePadding*2)
        
        let pausePath: CGPath = {
            let path = CGMutablePath()
            
            path.move(to: CGPoint(x: 0.0, y: 0.0), transform: .identity)
            path.addLine(to:  CGPoint(x: 0.0, y: pauseHeight), transform: .identity)
            
            return path
        }()
        
        pauseLeft.path = pausePath
        pauseLeftMover.path = pausePath
        pauseRight.path = pausePath
        pauseRightMover.path = pausePath
        playTop.path =  {
            let path = CGMutablePath()
            
            path.move(to: CGPoint(x: 0.0, y: 0.0), transform: .identity)
            path.addLine(to:  CGPoint(x: bounds.width, y: bounds.height / 2), transform: .identity)

            return path
            }()
        
        playBottom.path = {
            let path = CGMutablePath()

            path.move(to: CGPoint(x: 0.0, y: bounds.height), transform: .identity)
            path.addLine(to:  CGPoint(x: bounds.width, y: bounds.height / 2), transform: .identity)

            return path
            }()
        
        
        pauseLeft.frame = CGRect(x: (bounds.width/5)*1, y: pausePadding, width: pauseLine, height: pauseHeight)
        pauseLeft.lineWidth = pauseLine
        pauseLeft.masksToBounds = true
        layer.addSublayer(pauseLeft)
        
        pauseLeftMover.frame = CGRect(x: (bounds.width/5)*1, y: pausePadding, width: pauseLine * 1.25, height: pauseHeight)
        pauseLeftMover.lineWidth = pauseLine * 1.25
        pauseLeftMover.masksToBounds = true
        layer.addSublayer(pauseLeftMover)
        
        pauseRight.frame = CGRect(x: (bounds.width/5)*3, y: pausePadding, width: pauseLine, height: pauseHeight)
        pauseRight.lineWidth = pauseLine
        pauseRight.masksToBounds = true
        layer.addSublayer(pauseRight)
        
        pauseRightMover.frame = CGRect(x: (bounds.width/5)*3, y: pausePadding, width: pauseLine * 1.25, height: pauseHeight)
        pauseRightMover.lineWidth = pauseLine * 1.25
        pauseRightMover.masksToBounds = true
        layer.addSublayer(pauseRightMover)
        
        playTop.frame = CGRect(x: 0, y: -bounds.height, width: bounds.width-1, height: bounds.height)
        playTop.lineWidth = pauseLineWidth * 3
        playTop.masksToBounds = true
        layer.addSublayer(playTop)
        
        playBottom.frame = CGRect(x: 0, y: bounds.height, width: bounds.width-1, height: bounds.height)
        playBottom.lineWidth = pauseLineWidth * 3
        playBottom.masksToBounds = true
        layer.addSublayer(playBottom)
        
        // SELECT
        pauseLeftSelectAnimation.values = [
            NSValue(caTransform3D: CATransform3DMakeTranslation(pauseLineWidth * 0, 0, 0)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(pauseLineWidth * 0.51, 0, 0)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(pauseLineWidth * 0.51, 0, 0)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(pauseLineWidth * 0.51, 0, 0)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(pauseLineWidth * 0.51, 0, 0)),
        ]
        pauseRightSelectAnimation.values = [
            NSValue(caTransform3D: CATransform3DMakeTranslation(-pauseLineWidth * 0, 0, 0)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(-pauseLineWidth * 0.51, 0, 0)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(-pauseLineWidth * 0.51, 0, 0)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(-pauseLineWidth * 0.51, 0, 0)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(-pauseLineWidth * 0.51, 0, 0)),
        ]
        playTopSelectAnimation.values = [
            NSValue(caTransform3D: CATransform3DMakeTranslation(0, bounds.height * 0.3, 0)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(0, bounds.height * 0.76, 0)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(0, bounds.height * 0.76, 0)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(0, bounds.height * 0.76, 0)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(0, bounds.height * 0.76, 0)),
        ]
        playBottomSelectAnimation.values = [
            NSValue(caTransform3D: CATransform3DMakeTranslation(0, -bounds.height * 0.3, 0)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(0, -bounds.height * 0.76, 0)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(0, -bounds.height * 0.76, 0)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(0, -bounds.height * 0.76, 0)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(0, -bounds.height * 0.76, 0)),
        ]
        
        // DESELECT
        pauseLeftDeSelectAnimation.values = [
            NSValue(caTransform3D: CATransform3DMakeTranslation(pauseLineWidth * 0.5, 0, 0)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(pauseLineWidth * 0.2, 0, 0)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(pauseLineWidth * 0.1, 0, 0)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(pauseLineWidth * 0.0, 0, 0)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(pauseLineWidth * 0.0, 0, 0)),
        ]
        pauseRightDeSelectAnimation.values = [
            NSValue(caTransform3D: CATransform3DMakeTranslation(-pauseLineWidth * 0.5, 0, 0)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(-pauseLineWidth * 0.2, 0, 0)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(-pauseLineWidth * 0.1, 0, 0)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(-pauseLineWidth * 0.0, 0, 0)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(-pauseLineWidth * 0.0, 0, 0)),
        ]
        playTopDeSelectAnimation.values = [
            NSValue(caTransform3D: CATransform3DMakeTranslation(0, bounds.height * 0.76, 0)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(0, bounds.height * 0.4, 0)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(0, bounds.height * 0.3, 0)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(0, bounds.height * 0.2, 0)),
            NSValue(caTransform3D: CATransform3DIdentity),
        ]
        playBottomDeSelectAnimation.values = [
            NSValue(caTransform3D: CATransform3DMakeTranslation(0, -bounds.height * 0.76, 0)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(0, -bounds.height * 0.4, 0)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(0, -bounds.height * 0.3, 0)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(0, -bounds.height * 0.2, 0)),
            NSValue(caTransform3D: CATransform3DIdentity),
        ]
        
        setPauseProperty(pauseLeftSelectAnimation)
        setPauseProperty(pauseRightSelectAnimation)
        setCommonProperty(playTopSelectAnimation)
        setCommonProperty(playBottomSelectAnimation)
    }
    
    fileprivate func setPauseProperty(_ animation: CAKeyframeAnimation) {
        animation.duration = 0.4
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
    }
    
    fileprivate func setCommonProperty(_ animation: CAKeyframeAnimation) {
        animation.duration = 0.4
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
    }
    
    // MARK: - public
    open func select() {
        isSelected = true
        
        pauseLeftMover.removeAllAnimations()
        pauseRightMover.removeAllAnimations()
        playTop.removeAllAnimations()
        playBottom.removeAllAnimations()
        
        CATransaction.begin()
        
        pauseLeftMover.add(pauseLeftSelectAnimation, forKey: "transform")
        pauseRightMover.add(pauseRightSelectAnimation, forKey: "transform")
        playTop.add(playTopSelectAnimation, forKey: "transform")
        playBottom.add(playBottomSelectAnimation, forKey: "transform")
        
        CATransaction.commit()
    }
    
    open func deselect() {
        isSelected = false
        
        pauseLeftMover.removeAllAnimations()
        pauseRightMover.removeAllAnimations()
        playTop.removeAllAnimations()
        playBottom.removeAllAnimations()
        
        CATransaction.begin()
        
        pauseLeftMover.add(pauseLeftDeSelectAnimation, forKey: "transform")
        pauseRightMover.add(pauseRightDeSelectAnimation, forKey: "transform")
        playTop.add(playTopDeSelectAnimation, forKey: "transform")
        playBottom.add(playBottomDeSelectAnimation, forKey: "transform")
        
        CATransaction.commit()
    }
}
