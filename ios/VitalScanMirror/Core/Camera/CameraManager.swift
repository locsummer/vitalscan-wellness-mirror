import Foundation
import AVFoundation
import CoreVideo
import Combine

public protocol CameraFrameDelegate: AnyObject {
    func didCaptureFrame(pixelBuffer: CVPixelBuffer, timestamp: TimeInterval)
}

/// Trình quản lý camera trước độ phân giải cao và an toàn tuyệt đối
public final class CameraManager: NSObject, ObservableObject, @unchecked Sendable {
    @Published public var isRunning: Bool = false
    @Published public var isAuthorized: Bool = false

    public let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "com.vitalscan.cameraQueue")
    private let sampleQueue = DispatchQueue(label: "com.vitalscan.sampleBufferQueue")
    private var videoOutput = AVCaptureVideoDataOutput()

    public weak var frameDelegate: CameraFrameDelegate?

    public override init() {
        super.init()
        checkPermissions()
    }

    public func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.isAuthorized = true
            setupSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.isAuthorized = granted
                    if granted {
                        self?.setupSession()
                    }
                }
            }
        default:
            self.isAuthorized = false
        }
    }

    private func setupSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }

            self.session.beginConfiguration()
            self.session.sessionPreset = .hd1280x720

            // Camera trước
            if let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
               let input = try? AVCaptureDeviceInput(device: camera) {
                if self.session.canAddInput(input) {
                    self.session.addInput(input)
                }
            }

            self.videoOutput.alwaysDiscardsLateVideoFrames = true
            self.videoOutput.setSampleBufferDelegate(self, queue: self.sampleQueue)

            if self.session.canAddOutput(self.videoOutput) {
                self.session.addOutput(self.videoOutput)
            }

            self.session.commitConfiguration()
        }
    }

    public func start() {
        sessionQueue.async { [weak self] in
            guard let self = self, !self.session.isRunning else { return }
            self.session.startRunning()
            DispatchQueue.main.async {
                self.isRunning = true
            }
        }
    }

    public func stop() {
        sessionQueue.async { [weak self] in
            guard let self = self, self.session.isRunning else { return }
            self.session.stopRunning()
            DispatchQueue.main.async {
                self.isRunning = false
            }
        }
    }

    public func lockCameraParameters(_ lock: Bool) {}
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer).seconds
        frameDelegate?.didCaptureFrame(pixelBuffer: pixelBuffer, timestamp: timestamp)
    }
}
