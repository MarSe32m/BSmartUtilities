/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Protocols for defining types that can encode to bit streams.
*/

import Foundation
import CoreGraphics

protocol BitStreamEncodable {
    func encode(to bitStream: inout WritableBitStream) -> Bool
}

protocol BitStreamDecodable {
    init?(from bitStream: inout ReadableBitStream)
}

/// - Tag: BitStreamCodable
typealias BitStreamCodable = BitStreamDecodable & BitStreamEncodable

extension BitStreamEncodable where Self: Encodable {
    func encode(to bitStream: inout WritableBitStream) throws {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary
        let data = try encoder.encode(self)
        bitStream.append(data)
    }
}

extension BitStreamDecodable where Self: Decodable {
    init(from bitStream: inout ReadableBitStream) throws {
        let data = try bitStream.readData()
        let decoder = PropertyListDecoder()
        self = try decoder.decode(Self.self, from: data)
    }
}

extension UInt32: BitStreamCodable {
    init?(from bitStream: inout ReadableBitStream, numberOfBits: Int) {
        do {
            self = try bitStream.readUInt32(numberOfBits: numberOfBits)
        } catch let error {
            print("Error decoding UInt32 with \(numberOfBits) bits")
            print(error)
            return nil
        }
    }
    
    init?(from bitStream: inout ReadableBitStream) {
        do {
            self = try bitStream.readUInt32()
        } catch let error {
            print("Error decoding UInt32")
            print(error)
            return nil
        }
    }
    
    func encode(to bitStream: inout WritableBitStream, numberOfBits: Int) -> Bool {
        bitStream.appendUInt32(self, numberOfBits: numberOfBits)
        return true
    }
    
    func encode(to bitStream: inout WritableBitStream) -> Bool {
        bitStream.appendUInt32(self)
        return true
    }
}

extension Float: BitStreamCodable {
    init?(from bitStream: inout ReadableBitStream) {
        do {
            self = try bitStream.readFloat()
        } catch let error {
            print("Error decoding Float")
            print(error)
            return nil
        }
    }
    
    func encode(to bitStream: inout WritableBitStream) -> Bool {
        bitStream.appendFloat(self)
        return true
    }
}

extension CGFloat: BitStreamCodable {
    init?(from bitStream: inout ReadableBitStream) {
        do {
            self = try bitStream.readCGFloat()
        } catch let error {
            print("Error decoding CGFloat.")
            print(error)
            return nil
        }
    }
    
    func encode(to bitStream: inout WritableBitStream) -> Bool {
        bitStream.appendCGFloat(self)
        return true
    }
}

extension String: BitStreamCodable {
    init?(from bitStream: inout ReadableBitStream) {
        do {
            let data = try bitStream.readData()
            if let string = String(data: data, encoding: .utf8) {
                self.init(string)
            } else {
                return nil
            }
        } catch {
            print("Error decoding a String")
            return nil
        }
        
    }
    
    func encode(to bitStream: inout WritableBitStream) -> Bool {
        if let data = data(using: .utf8) {
            bitStream.append(data)
            return true
        } else {
            return false
        }
    }
}

extension CGPoint: BitStreamCodable {
    
    init?(from bitStream: inout ReadableBitStream) {
        do {
            let x = try bitStream.readCGFloat()
            let y = try bitStream.readCGFloat()
            self.init(x: x, y: y)
        } catch {
            return nil
        }
    }
    
    func encode(to bitStream: inout WritableBitStream) -> Bool {
        bitStream.appendCGFloat(x)
        bitStream.appendCGFloat(y)
        return true
    }
    
}

extension CGVector: BitStreamCodable {
    init?(from bitStream: inout ReadableBitStream) {
        do {
            let dx = try bitStream.readCGFloat()
            let dy = try bitStream.readCGFloat()
            self.init(dx: dx, dy: dy)
        } catch {
            return nil
        }
    }
    
    func encode(to bitStream: inout WritableBitStream) -> Bool {
        bitStream.appendCGFloat(dx)
        bitStream.appendCGFloat(dy)
        return true
    }
    
}
