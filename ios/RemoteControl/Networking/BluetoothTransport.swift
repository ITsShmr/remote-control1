import Foundation
import MultipeerConnectivity

public final class BluetoothTransport: NSObject, Transport {
    public weak var delegate: TransportDelegate?
    public private(set) var isConnected = false

    private let serviceType = "remote-ctrl"
    private let peerID: MCPeerID
    private var session: MCSession?
    private var advertiser: MCNearbyServiceAdvertiser?
    private let queue = DispatchQueue(label: "com.remotecontrol.bt",
                                      qos: .userInitiated)
    private var readBuffer = Data()

    public override init() {
        self.peerID = MCPeerID(displayName: "iPhone-\(UIDevice.current.name)")
        super.init()
    }

    public func start() {
        guard session == nil else { return }
        let session = MCSession(peer: peerID,
                               securityIdentity: nil,
                               encryptionPreference: .none)
        session.delegate = self
        self.session = session

        advertiser = MCNearbyServiceAdvertiser(peer: peerID,
                                              discoveryInfo: nil,
                                              serviceType: serviceType)
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
    }

    public func stop() {
        advertiser?.stopAdvertisingPeer()
        advertiser = nil
        session?.disconnect()
        session = nil
        isConnected = false
    }

    public func send(packet: Packet) throws {
        guard let session = session, isConnected else {
            throw TransportError.notConnected
        }
        let data = packet.serialize()
        try session.send(data, toPeers: session.connectedPeers,
                        with: .reliable)
    }

    private func processReceived(_ data: Data) {
        readBuffer.append(data)
        while let (packet, remaining) = Packet.parse(from: readBuffer) {
            readBuffer = remaining
            delegate?.transportDidReceive(packet: packet)
        }
    }
}

extension BluetoothTransport: MCSessionDelegate {
    public func session(_ session: MCSession,
                       peer peerID: MCPeerID,
                       didChange state: MCSessionState) {
        switch state {
        case .connected:
            isConnected = true
            delegate?.transportDidConnect()
        case .notConnected:
            isConnected = false
            delegate?.transportDidDisconnect(error: nil)
        case .connecting:
            break
        @unknown default:
            break
        }
    }

    public func session(_ session: MCSession,
                       didReceive data: Data,
                       fromPeer peerID: MCPeerID) {
        processReceived(data)
    }

    public func session(_ session: MCSession,
                       didReceive stream: InputStream,
                       withName streamName: String,
                       fromPeer peerID: MCPeerID) {}

    public func session(_ session: MCSession,
                       didStartReceivingResourceWithName resourceName: String,
                       fromPeer peerID: MCPeerID,
                       with progress: Progress) {}

    public func session(_ session: MCSession,
                       didFinishReceivingResourceWithName resourceName: String,
                       fromPeer peerID: MCPeerID,
                       at localURL: URL?,
                       withError error: Error?) {}
}

extension BluetoothTransport: MCNearbyServiceAdvertiserDelegate {
    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                          didReceiveInvitationFromPeer peerID: MCPeerID,
                          withContext context: Data?,
                          invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
}
