import Foundation
import UIKit
import CoreMedia

public final class StreamManager: NSObject {
    public static let shared = StreamManager()
    public var isStreaming = false

    private let captureService = ScreenCaptureService()
    private let frameQueue = DispatchQueue(label: "com.remotecontrol.stream",
                                           qos: .userInitiated)
    private var frameCount: UInt64 = 0
    private var lastQualityLog = Date()

    override init() {
        super.init()
        captureService.delegate = self
    }

    public func startStreaming() {
        guard !isStreaming else { return }
        isStreaming = true
        captureService.startCapture()
    }

    public func stopStreaming() {
        guard isStreaming else { return }
        isStreaming = false
        captureService.stopCapture()
    }

    public func updateQuality(_ quality: ConnectionQuality) {
        captureService.quality = quality
    }

    public func setMaxFps(_ fps: UInt8) {
        captureService.maxFps = fps
    }
}

extension StreamManager: ScreenCaptureDelegate {
    public func captureServiceDidCapture(jpegData: Data,
                                        presentationTime: CMTime) {
        guard ConnectionManager.shared.state.isConnected else { return }

        frameCount += 1
        ConnectionManager.shared.sendFrame(data: jpegData)

        if Date().timeIntervalSince(lastQualityLog) >= 5.0 {
            let fps = Double(frameCount) / 5.0
            let kbPerFrame = Double(jpegData.count) / 1024.0
            let mbps = kbPerFrame * fps / 1024.0
            print("[Stream] \(Int(fps)) fps | \(Int(kbPerFrame)) KB/frame | \(String(format: "%.1f", mbps)) Mbps")
            frameCount = 0
            lastQualityLog = Date()
        }
    }

    public func captureServiceDidFail(error: Error) {
        print("[Stream] Capture failed: \(error.localizedDescription)")
        isStreaming = false
    }
}

extension ConnectionState {
    var isConnected: Bool {
        if case .connected = self { return true }
        return false
    }

    var connectionMethod: ConnectionMethod? {
        if case .connected(let method) = self { return method }
        return nil
    }
}
