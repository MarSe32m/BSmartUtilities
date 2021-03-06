//
//  Utilities.swift
//
//  Created by Sebastian on 14.8.2017.
//  Copyright © 2017 Sebastian Toivonen. All rights reserved.
//
#if canImport(SpriteKit)
#if canImport(GameplayKit)
import SpriteKit
import GameplayKit

extension SKNode {
    var rotation: CGFloat {
        get {return CGFloat(fmod(Double(zRotation), .pi * 2))}
        set { zRotation = newValue }
    }
}

public extension SKColor {
    static func randomColor() -> SKColor {
        let r = CGFloat(GKRandomSource.sharedRandom().nextUniform())
        let g = CGFloat(GKRandomSource.sharedRandom().nextUniform())
        let b = CGFloat(GKRandomSource.sharedRandom().nextUniform())
        return SKColor(red: r, green: g, blue: b, alpha: 1.0)
    }
    func complementaryColor() -> SKColor {
        var hue: CGFloat = 0
        self.getHue(&hue, saturation: nil, brightness: nil, alpha: nil)
        if hue > 0.5 {
            hue -= 0.5
        } else {
            hue += 0.5
        }
        return SKColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
    }
    
    static var gold: SKColor {
        return SKColor(red: 255 / 255, green: 215 / 255, blue: 0, alpha: 1.0)
    }
    static var darkoliveGreen: SKColor {
        return SKColor(red: 85 / 255, green: 107 / 255, blue: 47 / 255, alpha: 1.0)
    }
    static var powderBlue: SKColor {
        return SKColor(red: 176 / 255, green: 224 / 255, blue: 230 / 255, alpha: 1.0)
    }
}

extension SKAction {
    class func shake(duration:CGFloat, amplitudeX:Int = 3, amplitudeY:Int = 3) -> SKAction {
        let numberOfShakes = duration / 0.015 / 2.0
        var actionsArray:[SKAction] = []
        for _ in 1...Int(numberOfShakes) {
            let dx = CGFloat(arc4random_uniform(UInt32(amplitudeX))) - CGFloat(amplitudeX / 2)
            let dy = CGFloat(arc4random_uniform(UInt32(amplitudeY))) - CGFloat(amplitudeY / 2)
            let forward = SKAction.moveBy(x: dx, y:dy, duration: 0.015)
            let reverse = forward.reversed()
            actionsArray.append(forward)
            actionsArray.append(reverse)
        }
        return SKAction.sequence(actionsArray)
    }
    
    class func hermiteInterpolation(duration: CGFloat, start: CGPoint, end: CGPoint, startVelocity: CGVector, endVelocity: CGVector) -> SKAction {
        let customAction = SKAction.customAction(withDuration: TimeInterval(duration)) { (node, elapsedTime) in
            let pos = hermiteSpline(startPos: start, startVelocity: startVelocity, endPos: end, endVelocity: endVelocity, t: elapsedTime / duration)
            node.position = pos
        }
        return customAction
    }
    
    class func colorizeWithRainbow(duration: CGFloat) -> SKAction {
        let actions = [SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: TimeInterval(duration / 7.0)),
                       SKAction.colorize(with: .orange, colorBlendFactor: 1.0, duration: TimeInterval(duration / 7.0)),
                       SKAction.colorize(with: .yellow, colorBlendFactor: 1.0, duration: TimeInterval(duration / 7.0)),
                       SKAction.colorize(with: .green, colorBlendFactor: 1.0, duration: TimeInterval(duration / 7.0)),
                       SKAction.colorize(with: .blue, colorBlendFactor: 1.0, duration: TimeInterval(duration / 7.0))]
        return sequence(actions)
    }
    
    class func colorizeFillColor(withSequence: SKKeyframeSequence, duration: CGFloat) -> SKAction {
        let customAction = SKAction.customAction(withDuration: TimeInterval(duration)) { (node, elapsedTime) in
            let timeValue = elapsedTime / duration
            let color = withSequence.sample(atTime: timeValue) as! SKColor
            if let shape = node as? SKShapeNode {
                shape.fillColor = color
            }
        }
        return customAction
    }
    
    class func typeOut(duration: CGFloat, text: String) -> SKAction {
        let timeBetweenCharacters: CGFloat = CGFloat(duration / CGFloat(text.count))
        let typeText = text
        var elapsedTypeTime: CGFloat = 0
        var lastElapsedTime: CGFloat = 0
        var index = 0
        let customAction = SKAction.customAction(withDuration: TimeInterval(duration)) { (node, elapsedTime) in
            if let label = node as? SKLabelNode {
                let deltaTime = elapsedTime - lastElapsedTime
                lastElapsedTime = elapsedTime
                elapsedTypeTime += deltaTime
                while elapsedTypeTime > timeBetweenCharacters {
                    index += 1
                    elapsedTypeTime -= timeBetweenCharacters
                    label.text = String(typeText.dropLast(text.count - index))
                }
            }
            
        }
        return SKAction.sequence([customAction, ])
    }
    
    class func smoothFollow(path: [CGPoint], speed: CGFloat) -> SKAction {
        var distance: CGFloat = 0
        if path.count <= 1 {
            return SKAction()
        }
        for i in 0..<path.count - 1 {
            distance += path[i].distanceTo(path[i + 1])
        }
        let customAction = SKAction.customAction(withDuration: 100) { (node, elapsedTime) in

            
            
        }
        return customAction
    }
    
    class func seekTarget(targetNode: SKNode, speed: CGFloat, duration: TimeInterval) -> SKAction {
        var velocity = CGVector(dx: 0, dy: 0)
        var lastElapsedTime: CGFloat = 0
        let customAction = SKAction.customAction(withDuration: duration) { (node, elapsedTime) in
            let deltaTime = elapsedTime - lastElapsedTime
            lastElapsedTime = elapsedTime
            velocity = CGVector(point: targetNode.position - node.position)
            if velocity.length() > speed * deltaTime {
                velocity = velocity.unitVector() * speed * deltaTime
            }
            node.position += velocity
        }
        return customAction
    }
}

extension SKSpriteNode {
    
    func removeGlow() {
        self.enumerateChildNodes(withName: "glow") { (node, void) in
            node.removeFromParent()
        }
    }
    
    func addGlow(radius: Float = 30) {
        let effectNode = SKEffectNode()
        effectNode.shouldRasterize = true
        effectNode.name = "glow"
        self.addChild(effectNode)
        let sprite = SKSpriteNode(texture: texture)
        sprite.blendMode = .add
        sprite.size = self.size
        effectNode.addChild(sprite)
        effectNode.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius":radius])
    }
    
    func addBlur() -> SKEffectNode {
        let effectNode = SKEffectNode()
        effectNode.shouldRasterize = true
        effectNode.name = "blur"
        effectNode.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius":200])
        return effectNode
    }
    
    }

extension SKShader {
    class func createWater(speed: Float, strength: Float, frequency: Float) -> SKShader {
        let uniforms: [SKUniform] = [
            SKUniform(name: "u_speed", float: speed),
            SKUniform(name: "u_strength", float: strength),
            SKUniform(name: "u_frequency", float: frequency)
        ]
        return SKShader(fromFile: "SHKWater", uniforms: uniforms)
    }
}

extension SKCameraNode {
    func followNode(target: SKNode, offset: CGVector, smoothTime: CGFloat, currentVelocity: inout CGVector, dt: CGFloat) {
        position = smoothDamp(currentPosition: position, targetPosition: target.position + offset, currentVelocity: &currentVelocity, smoothTime: smoothTime, deltaTime: dt)
        
    }
}

extension SKPhysicsBody {
    open var kineticEnergy: CGFloat {
        get {
            return 0.5 * mass * velocity.lengthSquared()
        }
    }
    
    open var potentialEnergy: CGFloat {
        get {
            guard let node = node else {
                return 0
            }
            return mass * 9.81 * node.position.y
        }
    }
}

extension SKLabelNode {
    
    func setText(_ text: String) {
        self.text = text
        (childNode(withName: "shadow") as? SKLabelNode)?.text = text
    }
    
}

extension SKTexture {
    func getPixelColor(pos: CGPoint) -> SKColor {
        let pixelData = self.cgImage().dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let pixelInfo: Int = ((Int(self.size().width) * Int(pos.y)) + Int(pos.x)) * 4
        
        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        
        return SKColor(red: r, green: g, blue: b, alpha: a)
    }
    func getAveragePixelColor() -> SKColor {
        let pixelData = self.cgImage().dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        
        for x in 0...Int(self.size().width) {
            for y in 0...Int(self.size().height) {
                let pixelInfo: Int = ((Int(self.size().width) * y) + x) * 4
                let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
                r += CGFloat(data[pixelInfo]) / CGFloat(255.0) * a
                g += CGFloat(data[pixelInfo+1]) / CGFloat(255.0) * a
                b += CGFloat(data[pixelInfo+2]) / CGFloat(255.0) * a
            }
        }
        
        r /= self.size().width * self.size().height
        g /= self.size().width * self.size().height
        b /= self.size().width * self.size().height
        
        return SKColor(red: r, green: g, blue: b, alpha: 1.0)
    }
}

extension SKShapeNode {
    public static func roundedRect(width: CGFloat, height: CGFloat) -> SKShapeNode{
        let path = CGMutablePath()
        path.move(to: CGPoint(x: width, y: 0))
        for theta in stride(from: 0, to: 2 * CGFloat.pi, by: 0.2) {
            let na: CGFloat = 2 / 4
            let x = CGFloat(pow(abs(cos(theta)), na) * width * CGFloat(sign(cos(Double(theta)))))
            let y = CGFloat(pow(abs(sin(theta)), na) * height * CGFloat(sign(sin(Double(theta)))))
            path.addLine(to: CGPoint(x: x, y: y))
        }
        path.closeSubpath()
        return SKShapeNode(path: path, centered: true)
    }
    
    public static func shape(width: CGFloat, height: CGFloat, withCorners corners: CGFloat) -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: width, y: 0))
        for theta in stride(from: 0, to: 2 * CGFloat.pi, by: 2 * CGFloat.pi / corners) {
            let x = cos(theta) * width
            let y = sin(theta) * height
            path.addLine(to: CGPoint(x: x, y: y))
        }
        path.closeSubpath()
        let shapenode = SKShapeNode(path: path, centered: true)
        shapenode.lineCap = .round
        shapenode.name = "shape_\(Int(corners))"
        return shapenode
    }
    
    public static func upArrowTop(width: CGFloat, height: CGFloat) -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -width / 2, y: -height / 2))
        path.addLine(to: CGPoint(x: 0, y: height / 2))
        path.addLine(to: CGPoint(x: width / 2, y: -height / 2))
        let shapeNode = SKShapeNode(path: path, centered: true)
        shapeNode.lineCap = .round
        return shapeNode
    }
    
    public static func downArrowTop(width: CGFloat, height: CGFloat) -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -width / 2, y: height / 2))
        path.addLine(to: CGPoint(x: 0, y: -height / 2))
        path.addLine(to: CGPoint(x: width / 2, y: height / 2))
        let shapeNode = SKShapeNode(path: path, centered: true)
        shapeNode.lineCap = .round
        return shapeNode
    }
    
    public static func thunderBolt(width: CGFloat, height: CGFloat) -> SKShapeNode {
        let path = CGMutablePath()
        var points = [CGPoint(x: width / 4.0, y: 7.0 * height / 8.0),
                      CGPoint(x: width / 8, y: height / 2.0),
                      CGPoint(x: width * 3.0 / 8.0, y: height / 2.0),
                      CGPoint(x: width / 4.0, y: height / 8.0),
                      CGPoint(x: width * 7.0 / 8.0, y: height * 5.0 / 8.0),
                      CGPoint(x: width * 5.0 / 8.0, y: height * 5.0 / 8.0),
                      CGPoint(x: width * 6.0 / 8.0, y: height * 7.0 / 8.0),
                      CGPoint(x: width / 4.0, y: height * 7.0 / 8.0)]
        for point in points {
            if let index = points.firstIndex(of: point) {
                points[index] -= 0.5 * CGPoint(x: width, y: height)
            }
        }
        path.addLines(between: points)
        let shapeNode = SKShapeNode(path: path, centered: true)
        shapeNode.fillColor = .yellow
        shapeNode.strokeColor = .black
        shapeNode.lineWidth = 5
        shapeNode.lineCap = .round
        shapeNode.lineJoin = .round
        return shapeNode
    }
    
}

//MARK: GridNode
class GridNode: SKSpriteNode {
    var rows:Int!
    var cols:Int!
    var blockSize:CGFloat!
    
    convenience init(blockSize:CGFloat,rows:Int,cols:Int) {
        guard let texture = GridNode.gridTexture(blockSize: blockSize,rows: rows, cols:cols) else {
            self.init()
            return
        }
        self.init(texture: texture, color:SKColor.clear, size: texture.size())
        self.blockSize = blockSize
        self.rows = rows
        self.cols = cols
    }
    
    class func gridTexture(blockSize:CGFloat,rows:Int,cols:Int) -> SKTexture? {
        // Add 1 to the height and width to ensure the borders are within the sprite
        let size = CGSize(width: CGFloat(cols)*blockSize+1.0, height: CGFloat(rows)*blockSize+1.0)
        UIGraphicsBeginImageContext(size)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        let bezierPath = UIBezierPath()
        let offset:CGFloat = 0.5
        // Draw vertical lines
        for i in 0...cols {
            let x = CGFloat(i)*blockSize + offset
            bezierPath.move(to: CGPoint(x: x, y: 0))
            bezierPath.addLine(to: CGPoint(x: x, y: size.height))
        }
        // Draw horizontal lines
        for i in 0...rows {
            let y = CGFloat(i)*blockSize + offset
            bezierPath.move(to: CGPoint(x: 0, y: y))
            bezierPath.addLine(to: CGPoint(x: size.width, y: y))
        }
        SKColor.lightGray.setStroke()
        bezierPath.lineWidth = 1.2
        bezierPath.stroke()
        context.addPath(bezierPath.cgPath)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return SKTexture(image: image!)
    }
    
    func gridPosition(row:Int, col:Int) -> CGPoint {
        let offset = CGFloat(blockSize / 2.0 + 0.5)
        let a = CGFloat(col) * blockSize
        let b = (blockSize * CGFloat(cols)) / 2.0
        let x = a - b + offset
        let y = CGFloat(rows - row - 1) * blockSize - (blockSize * CGFloat(rows)) / 2.0 + offset
        return CGPoint(x:x, y:y)
    }
}

//MARK: Camera
class Camera: SKCameraNode {
    
    private var focusArea: FocusArea!
    private var focusAreaSize: CGSize = CGSize(width: 175, height: 75)
    var targetNode: SKNode!
    var targetShip: SKNode!

    var followTargetNode: Bool = true
    var debugDrawing: SKShapeNode!
    
    var lookAheadDstX: CGFloat = 150
    var lookSmoothTimeX: CGFloat = 0.25
    var verticalSmoothTime: CGFloat = 0.25
    
    var currentLookAheadX: CGFloat = 0
    var targetLookAheadX: CGFloat = 0
    var lookAheadDirectionX: CGFloat = 1
    var smoothVelocityX: CGFloat = 0
    var smoothVelocityY: CGFloat = 0
    
    var lookAhead: Bool = false
    
    var lookAheadStopped: Bool = false
    
    var verticalOffset: CGVector = CGVector(dx: 0, dy: 0)
    
    var maximumPoint: CGPoint = CGPoint(x: 100000, y: 100000)
    var minimumPoint: CGPoint = CGPoint(x: -100000, y: -100000)
    
    init(targetNode: SKNode, cameraNode: SKCameraNode) {
        self.focusArea = FocusArea(targetBounds: targetNode.frame, size: focusAreaSize)
        self.debugDrawing = SKShapeNode(rect: CGRect(origin: CGPoint.zero, size: focusAreaSize))
        self.targetNode = targetNode
        super.init()
        position = cameraNode.position
        zRotation = cameraNode.zRotation
        self.setScale(cameraNode.xScale)
        if let uiNode = cameraNode.childNode(withName: "UI") {
            for childNode in uiNode.children {
                childNode.move(toParent: self)
                childNode.removeFromParent()
                self.addChild(childNode)
            }
        }
        self.zPosition = cameraNode.zPosition
        self.name = cameraNode.name
        debugDrawing.isHidden = false
        debugDrawing.strokeColor = .cyan
        cameraNode.removeFromParent()
    }
    
    convenience init(targetShip: SKNode, cameraNode: SKCameraNode) {
        self.init(targetNode: targetShip, cameraNode: cameraNode)
        self.targetShip = targetShip
    }
    
    func update(_ deltaTime: CGFloat) {
        if !followTargetNode {
            return
        }
        focusArea.update(targetBounds: targetNode.frame)
        debugDrawing.position = focusArea.center - CGPoint(x: debugDrawing.frame.width / 2, y: debugDrawing.frame.height / 2)
        
        var focusPosition = focusArea.center + verticalOffset
        
        //currentLookAheadX = smoothDamp(current: currentLookAheadX, target: targetLookAheadX, currentVelocity: &smoothVelocityX, smoothTime: lookSmoothTimeX, deltaTime: CGFloat(deltaTime))
        
        focusPosition.y = smoothDamp(current: self.position.y, target: focusPosition.y, currentVelocity: &smoothVelocityY, smoothTime: verticalSmoothTime, deltaTime: deltaTime)
        focusPosition.x = smoothDamp(current: self.position.x, target: focusPosition.x, currentVelocity: &smoothVelocityX, smoothTime: lookSmoothTimeX, deltaTime: deltaTime)
        focusPosition.x += currentLookAheadX
        
        self.position = focusPosition
        clamp(current: &self.position, min: minimumPoint, max: maximumPoint)
        
    }
    
    private struct FocusArea {
        var center: CGPoint
        var velocity: CGVector
        var left: CGFloat
        var right: CGFloat
        var top: CGFloat
        var bottom: CGFloat
        
        init(targetBounds: CGRect, size: CGSize) {
            left = targetBounds.origin.x - size.width / 2
            right = targetBounds.origin.x + size.width / 2
            bottom = targetBounds.minY
            top = targetBounds.minY + size.height
            
            center = CGPoint(x: (left + right) / 2, y: (bottom + top) / 2)
            velocity = CGVector.zero
        }
        
        mutating func update(targetBounds: CGRect) {
            var shiftX: CGFloat = 0
            if targetBounds.minX < left {
                shiftX = targetBounds.minX - left
            } else if targetBounds.maxX > right {
                shiftX = targetBounds.maxX - right
            }
            left += shiftX
            right += shiftX
            
            var shiftY: CGFloat = 0
            if targetBounds.minY < bottom {
                shiftY = targetBounds.minY - bottom
            } else if targetBounds.maxY > top {
                shiftY = targetBounds.maxY - top
            }
            bottom += shiftY
            top += shiftY
            
            center = CGPoint(x: (left + right) / 2, y: (bottom + top) / 2)
            velocity = CGVector(dx: shiftX, dy: shiftY)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        print("Decoding camera from scene!")
        
    }
}
#endif
#endif
