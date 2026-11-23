import Foundation
import AVFoundation
import CoreVideo
import Combine

public protocol CameraFrameDelegate: AnyObject {
    func didCaptureFrame(pixelBuffer: CVPixelBuffer, timestamp: TimeInterval)
}

/// Trình quản lý camera trước độ phân giải cao và cố định 30 FPS cho đo lường rPPG
public final class CameraManager: NSObject, ObservableObject {
    @Published public var isRunning: Bool = false
    @Published public var isAuthorized: Bool = false
    @Published public var permissionDenied: Bool = false

    public let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "com.vitalscan.cameraQueue")
    private var frontCamera: AVCaptureDevice?
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
                    self?.permissionDenied = !granted
                    if granted {
                        self?.setupSession()
                    }
                }
            }
        default:
            self.isAuthorized = false
            self.permissionDenied = true
        }
    }

    private func setupSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }

            self.session.beginConfiguration()
            self.session.sessionPreset = .hd1280x720 // 720p tối ưu cho Face Tracking & rPPG

            // Tìm camera trước
            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
                self.session.commitConfiguration()
                return
            }
            self.frontCamera = camera

            do {
                let input = try AVCaptureDeviceInput(device: camera)
                if self.session.canAddInput(input) {
                    self.session.addInput(input)
                }

                // Cấu hình Output video sample buffer 32BGRA
                self.videoOutput.alwaysDiscardsLateVideoFrames = true
                self.videoOutput.videoSettings = [
                    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
                ]
                self.videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "com.vitalscan.sampleBufferQueue"))

                if self.session.canAddOutput(self.videoOutput) {
                    self.session.addOutput(self.videoOutput)
                    if let connection = self.videoOutput.connection(with: .video) {
                        if connection.isVideoOrientationSupported {
                            connection.videoOrientation = .portrait
                        }
                        if connection.isVideoMirroringSupported {
                            connection.automaticallyAdjustsVideoMirroring = false
                            connection.isVideoMirrored = true
                        }
                    }
                }

                // Cố định tốc độ khung hình 30 FPS an toàn
                do {
                    try camera.lockForConfiguration()
                    let targetFrameRate = 30.0
                    let supported = camera.activeFormat.videoSupportedFrameRateRanges.contains { range in
                        range.minFrameRate <= targetFrameRate && targetFrameRate <= range.maxFrameRate
                    }
                    if supported {
                        camera.activeVideoMinFrameDuration = CMTime(value: 1, timescale: Int32(targetFrameRate))
                        camera.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: Int32(targetFrameRate))
                    }
                    camera.unlockForConfiguration()
                } catch {
                    print("Không thể cấu hình frame rate camera: \(error.localizedDescription)")
                }

            } catch {
                print("Lỗi cấu hình Camera: \(error.localizedDescription)")
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

    /// Khóa Auto-Exposure và Auto-White Balance khi bắt đầu đo để tránh hiện tượng nhấp nháy cảm biến
    public func lockCameraParameters(_ lock: Bool) {
        sessionQueue.async { [weak self] in
            guard let camera = self?.frontCamera else { return }
            do {
                try camera.lockForConfiguration()
                if lock {
                    if camera.isExposureModeSupported(.locked) {
                        camera.exposureMode = .locked
                    }
                    if camera.isWhiteBalanceModeSupported(.locked) {
                        camera.whiteBalanceMode = .locked
                    }
                } else {
                    if camera.isExposureModeSupported(.continuousAutoExposure) {
                        camera.exposureMode = .continuousAutoExposure
                    }
                    if camera.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
                        camera.whiteBalanceMode = .continuousAutoWhiteBalance
                    }
                }
                camera.unlockForConfiguration()
            } catch {
                print("Không thể khóa thông số camera: \(error.localizedDescription)")
            }
        }
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer).seconds
        frameDelegate?.didCaptureFrame(pixelBuffer: pixelBuffer, timestamp: timestamp)
    }
}
