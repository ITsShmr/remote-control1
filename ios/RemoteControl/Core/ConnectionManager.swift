import Foundation
import UIKit

public enum ConnectionMethod: String, CaseIterable, Sendable {
    case usb = "USB"
    case wifi = "WiFi"
    case bluetooth = "Bluetooth"
}

public enum ConnectionState: Sendable, Hashable {
    case disconnected
    case connecting
    case connected(method: ConnectionMethod)
    case failed(Error)

    public func hash(into hasher: inout Hasher) {
        switch self {
        case .disconnected: hasher.combine(0)
        case .connecting: hasher.combine(1)
        case .connected(let method): hasher.combine(2); hasher.combine(method)
        case .failed: hasher.combine(3)
        }
    }
}

public protocol ConnectionManagerDelegate: AnyObject {
    func connectionStateDidChange(_ state: ConnectionState)
    func didReceivePacket(_ packet: Packet)
}

public final class ConnectionManager {
    public static let shared = ConnectionManager()
    public weak var delegate: ConnectionManagerDelegate?

    public private(set) var state: ConnectionState = .disconnected {
        didSet { delegate?.connectionStateDidChange(state) }
    }

    private var transports: [Transport] = []
    private var activeTransport: Transport?
    private var heartbeatTimer: Timer?
    private var lastHeartbeat = Date()

    private init() {}

    public func start(port: UInt16 = 5288) {
        guard case .disconnected = state else { return }

        let tcp = TCPTransport(port: port)
        let bt = BluetoothTransport()

        tcp.delegate = self
        bt.delegate = self

        transports = [tcp, bt]
        state = .connecting

        tcp.start()
        bt.start()
    }

    public func stop() {
        heartbeatTimer?.invalidate()
        heartbeatTimer = nil
        for transport in transports {
            transport.stop()
        }
        transports.removeAll()
        activeTransport = nil
        state = .disconnected
    }

    public func send(packet: Packet) throws {
        guard let transport = activeTransport, transport.isConnected else {
            throw TransportError.notConnected
        }
        try transport.send(packet: packet)
    }

    public func sendFrame(data: Data) {
        guard activeTransport?.isConnected == true else { return }
        let packet = Packet(type: .frameData, payload: data)
        try? send(packet: packet)
    }

    public func sendDeviceInfo() {
        let info = HandshakePayload(
            deviceName: UIDevice.current.name,
            screenWidth: UInt16(UIScreen.main.bounds.width),
            screenHeight: UInt16(UIScreen.main.bounds.height),
            capabilities: ["mouse", "touch", "stream"]
        )
        guard let data = try? JSONEncoder().encode(info) else { return }
        let packet = Packet(type: .deviceInfo, payload: data)
        try? send(packet: packet)
    }

    private func startHeartbeat() {
        heartbeatTimer?.invalidate()
        lastHeartbeat = Date()
        heartbeatTimer = Timer.scheduledTimer(withTimeInterval: 5.0,
                                              repeats: true)
        { [weak self] _ in
            self?.sendHeartbeat()
        }
    }

    private func sendHeartbeat() {
        let packet = Packet(type: .heartbeat, payload: Data())
        try? send(packet: packet)
    }

    private func setConnected(method: ConnectionMethod,
                             transport: Transport) {
        guard activeTransport == nil else {
            transport.stop()
            return
        }
        activeTransport = transport
        state = .connected(method: method)
        startHeartbeat()
        sendDeviceInfo()

        for other in transports where other !== transport {
            other.stop()
        }
    }
}

extension ConnectionManager: TransportDelegate {
    public func transportDidConnect() {
        let method: ConnectionMethod
        if let transport = activeTransport {
            if transport is BluetoothTransport {
                method = .bluetooth
            } else {
                method = .wifi
            }
        } else {
            method = .wifi
        }

        for transport in transports {
            if transport.isConnected {
                setConnected(method: method, transport: transport)
                return
            }
        }
    }

    public func transportDidDisconnect(error: Error?) {
        if let error = error {
            state = .failed(error)
        } else {
            state = .disconnected
        }
        activeTransport = nil
        heartbeatTimer?.invalidate()
    }

    public func transportDidReceive(packet: Packet) {
        switch packet.type {
        case .heartbeat:
            let ack = Packet(type: .heartbeatAck, payload: Data())
            try? send(packet: ack)
        case .heartbeatAck:
            lastHeartbeat = Date()
        case .mouseMove:
            handleMouseMove(packet: packet)
        case .mouseDown:
            handleMouseDown(packet: packet)
        case .mouseUp:
            handleMouseUp(packet: packet)
        case .mouseScroll:
            handleMouseScroll(packet: packet)
        case .keyboardEvent:
            handleKeyboard(packet: packet)
        case .frameConfig:
            handleFrameConfig(packet: packet)
        case .disconnect:
            stop()
        default:
            delegate?.didReceivePacket(packet)
        }
    }

    private func handleMouseMove(packet: Packet) {
        guard let payload = try? JSONDecoder().decode(MouseMovePayload.self,
                                                      from: packet.payload)
        else { return }
        let point = EventProcessor.shared.processMouseMove(x: payload.x,
                                                          y: payload.y)
        CursorController.shared.moveCursor(to: point)
        if !CursorController.shared.isVisible {
            CursorController.shared.showCursor(at: point)
        }
    }

    private func handleMouseDown(packet: Packet) {
        guard let payload = try? JSONDecoder().decode(MouseClickPayload.self,
                                                      from: packet.payload)
        else { return }
        EventProcessor.shared.processMouseDown(x: payload.x,
                                              y: payload.y,
                                              button: payload.button)
    }

    private func handleMouseUp(packet: Packet) {
        TouchSimulator.shared.performTouchUp()
    }

    private func handleMouseScroll(packet: Packet) {
        guard let payload = try? JSONDecoder().decode(MouseScrollPayload.self,
                                                      from: packet.payload)
        else { return }
        EventProcessor.shared.processScroll(deltaX: payload.deltaX,
                                           deltaY: payload.deltaY)
    }

    private func handleKeyboard(packet: Packet) {
        guard let payload = try? JSONDecoder().decode(KeyboardPayload.self,
                                                      from: packet.payload)
        else { return }
        EventProcessor.shared.processKeyboard(keyCode: payload.keyCode,
                                             keyDown: payload.keyDown)
    }

    private func handleFrameConfig(packet: Packet) {
        guard let config = try? JSONDecoder().decode(FrameConfig.self,
                                                     from: packet.payload)
        else { return }
        StreamManager.shared.updateQuality(config.quality)
    }
}
