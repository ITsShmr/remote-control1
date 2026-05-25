import ReplayKit
import Network
import CoreMedia
import CoreImage
import UIKit

class SampleHandler: RPBroadcastSampleHandler {
    private var connection: NWConnection?
    private let queue = DispatchQueue(label: "com.remotecontrol.broadcast", qos: .userInitiated)
    private let kProtocolMagic: UInt32 = 0x524D544C

    override func broadcastStarted(withSetupInfo setupInfo: [String: NSObject]?) {
        let host = NWEndpoint.Host("127.0.0.1")
        guard let port = NWEndpoint.Port(rawValue: 5289) else { return }
        connection = NWConnection(host: host, port: port, using: .tcp)
        connection?.start(queue: queue)
    }

    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with type: RPSampleBufferType) {
        guard type == .video, let connection = connection, connection.state == .ready else { return }
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }
        let image = UIImage(cgImage: cgImage)
        guard let jpegData = image.jpegData(compressionQuality: 0.6) else { return }
        var packet = Data()
        withUnsafeBytes(of: kProtocolMagic.bigEndian) { packet.append(contentsOf: $0) }
        let len = UInt32(jpegData.count).bigEndian
        withUnsafeBytes(of: len) { packet.append(contentsOf: $0) }
        let typeVal = UInt32(0x0101).bigEndian
        withUnsafeBytes(of: typeVal) { packet.append(contentsOf: $0) }
        packet.append(jpegData)
        connection.send(content: packet, completion: .contentProcessed { _ in })
    }

    override func broadcastFinished() {
        connection?.cancel()
        connection = nil
    }
}
