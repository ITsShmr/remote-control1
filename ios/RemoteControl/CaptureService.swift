import Foundation
import ReplayKit
import CoreMedia
import CoreImage
import UIKit

protocol CaptureServiceDelegate: AnyObject {
    func captureServiceDidCapture(jpegData: Data)
    func captureServiceDidFail(_ error: Error)
}

final class CaptureService: NSObject {
    weak var delegate: CaptureServiceDelegate?
    private let recorder = RPScreenRecorder.shared()
    private var isActive = false

    func start() {
        guard !isActive, recorder.isAvailable else { return }
        isActive = true
        recorder.isMicrophoneEnabled = false
        recorder.startCapture { [weak self] buffer, type, error in
            guard let self = self else { return }
            if let error = error {
                self.delegate?.captureServiceDidFail(error)
                return
            }
            guard type == .video else { return }
            self.processBuffer(buffer)
        } completionHandler: { [weak self] error in
            if let error = error {
                self?.delegate?.captureServiceDidFail(error)
            }
        }
    }

    func stop() {
        guard isActive else { return }
        recorder.stopCapture { _ in }
        isActive = false
    }

    private func processBuffer(_ buffer: CMSampleBuffer) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) else { return }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }
        let image = UIImage(cgImage: cgImage)
        guard let jpegData = image.jpegData(compressionQuality: 0.6) else { return }
        delegate?.captureServiceDidCapture(jpegData: jpegData)
    }
}
