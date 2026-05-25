import Foundation
import ReplayKit
import CoreGraphics
import VideoToolbox
import UIKit

public protocol ScreenCaptureDelegate: AnyObject {
    func captureServiceDidCapture(jpegData: Data, presentationTime: CMTime)
    func captureServiceDidFail(error: Error)
}

public final class ScreenCaptureService: NSObject {
    public weak var delegate: ScreenCaptureDelegate?

    public private(set) var isCapturing = false
    public var quality: ConnectionQuality = .high {
        didSet { updateCompressionParams() }
    }
    public var maxFps: UInt8 = 30

    private let recorder = RPScreenRecorder.shared()
    private let queue = DispatchQueue(label: "com.remotecontrol.capture",
                                      qos: .userInteractive)
    private let ciContext = CIContext(options: [
        .workingColorSpace: NSNull(),
        .highQualityDownsample: true
    ])
    private var compressionQueue: [Data] = []

    private var scaleFactor: CGFloat = 1.0
    private var jpegCompressionQuality: CGFloat = 0.8
    private var lastFrameTime = CMTime.zero
    private let minFrameInterval: CMTime

    override init() {
        minFrameInterval = CMTime(value: 1, timescale: 30)
        super.init()
        updateCompressionParams()
    }

    public func startCapture() {
        guard !isCapturing, recorder.isAvailable else { return }
        isCapturing = true
        recorder.isMicrophoneEnabled = false
        recorder.startCapture { [weak self] sampleBuffer, type, error in
            guard let self = self else { return }
            if let error = error {
                self.delegate?.captureServiceDidFail(error: error)
                return
            }
            guard type == .video else { return }
            self.processSampleBuffer(sampleBuffer)
        } completionHandler: { [weak self] error in
            if let error = error {
                self?.isCapturing = false
                self?.delegate?.captureServiceDidFail(error: error)
            }
        }
    }

    public func stopCapture() {
        guard isCapturing else { return }
        recorder.stopCapture { [weak self] error in
            self?.isCapturing = false
            if let error = error {
                self?.delegate?.captureServiceDidFail(error: error)
            }
        }
    }

    private func processSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)

        let timeDiff = CMTimeSubtract(presentationTime, lastFrameTime)
        if CMTimeCompare(timeDiff, minFrameInterval) < 0 { return }
        lastFrameTime = presentationTime

        autoreleasepool {
            guard let jpeg = compressToJPEG(pixelBuffer: pixelBuffer) else { return }
            delegate?.captureServiceDidCapture(jpegData: jpeg,
                                              presentationTime: presentationTime)
        }
    }

    private func compressToJPEG(pixelBuffer: CVPixelBuffer) -> Data? {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let width = CGFloat(CVPixelBufferGetWidth(pixelBuffer))
        let height = CGFloat(CVPixelBufferGetHeight(pixelBuffer))

        let scaledWidth = width * scaleFactor
        let scaledHeight = height * scaleFactor

        guard let cgImage = ciContext.createCGImage(ciImage,
                                                    from: CGRect(x: 0, y: 0,
                                                                width: width,
                                                                height: height),
                                                    format: .RGBA8,
                                                    colorSpace: nil) else { return nil }

        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: nil,
                                     width: Int(scaledWidth),
                                     height: Int(scaledHeight),
                                     bitsPerComponent: 8,
                                     bytesPerRow: Int(scaledWidth) * 4,
                                     space: colorSpace,
                                     bitmapInfo: bitmapInfo.rawValue) else { return nil }
        context.interpolationQuality = .high
        context.draw(cgImage, in: CGRect(x: 0, y: 0,
                                        width: scaledWidth,
                                        height: scaledHeight))
        guard let scaledCG = context.makeImage() else { return nil }

        let mutableData = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(mutableData as CFMutableData,
                                                                  "public.jpeg" as CFString,
                                                                  1, nil) else { return nil }
        let options: [CFString: Any] = [
            kCGImageDestinationLossyCompressionQuality: jpegCompressionQuality
        ]
        CGImageDestinationAddImage(destination, scaledCG, options as CFDictionary)
        CGImageDestinationFinalize(destination)
        return mutableData as Data
    }

    private func updateCompressionParams() {
        switch quality {
        case .low:
            scaleFactor = 0.25
            jpegCompressionQuality = 0.4
            minFrameInterval = CMTime(value: 1, timescale: 15)
        case .medium:
            scaleFactor = 0.4
            jpegCompressionQuality = 0.6
            minFrameInterval = CMTime(value: 1, timescale: 20)
        case .high:
            scaleFactor = 0.6
            jpegCompressionQuality = 0.8
            minFrameInterval = CMTime(value: 1, timescale: 30)
        case .ultra:
            scaleFactor = 0.8
            jpegCompressionQuality = 0.9
            minFrameInterval = CMTime(value: 1, timescale: 60)
        }
    }
}
