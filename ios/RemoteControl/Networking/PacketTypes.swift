import Foundation

public let kProtocolMagic: UInt32 = 0x524D544C

public enum PacketType: UInt32, Sendable {
    case handshakeRequest  = 0x0001
    case handshakeResponse = 0x0002
    case heartbeat         = 0x0003
    case heartbeatAck      = 0x0004
    case frameData         = 0x0101
    case frameConfig       = 0x0102
    case mouseMove         = 0x0201
    case mouseDown         = 0x0202
    case mouseUp           = 0x0203
    case mouseScroll       = 0x0204
    case keyboardEvent     = 0x0205
    case connectionQuality = 0x0301
    case deviceInfo        = 0x0302
    case disconnect        = 0xFFFF
}

public enum ConnectionQuality: UInt8, Codable, Sendable {
    case low    = 0
    case medium = 1
    case high   = 2
    case ultra  = 3
}

public struct HandshakePayload: Codable, Sendable {
    public var protocolVersion: UInt16 = 1
    public let deviceName: String
    public let screenWidth: UInt16
    public let screenHeight: UInt16
    public let capabilities: [String]
}

public struct FrameConfig: Codable, Sendable {
    public let quality: ConnectionQuality
    public let maxFps: UInt8
    public let scaleFactor: UInt8
}

public struct MouseMovePayload: Codable, Sendable {
    public let x: Float
    public let y: Float
}

public struct MouseClickPayload: Codable, Sendable {
    public let x: Float
    public let y: Float
    public let button: UInt8
}

public struct MouseScrollPayload: Codable, Sendable {
    public let deltaX: Float
    public let deltaY: Float
}

public struct KeyboardPayload: Codable, Sendable {
    public let keyCode: UInt16
    public let keyDown: Bool
    public let characters: String?
}

public struct Packet: Sendable {
    public let type: PacketType
    public let payload: Data

    public func serialize() -> Data {
        var header = Data()
        header.append(contentsOf: withUnsafeBytes(of: kProtocolMagic.bigEndian) { Data($0) })
        var length = UInt32(payload.count).bigEndian
        header.append(contentsOf: withUnsafeBytes(of: length) { Data($0) })
        var typeRaw = type.rawValue.bigEndian
        header.append(contentsOf: withUnsafeBytes(of: typeRaw) { Data($0) })
        return header + payload
    }

    public static func parse(from data: Data) -> (Packet, Data)? {
        let headerSize = 12
        guard data.count >= headerSize else { return nil }
        let magic = data.withUnsafeBytes { $0.load(as: UInt32.self) }.bigEndian
        guard magic == kProtocolMagic else { return nil }
        let length = data.withUnsafeBytes({ $0.load(fromByteOffset: 4, as: UInt32.self) }).bigEndian
        let typeRaw = data.withUnsafeBytes({ $0.load(fromByteOffset: 8, as: UInt32.self) }).bigEndian
        guard let type = PacketType(rawValue: typeRaw) else { return nil }
        let totalSize = headerSize + Int(length)
        guard data.count >= totalSize else { return nil }
        let payload = data[headerSize..<totalSize]
        let remaining = data[totalSize...]
        return (Packet(type: type, payload: payload), Data(remaining))
    }
}
