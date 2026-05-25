import Foundation
import Network
import UIKit

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

    private var listener: NWListener?
    private var connection: NWConnection?
    private var readBuffer = Data()
    private let queue = DispatchQueue(label: "com.remotecontrol.server", qos: .userInitiated)
    private let serviceType = "_remoteios._tcp"
    private let port: UInt16 = 5288
    private let capture = CaptureService()

    private init() {
        capture.delegate = self
    }

    func start() {
        guard listener == nil else { return }
        let params = NWParameters.tcp
        params.includePeerToPeer = true
        guard let port = NWEndpoint.Port(rawValue: port) else { return }
        do {
            listener = try NWListener(using: params, on: port)
            listener?.service = NWListener.Service(type: serviceType, txtRecord: txtData())
            listener?.newConnectionHandler = { [weak self] conn in
                self?.accept(conn)
            }
            listener?.stateUpdateHandler = { [weak self] state in
                if case .failed = state {
                    self?.setFailed("Listener failed")
                }
            }
            listener?.start(queue: queue)
            setState(.listening)
        } catch {
            setFailed("Failed to start server")
        }
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

    private func txtData() -> Data {
        var data = Data()
        for pair in ["version=1", "device=\(UIDevice.current.name)", "model=\(UIDevice.current.model)"] {
            let bytes = [UInt8](pair.utf8)
            data.append(UInt8(bytes.count))
            data.append(contentsOf: bytes)
        }
        return data
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
