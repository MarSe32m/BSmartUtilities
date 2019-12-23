//
//  CGExtensions.swift
//  Project Spacestation
//
//  Created by Sebastian on 25.6.2016.
//  Copyright © 2016 Sebastian Toivonen. All rights reserved.
//

import Foundation

#if canImport(CoreGraphics)
import CoreGraphics

public extension CGFloat {
    
    mutating func toRadians() -> CGFloat {
        self *= (.pi / 180)
        return self
    }
    
    mutating func toDegrees() -> CGFloat {
        self *= (180 / .pi)
        return self
    }
    
    func roundTo(decimals: Int) -> CGFloat {
        var divider = 10
        var float: CGFloat = self
        if decimals == 0 {
            float = CGFloat(Int(float))
            return float
        } else if decimals == 1 {
            let intValue = Int(float * CGFloat(divider))
            return CGFloat(intValue) / CGFloat(divider)
        }
        for _ in 1..<decimals {
            divider *= 10
        }
        let intValue = Int(float * CGFloat(divider))
        return CGFloat(intValue) / CGFloat(divider)
    }
    
}

public extension CGPoint {
    
    mutating func offset(dx: CGFloat, dy: CGFloat) -> CGPoint {
        x += dx
        y += dy
        return self
    }
    
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func lengthSquared() -> CGFloat {
        return x*x + y*y
    }
    
    func normalized() -> CGPoint {
        let len = length()
        return len > 0 ? self / len : CGPoint.zero
    }
    
    mutating func normalize() {
        self = normalized()
    }
    
    func distanceTo(_ point: CGPoint) -> CGFloat {
        return (self - point).length()
    }
    
    func squareDistanceTo(_ point: CGPoint) -> CGFloat {
        return (self - point).lengthSquared()
    }
    
    var angle: CGFloat {
        return atan2(y, x)
    }
    
    func rotated(by: CGFloat) -> CGPoint {
        return CGPoint(x: x * cos(by) - y * sin(by),
                        y: x * sin(by) + y * cos(by))
    }
}

extension CGVector {
    
    public func length() -> CGFloat {
        return sqrt(dx*dx + dy*dy)
    }
    
    public func lengthSquared() -> CGFloat {
        return dx*dx + dy*dy
    }
    
    public var angle: CGFloat {
        return atan2(dy, dx)
    }

    // Dot product
    static func * (left: CGVector, right: CGVector) -> CGFloat {
        return left.dx*right.dx + left.dy*right.dy
    }
    
    func rotated(by: CGFloat) -> CGVector {
        return CGVector(dx: dx * cos(by) - dy * sin(by),
                        dy: dx * sin(by) + dy * cos(by))
    }
    
}

extension CGSize {
    func aspectFill(_ target: CGSize) -> CGSize {
        let baseAspect = self.width / self.height
        let targetAspect = target.width / target.height
        if baseAspect > targetAspect {
            return CGSize(width: (target.height * width) / height, height: target.height)
        } else {
            return CGSize(width: target.width, height: (target.width * height) / width)
        }
    }
}

public func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

public func += ( left: inout CGPoint, right: CGPoint) {
    left = left + right
}

public func + (left: CGPoint, right: CGVector) -> CGPoint {
    return CGPoint(x: left.x + right.dx, y: left.y + right.dy)
}

public func += ( left: inout CGPoint, right: CGVector) {
    left = left + right
}

public func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

public func -= ( left: inout CGPoint, right: CGPoint) {
    left = left - right
}

public func - (left: CGPoint, right: CGVector) -> CGPoint {
    return CGPoint(x: left.x - right.dx, y: left.y - right.dy)
}

public func -= ( left: inout CGPoint, right: CGVector) {
    left = left - right
}

public func * (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x * right.x, y: left.y * right.y)
}

public func *= ( left: inout CGPoint, right: CGPoint) {
    left = left * right
}

public func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

public func * (point: CGPoint, scalar: Int) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

public func * (scalar: Int, point: CGPoint) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

public func * (cgfloat: CGFloat, integer: Int) -> CGFloat {
    return CGFloat(integer) * cgfloat
}

public func * (integer: Int, cgfloat: CGFloat) -> CGFloat {
    return CGFloat(integer) * cgfloat
}

public func * (size: CGSize, scalar: CGFloat) -> CGSize {
    return CGSize(width: size.width * scalar, height: size.height * scalar)
}

public func *= (size: inout CGSize, scalar: CGFloat) {
    size = CGSize(width: size.width * scalar, height: size.height * scalar)
}

public func * (vector: CGVector, scalar: CGFloat) -> CGVector {
    return CGVector(dx: vector.dx * scalar, dy: vector.dy * scalar)
}

public func *= ( point: inout CGPoint, scalar: CGFloat) {
    point = point * scalar
}

public func * (left: CGPoint, right: CGVector) -> CGPoint {
    return CGPoint(x: left.x * right.dx, y: left.y * right.dy)
}

public func *= ( left: inout CGPoint, right: CGVector) {
    left = left * right
}

public func / (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x / right.x, y: left.y / right.y)
}

public func /= ( left: inout CGPoint, right: CGPoint) {
    left = left / right
}

public func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

public func /= ( point: inout CGPoint, scalar: CGFloat) {
    point = point / scalar
}

public func / (left: CGPoint, right: CGVector) -> CGPoint {
    return CGPoint(x: left.x / right.dx, y: left.y / right.dy)
}

public func / (left: CGVector, right: CGFloat) -> CGVector {
    return CGVector(dx: left.dx / right, dy: left.dy / right)
}

public func /= ( left: inout CGPoint, right: CGVector) {
    left = left / right
}



public extension CGVector {
    
    func dotProductWithSelf() -> CGFloat {
        return dx*dx + dy*dy
    }
    
    func unitVector() -> CGVector {
        let len = length()
        if len == 0 {
            return CGVector.zero
        }
        return self / len
    }
    
    init(point: CGPoint) {
        self.init()
        self.dx = point.x
        self.dy = point.y
    }
    
    func orthogonalProjection(with vector: CGVector) -> CGVector {
        let dotProduct = self * vector
        return dotProduct / (vector.lengthSquared()) * vector
    }
    
    // In radians
    func angleTo(vector: CGVector) -> CGFloat {
        let dotProduct = self * vector
        let lengthProduct = self.length() * vector.length()
        if dotProduct - lengthProduct == 0 {
            return 0
        }
        return acos(dotProduct / lengthProduct)
    }
    
}

public func crossProductScalar(vector1: CGVector, vector2: CGVector) -> CGFloat{
    return vector1.dx*vector2.dy - vector1.dy*vector2.dx
}


public func + (left: CGVector, right: CGVector) -> CGVector {
    return CGVector(dx: left.dx + right.dx, dy: left.dy + right.dy)
}

public func += (left: inout CGVector, right: CGVector) {
    left = left + right
}

public func - (left: CGVector, right: CGVector) -> CGVector {
    return CGVector(dx: left.dx - right.dx, dy: left.dy - right.dy)
}

public func -= (left: inout CGVector, right: CGVector) {
    left = left - right
}

public func *= (lhs: inout CGVector, right: CGFloat) {
    lhs = lhs * right
}

public func * (left: CGFloat, right: CGPoint) -> CGPoint {
    return CGPoint(x: left * right.x, y: left * right.y)
}

public func * (right: CGFloat, left: CGVector) -> CGVector {
    return CGVector(dx: left.dx * right, dy: left.dy * right)
}

public func /= (left: inout CGVector, right: CGFloat) {
    left = left / right
}
#endif

