import Foundation

let kProtocolMagic: UInt32 = 0x524D544C

enum PacketType: UInt32, Codable, Sendable {
    case handshake     = 0x0001
    case heartbeat     = 0x0002
    case heartbeatAck  = 0x0003
    case frameData     = 0x0101
    case mouseMove     = 0x0201
    case mouseDown     = 0x0202
    case mouseUp       = 0x0203
    case mouseScroll   = 0x0204
    case disconnect    = 0xFFFF
}

enum ConnectionQuality: UInt8, Codable, Sendable {
    case low    = 0
    case medium = 1
    case high   = 2
    case ultra  = 3
}

struct HandshakeMessage: Codable, Sendable {
    var deviceName: String
    var version: String
}

struct MouseMoveMessage: Codable, Sendable {
    var x: Float
    var y: Float
}

struct MouseClickMessage: Codable, Sendable {
    var x: Float
    var y: Float
    var button: UInt8
}

struct MouseScrollMessage: Codable, Sendable {
    var deltaX: Float
    var deltaY: Float
}

struct Packet: Sendable {
    var type: PacketType
    var payload: Data

    func serialize() -> Data {
        var data = Data()
        withUnsafeBytes(of: kProtocolMagic.bigEndian) { data.append(contentsOf: $0) }
        let len = UInt32(payload.count).bigEndian
        withUnsafeBytes(of: len) { data.append(contentsOf: $0) }
        let t = type.rawValue.bigEndian
        withUnsafeBytes(of: t) { data.append(contentsOf: $0) }
        data.append(payload)
        return data
    }

    static func parse(from data: Data) -> (Packet, Data)? {
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
