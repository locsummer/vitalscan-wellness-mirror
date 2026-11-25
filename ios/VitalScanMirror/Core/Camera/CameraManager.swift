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
    private var isSessionConfigured = false

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
            self.configureSessionInternal()
        }
    }

    private func configureSessionInternal() {
        guard !isSessionConfigured else { return }

        session.beginConfiguration()
        session.sessionPreset = .hd1280x720

        // Camera trước
        if let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
           let input = try? AVCaptureDeviceInput(device: camera) {
            if session.canAddInput(input) {
                session.addInput(input)
            }
        }

        videoOutput.alwaysDiscardsLateVideoFrames = true
        // Ép định dạng 32BGRA để bảo đảm tương thích và an toàn bộ nhớ tuyệt đối trên mọi thế hệ iPhone
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)
        ]
        videoOutput.setSampleBufferDelegate(self, queue: sampleQueue)

        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }

        if let connection = videoOutput.connection(with: .video) {
            if connection.isVideoOrientationSupported {
                connection.videoOrientation = .portrait
            }
            if connection.isVideoMirroringSupported {
                connection.isVideoMirrored = true
            }
        }

        session.commitConfiguration()
        isSessionConfigured = true
    }

    public func start() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if !self.isSessionConfigured {
                self.configureSessionInternal()
            }
            guard !self.session.isRunning else { return }
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
