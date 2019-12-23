//
//  Math.swift
//  
//
//  Created by Sebastian Toivonen on 23.12.2019.
//

import Foundation
import CoreGraphics

func invSqrt(x: Double) -> Double {
    let halfx = 0.5 * x
    var i = x.bitPattern
    i = 0x5f3759df - (i >> 1)
    var y = Double(bitPattern: i)
    y = y * (1.5 - (halfx * y * y))
    return y
}

public func invSqrt(x: Float) -> Float {
    let halfx = 0.5 * x
    var i = x.bitPattern
    i = 0x5f3759df - (i >> 1)
    var y = Float(bitPattern: i)
    y = y * (1.5 - (halfx * y * y))
    return y
}

public func ln(_ value: Double) -> Double {
    return log(value) / log(M_E)
}

public func smoothMin(a: Float, b: Float, k: Float) -> Float {
    if k == 0 {
        return min(a, b)
    }
    let h = max(k - abs(a - b), 0) / k
    return min(a, b) - h*h*h*h*1/6.0
}

public func smoothMin(a: CGFloat, b: CGFloat, k: CGFloat) -> CGFloat {
    if k == 0 {
        return min(a, b)
    }
    let h = max(k - abs(a - b), 0) / k
    return min(a, b) - h*h*h*h*1/6.0
}

public func invSqrt(x: CGFloat) -> CGFloat {
    let halfx = 0.5 * x
    var i = x.bitPattern
    i = 0x5f3759df - (i >> 1)
    var y = CGFloat(bitPattern: i)
    y = y * (1.5 - (halfx * y * y))
    return y
}



public func sign(value: CGFloat) -> Int {
    return value >= 0 ? 1 : -1
}

func exponentialSmoothingFunction(t: Float) -> Float {
    return (t == 1.0) ? t : 1.0 - pow(Float(M_E), -6.0 * t)
}

public postfix func ++(a: inout Int) -> Int {
    a += 1
    return a - 1
}

public prefix func ++(a: inout Int) -> Int {
    a += 1
    return a
}

public postfix func ++(a: inout UInt64) -> UInt64 {
    a += 1
    return a - 1
}

public prefix func ++(a: inout UInt64) -> UInt64 {
    a += 1
    return a
}

/// Calculates the collision point of two moving (point) objects
func collisionPoint(targetStartPosition: CGPoint, targetVelocity: CGVector, bulletStartPosition: CGPoint, bulletSpeed: CGFloat) -> CGPoint? {
    let a = targetVelocity.lengthSquared() - bulletSpeed * bulletSpeed
    let b = 2 * (targetVelocity.dx * (targetStartPosition.x - bulletStartPosition.x) + targetVelocity.dy * (targetStartPosition.y - bulletStartPosition.y))
    let c = (targetStartPosition - bulletStartPosition).lengthSquared()
    let d = b * b - 4 * a * c
    
    if d < 0 {
        return nil
    }
    
    let t1 = (-b + d) / (2 * a)
    let t2 = (-b - d) / (2 * a)
    
    let t = max(0, min(t1, t2))
    
    if t == 0 {
        return nil
    }
    
    let targetPos = targetStartPosition + targetVelocity * t
    return targetPos
}

public func smoothDamp(currentVector: CGVector, targetVector: CGVector, currentVelocity: inout CGVector, smoothTime time: CGFloat, deltaTime: CGFloat) -> CGVector {
    let newDX = smoothDamp(current: currentVector.dx, target: targetVector.dx, currentVelocity: &currentVelocity.dx, smoothTime: time, deltaTime: deltaTime)
    let newDY = smoothDamp(current: currentVector.dy, target: targetVector.dy, currentVelocity: &currentVelocity.dy, smoothTime: time, deltaTime: deltaTime)
    return CGVector(dx: newDX, dy: newDY)
}

public func smoothDamp(currentPosition: CGPoint, targetPosition: CGPoint, currentVelocity: inout CGVector, smoothTime time: CGFloat, deltaTime: CGFloat) -> CGPoint {
    let newX = smoothDamp(current: currentPosition.x, target: targetPosition.x, currentVelocity: &currentVelocity.dx, smoothTime: time, deltaTime: deltaTime)
    let newY = smoothDamp(current: currentPosition.y, target: targetPosition.y, currentVelocity: &currentVelocity.dy, smoothTime: time, deltaTime: deltaTime)
    return CGPoint(x: newX, y: newY)
}

public func smoothDamp(current c: CGFloat, target t: CGFloat, currentVelocity: inout CGFloat, smoothTime time: CGFloat, maxSpeed: CGFloat = CGFloat.infinity, deltaTime: CGFloat) -> CGFloat {
    let smoothTime = max(0.0001, time)
    let num  = 2 / smoothTime
    let num2 = num * deltaTime
    let num3 = 1 / (1 + num2 + 0.48 * num2 * num2 + 0.235 * num2 * num2 * num2)
    var num4 = c - t
    let num5 = t
    let num6 = maxSpeed * smoothTime
    num4 = min(max(num4, -num6), num6)
    let target = c - num4
    let num7 = (currentVelocity + num * num4) * deltaTime
    currentVelocity = (currentVelocity - num * num7) * num3
    var num8 = target + (num4 + num7) * num3
    if (num5 - c > 0) == (num8 > num5) {
        num8 = num5
        currentVelocity = (num8 - num5) / deltaTime
    }
    return num8
}

func hermiteSpline(startPos: CGPoint, startVelocity: CGVector, endPos: CGPoint, endVelocity: CGVector, t: CGFloat) -> CGPoint {
    var result = CGPoint.zero
    let t2 = t * t
    let t3 = t2 * t
    result += (2 * t3 - 3 * t2 + 1) * startPos
    result += (t3 - 2 * t2 + t) * startVelocity
    result += (-2 * t3 + 3 * t2) * endPos
    result += (t3 - t2) * endVelocity
    return result
}

public func lerp(_ start: CGPoint, end: CGPoint, t: CGFloat) -> CGPoint {
    return start + (end - start) * t
}

public func lerp(_ start: CGVector, end: CGVector, t: CGFloat) -> CGVector {
    return start + (end - start) * t
}

public func lerp(_ start: CGFloat, end: CGFloat, t: CGFloat) -> CGFloat {
    return start + (end - start) * t
}

public func lerp(_ start: Float, end: Float, t: Float) -> Int {
    return Int(start + (end - start) * t)
}

public func lerpRot(_ start: CGFloat, end: CGFloat, t: CGFloat) -> CGFloat {
    let max = Double.pi * 2
    let da = Double(end - start).truncatingRemainder(dividingBy: max)
    let shortAngleDist = CGFloat((2 * da).truncatingRemainder(dividingBy: max) - da)
    return start + shortAngleDist * t
}

public func lerpRot(_ startAngle: CGFloat, endAngle: CGFloat, t: CGFloat) -> CGFloat {
    let start = Int(radiansToDegrees(radians: startAngle))
    let end = Int(radiansToDegrees(radians: endAngle))
    let shortestAngleInDegrees = CGFloat(((((end - start) % 360) + 540) % 360) - 180)
    let shortestAngle = degreesToRadians(degrees: shortestAngleInDegrees)
    return shortestAngle * t
}


public func clamp(current: inout CGFloat, min: CGFloat, max: CGFloat) {
    current = current < min ? min : (current > max) ? max : current
}

public func clamp(current: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
    return ((current < min) ? min : (current > max ? max : current))
}

public func clamp(current: CGPoint, min: CGPoint, max: CGPoint) -> CGPoint {
    let newX: CGFloat = clamp(current: current.x, min: min.x, max: max.x)
    let newY: CGFloat = clamp(current: current.y, min: min.y, max: max.y)
    return CGPoint(x: newX, y: newY)
}

public func clamp(current: inout CGPoint, min: CGPoint, max: CGPoint) {
    let newX: CGFloat = clamp(current: current.x, min: min.x, max: max.x)
    let newY: CGFloat = clamp(current: current.y, min: min.y, max: max.y)
    current = CGPoint(x: newX, y: newY)
}

public func clamp(current: CGVector, min: CGVector, max: CGVector) -> CGVector {
    let newX: CGFloat = clamp(current: current.dx, min: min.dx, max: max.dx)
    let newY: CGFloat = clamp(current: current.dy, min: min.dy, max: max.dy)
    return CGVector(dx: newX, dy: newY)
}

public func clamp(current: inout CGVector, min: CGVector, max: CGVector) {
    let newX: CGFloat = clamp(current: current.dx, min: min.dx, max: max.dx)
    let newY: CGFloat = clamp(current: current.dy, min: min.dy, max: max.dy)
    current = CGVector(dx: newX, dy: newY)
}

public func degreesToRadians(degrees: CGFloat) -> CGFloat {
    return degrees * (CGFloat.pi / 180)
}

public func radiansToDegrees(radians: CGFloat) -> CGFloat {
    return radians * (180 / CGFloat.pi)
}
