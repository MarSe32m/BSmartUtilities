//
//  AnalogStick.swift
//
//  Created by Sebastian Toivonen on 16.4.2016.
//  Copyright (c) 2016 BSmart. All rights reserved.
//
#if canImport(SpriteKit)
import SpriteKit

@objc protocol AnalogStickProtocol {
    func moveAnalogStick(_ analogStick: AnalogStick, velocity: CGVector, angularVelocity: CGFloat)
    func stoppedMovingAnalogStick(_ analogStick: AnalogStick)
}

final class AnalogStick: SKNode {
    
    var velocityLoop: CADisplayLink?
    let thumbNode: SKSpriteNode, bgNode: SKSpriteNode
    var desiredAlpha: CGFloat = 0.6
    func setThumbImage(_ image: UIImage?, sizeToFit: Bool) {
        let tImage: UIImage = UIImage(named: "control_pad")!
        self.thumbNode.texture = SKTexture(image: tImage)
        self.thumbNode.texture?.filteringMode = .linear
        self.thumbNode.zPosition = self.bgNode.zPosition + 1
        self.thumbNode.size = CGSize(width: thumbNodeDiametr, height: thumbNodeDiametr)
    }
    func setBgImage(_ image: UIImage?, sizeToFit: Bool) {
        let tImage: UIImage = UIImage(named: "control_pad")!
        self.bgNode.texture = SKTexture(image: tImage)
        self.bgNode.texture?.filteringMode = .linear
    }
    var bgNodeDiametr: CGFloat {
        get { return self.bgNode.size.width }
    }
    var thumbNodeDiametr: CGFloat {
        get { return self.bgNode.size.width / 2 }
    }
    weak var delegate: AnalogStickProtocol? /*{
        didSet {
            velocityLoop?.invalidate()
            velocityLoop = nil
            if delegate != nil {
                velocityLoop = CADisplayLink(target: self, selector: #selector(AnalogStick.update))
                velocityLoop?.add(to: RunLoop.current, forMode: RunLoopMode(rawValue: RunLoopMode.commonModes.rawValue))
            }
        }
    }*/
        
    
    
    
    func update() {
        if isTracking {
            desiredAlpha = 0.95
            delegate?.moveAnalogStick(self, velocity: self.velocity, angularVelocity: self.angularVelocity)
        } else {
            desiredAlpha = 0.45
        }
        self.alpha = lerp(self.alpha, end: desiredAlpha, t: 0.1)
    }
    let kThumbSpringBackDuration: TimeInterval = 0.15 // action duration
    var isTracking = false
    var velocity = CGVector.zero, anchorPointInPoints = CGPoint.zero
    var angularVelocity = CGFloat()
    convenience init(thumbImage: UIImage?) {
        
        self.init(thumbImage: thumbImage, bgImage: nil)
    }
    convenience init(bgImage: UIImage?) {
        
        self.init(thumbImage: nil, bgImage: bgImage)
        
    }
    convenience override init() {
        
        self.init(thumbImage: nil, bgImage: nil)
        
    }
    init(thumbImage: UIImage?, bgImage: UIImage?) {
        
        self.thumbNode = SKSpriteNode()
        self.bgNode = SKSpriteNode()
        super.init()
        setUpAnalogStick()
        setThumbImage(thumbImage, sizeToFit: true)
        setBgImage(bgImage, sizeToFit: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.thumbNode = SKSpriteNode()
        self.bgNode = SKSpriteNode()
        super.init(coder: aDecoder)
        setUpAnalogStick()
        setScale(1.4)
    }
    
    private func setUpAnalogStick() {
        setThumbImage(UIImage(named: "analogstick_thmb"), sizeToFit: true)
        setBgImage(UIImage(named: "analogstick_bg"), sizeToFit: true)
        self.isUserInteractionEnabled = true
        self.isTracking = false
        self.velocity = CGVector.zero
        self.addChild(bgNode)
        self.addChild(thumbNode)
    }
    
    func reset() {
        
        self.velocity = CGVector.zero
        let easeOut: SKAction = SKAction.move(to: self.anchorPointInPoints, duration: kThumbSpringBackDuration)
        easeOut.timingMode = SKActionTimingMode.easeOut
        self.thumbNode.run(easeOut)
        self.isTracking = false
        
        delegate?.stoppedMovingAnalogStick(self)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        for touch: AnyObject in touches {
            
            let location: CGPoint = touch.location(in: self)
            let touchedNode = atPoint(location)
            if self.thumbNode == touchedNode && isTracking == false {
                isTracking = true
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event);
        for touch: AnyObject in touches {
            
            let location = touch.location(in: self);
            let xDistance: Float = Float(location.x - self.thumbNode.position.x)
            let yDistance: Float = Float(location.y - self.thumbNode.position.y)
            
            if self.isTracking == true && sqrtf(powf(xDistance, 2) + powf(yDistance, 2)) <= Float(self.bgNodeDiametr * 2) {
                let xAnchorDistance: CGFloat = (location.x - self.anchorPointInPoints.x)
                let yAnchorDistance: CGFloat = (location.y - self.anchorPointInPoints.y)
                if sqrt(pow(xAnchorDistance, 2) + pow(yAnchorDistance, 2)) <= self.thumbNode.size.width {
                    let moveDifference: CGPoint = CGPoint(x: xAnchorDistance , y: yAnchorDistance)
                    self.thumbNode.position = CGPoint(x: self.anchorPointInPoints.x + moveDifference.x, y: self.anchorPointInPoints.y + moveDifference.y)
                    
                } else {
                    
                    let magV = sqrt(xAnchorDistance * xAnchorDistance + yAnchorDistance * yAnchorDistance)
                    let aX = self.anchorPointInPoints.x + xAnchorDistance / magV * self.thumbNode.size.width
                    let aY = self.anchorPointInPoints.y + yAnchorDistance / magV * self.thumbNode.size.width
                    self.thumbNode.position = CGPoint(x: aX, y: aY)
                    
                }
                
                let tNAnchPoinXDiff: CGFloat = self.thumbNode.position.x - self.anchorPointInPoints.x
                let tNAnchPoinYDiff: CGFloat = self.thumbNode.position.y - self.anchorPointInPoints.y
                self.velocity = CGVector(dx: tNAnchPoinXDiff, dy: tNAnchPoinYDiff).unitVector()
                self.angularVelocity = CGFloat(-atan2f(Float(tNAnchPoinXDiff), Float(tNAnchPoinYDiff))) + CGFloat.pi / 2
            }
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.velocity = CGVector.zero
        reset()
        
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        reset()
    }
}
#endif
