import Foundation
import Network
import UIKit

public protocol TransportDelegate: AnyObject {
    func transportDidConnect()
    func transportDidDisconnect(error: Error?)
    func transportDidReceive(packet: Packet)
}

public protocol Transport: AnyObject {
    var delegate: TransportDelegate? { get set }
    var isConnected: Bool { get }
    func start()
    func stop()
    func send(packet: Packet) throws
}

public final class TCPTransport: Transport {
    public weak var delegate: TransportDelegate?
    public private(set) var isConnected = false

    private let port: UInt16
    private let serviceType = "_remoteios._tcp"
    private var listener: NWListener?
    private var connection: NWConnection?
    private let queue = DispatchQueue(label: "com.remotecontrol.tcp",
                                      qos: .userInitiated)
    private var readBuffer = Data()

    public init(port: UInt16 = 5288) {
        self.port = port
    }

    public func start() {
        guard listener == nil else { return }
        do {
            let params = NWParameters.tcp
            params.includePeerToPeer = true
            listener = try NWListener(using: params, on: NWEndpoint.Port(rawValue: port)!)
            listener?.service = NWListener.Service(type: serviceType,
                                                   txtRecord: txtRecord())
            listener?.newConnectionHandler = { [weak self] conn in
                self?.handleNewConnection(conn)
            }
            listener?.stateUpdateHandler = { [weak self] state in
                self?.handleListenerState(state)
            }
            listener?.start(queue: queue)
        } catch {
            delegate?.transportDidDisconnect(error: error)
        }
    }

    public func stop() {
        connection?.cancel()
        connection = nil
        listener?.cancel()
        listener = nil
        isConnected = false
    }

    public func send(packet: Packet) throws {
        guard let conn = connection, isConnected else {
            throw TransportError.notConnected
        }
        let data = packet.serialize()
        conn.send(content: data, completion: .contentProcessed({ [weak self] error in
            if let error = error {
                self?.delegate?.transportDidDisconnect(error: error)
            }
        }))
    }

    private func handleNewConnection(_ conn: NWConnection) {
        connection?.cancel()
        connection = conn
        conn.stateUpdateHandler = { [weak self] state in
            self?.handleConnectionState(state)
        }
        conn.start(queue: queue)
        receiveNext()
    }

    private func receiveNext() {
        connection?.receive(minimumIncompleteLength: 1,
                           maximumLength: 65536)
        { [weak self] data, _, isComplete, error in
            guard let self = self else { return }
            if let data = data, !data.isEmpty {
                self.readBuffer.append(data)
                self.processPackets()
            }
            if isComplete {
                self.delegate?.transportDidDisconnect(error: nil)
            } else if let error = error {
                self.delegate?.transportDidDisconnect(error: error)
            } else {
                self.receiveNext()
            }
        }
    }

    private func processPackets() {
        while let (packet, remaining) = Packet.parse(from: readBuffer) {
            readBuffer = remaining
            delegate?.transportDidReceive(packet: packet)
        }
    }

    private func handleListenerState(_ state: NWListener.State) {
        switch state {
        case .failed(let error):
            delegate?.transportDidDisconnect(error: error)
        default:
            break
        }
    }

    private func handleConnectionState(_ state: NWConnection.State) {
        switch state {
        case .ready:
            isConnected = true
            delegate?.transportDidConnect()
        case .failed(let error):
            isConnected = false
            delegate?.transportDidDisconnect(error: error)
        case .cancelled:
            isConnected = false
            delegate?.transportDidDisconnect(error: nil)
        default:
            break
        }
    }

    private func txtRecord() -> Data {
        var data = Data()
        let pairs = [
            "version=1",
            "device=\(UIDevice.current.name)",
            "model=\(UIDevice.current.model)"
        ]
        for pair in pairs {
            let bytes = [UInt8](pair.utf8)
            data.append(UInt8(bytes.count))
            data.append(contentsOf: bytes)
        }
        return data
    }
}

public enum TransportError: LocalizedError {
    case notConnected
    case sendFailed

    public var errorDescription: String? {
        switch self {
        case .notConnected: return "Not connected to any client"
        case .sendFailed: return "Failed to send data"
        }
    }
}
