import Foundation
import Network
import UIKit
import Darwin

enum AppState: String, Sendable {
    case idle
    case listening
    case connected
    case failed
}

final class ServerManager: ObservableObject {
    static let shared = ServerManager()

    @Published var state: AppState = .idle
    @Published var errorMessage: String = ""
    @Published var localIP: String = ""

    private var listener: NWListener?
    private var connection: NWConnection?
    private var readBuffer = Data()
    private let queue = DispatchQueue(label: "com.remotecontrol.server", qos: .userInitiated)
    private let port: UInt16 = 5288
    private let capture = CaptureService()

    private init() {
        capture.delegate = self
    }

    func start() {
        guard listener == nil else { return }
        let params = NWParameters.tcp
        guard let port = NWEndpoint.Port(rawValue: port) else { return }
        do {
            listener = try NWListener(using: params, on: port)
            listener?.newConnectionHandler = { [weak self] conn in
                self?.accept(conn)
            }
            listener?.stateUpdateHandler = { [weak self] state in
                if case .failed(let err) = state {
                    self?.setFailed("Listener failed: \(err.debugDescription)")
                }
            }
            listener?.start(queue: queue)
            localIP = Self.getWiFiAddress()
            setState(.listening)
        } catch {
            setFailed("Failed to start: \(error.localizedDescription)")
        }
    }

    private static func getWiFiAddress() -> String {
        var addr: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0, let ifaddr else { return "Unknown" }
        var ptr: UnsafeMutablePointer<ifaddrs>? = ifaddr
        while let p = ptr {
            let family = p.pointee.ifa_addr.pointee.sa_family
            if family == UInt8(AF_INET) {
                let name = String(cString: p.pointee.ifa_name)
                if name.hasPrefix("en") {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(p.pointee.ifa_addr, socklen_t(p.pointee.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST)
                    let ip = String(cString: hostname)
                    if !ip.hasPrefix("169.254.") {
                        addr = ip
                    }
                }
            }
            ptr = p.pointee.ifa_next
        }
        freeifaddrs(ifaddr)
        return addr ?? "Unknown"
    }

    func stop() {
        connection?.cancel()
        connection = nil
        listener?.cancel()
        listener = nil
        capture.stop()
        readBuffer.removeAll()
        setState(.idle)
        setError("")
    }

    private func accept(_ conn: NWConnection) {
        connection?.cancel()
        connection = conn
        conn.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                self?.setState(.connected)
                self?.sendDeviceInfo()
                self?.capture.start()
            case .failed, .cancelled:
                self?.setState(.idle)
                self?.capture.stop()
            default:
                break
            }
        }
        conn.start(queue: queue)
        receive()
    }

    private func sendDeviceInfo() {
        let screen = UIScreen.main
        let msg = DeviceInfoMessage(
            deviceName: UIDevice.current.name,
            screenWidth: screen.bounds.width * screen.scale,
            screenHeight: screen.bounds.height * screen.scale
        )
        guard let payload = try? JSONEncoder().encode(msg) else { return }
        send(Packet(type: .deviceInfo, payload: payload))
    }

    private func receive() {
        connection?.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
            guard let self = self else { return }
            if let data = data, !data.isEmpty {
                self.readBuffer.append(data)
                self.processPackets()
            }
            if isComplete || error != nil {
                Task { @MainActor in self.stop() }
            } else {
                self.receive()
            }
        }
    }

    private func processPackets() {
        while let (packet, remaining) = Packet.parse(from: readBuffer) {
            readBuffer = remaining
            handle(packet)
        }
    }

    private func handle(_ packet: Packet) {
        switch packet.type {
        case .handshake:
            sendHandshake()
        case .mouseMove:
            if let msg = try? JSONDecoder().decode(MouseMoveMessage.self, from: packet.payload) {
                InputSimulator.shared.handleMouseMove(x: msg.x, y: msg.y)
            }
        case .mouseDown:
            if let msg = try? JSONDecoder().decode(MouseClickMessage.self, from: packet.payload) {
                InputSimulator.shared.handleMouseDown(x: msg.x, y: msg.y, button: msg.button)
            }
        case .mouseUp:
            InputSimulator.shared.handleMouseUp()
        case .mouseScroll:
            break
        case .disconnect:
            Task { @MainActor in self.stop() }
        default:
            break
        }
    }

    private func sendHandshake() {
        let msg = HandshakeMessage(deviceName: UIDevice.current.name, version: "1.0")
        guard let payload = try? JSONEncoder().encode(msg) else { return }
        send(Packet(type: .handshake, payload: payload))
    }

    func sendFrame(jpegData: Data) {
        send(Packet(type: .frameData, payload: jpegData))
    }

    private func send(_ packet: Packet) {
        connection?.send(content: packet.serialize(), completion: .contentProcessed { _ in })
    }

    private func setState(_ s: AppState) {
        Task { @MainActor in state = s }
    }

    private func setError(_ msg: String) {
        Task { @MainActor in errorMessage = msg }
    }

    private func setFailed(_ msg: String) {
        Task { @MainActor in
            errorMessage = msg
            state = .failed
        }
    }

}

extension ServerManager: CaptureServiceDelegate {
    func captureServiceDidCapture(jpegData: Data) {
        sendFrame(jpegData: jpegData)
    }

    func captureServiceDidFail(_ error: Error) {
        setFailed(error.localizedDescription)
    }
}
