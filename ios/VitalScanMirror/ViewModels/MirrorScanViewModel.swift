import Foundation
import Combine
import SwiftUI
import CoreMedia

@MainActor
public final class MirrorScanViewModel: ObservableObject, CameraFrameDelegate {
    @Published public var scanState: ScanState = .idle
    @Published public var currentFaceROI: FaceROI?
    @Published public var liveWaveform: [Double] = [Double](repeating: 0.0, count: 60)
    @Published public var instantBPM: Double = 0.0
    @Published public var scanProgress: Double = 0.0
    @Published public var remainingSeconds: Int = 20
    @Published public var latestResult: VitalMetrics?
    @Published public var showSummaryModal: Bool = false
    @Published public var showDisclaimerConsent: Bool = false

    public let cameraManager = CameraManager()
    private let faceTracker = FaceTracker()
    private let signalProcessor = SignalProcessor()

    private var scanTimer: Timer?
    private let totalScanDuration: Double = 20.0 // Quét trong 20 giây
    private var scanStartTime: Date?
    private var isActivelyMeasuring = false
    private var consecutiveMissedFaceFrames = 0

    public init() {
        cameraManager.frameDelegate = self
        // Kiểm tra xem người dùng đã đồng ý với disclaimer y tế chưa
        let hasAgreed = UserDefaults.standard.bool(forKey: "vitalscan_disclaimer_agreed")
        if !hasAgreed {
            self.showDisclaimerConsent = true
        }
    }

    public func acceptDisclaimer() {
        UserDefaults.standard.set(true, forKey: "vitalscan_disclaimer_agreed")
        showDisclaimerConsent = false
        cameraManager.start()
        scanState = .searchingFace
    }

    public func startScanning() {
        signalProcessor.reset()
        consecutiveMissedFaceFrames = 0
        scanProgress = 0.0
        remainingSeconds = Int(totalScanDuration)
        scanState = .searchingFace
        cameraManager.start()
        cameraManager.lockCameraParameters(false)
    }

    public func cancelScanning() {
        scanTimer?.invalidate()
        scanTimer = nil
        isActivelyMeasuring = false
        consecutiveMissedFaceFrames = 0
        cameraManager.lockCameraParameters(false)
        scanState = .idle
    }

    private func beginMeasurement() {
        guard !isActivelyMeasuring else { return }
        isActivelyMeasuring = true
        scanStartTime = Date()
        cameraManager.lockCameraParameters(true) // Khóa phơi sáng và cân bằng trắng

        scanTimer?.invalidate()
        scanTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                self.updateMeasurementProgress()
            }
        }
    }

    private func updateMeasurementProgress() {
        guard let start = scanStartTime else { return }
        let elapsed = Date().timeIntervalSince(start)
        let progress = min(elapsed / totalScanDuration, 1.0)
        self.scanProgress = progress
        self.remainingSeconds = max(0, Int(totalScanDuration - elapsed))

        // Cập nhật biểu đồ sóng thời gian thực
        self.liveWaveform = self.signalProcessor.getLatestFilteredWaveform(count: 60)

        // Tính thử nghiệm nhịp tim tạm thời
        if let currentMetrics = self.signalProcessor.computeVitalMetrics() {
            self.instantBPM = currentMetrics.heartRateBPM
            self.scanState = .measuring(progress: progress, currentBPM: self.instantBPM)
        }

        if progress >= 1.0 {
            finishMeasurement()
        }
    }

    private func finishMeasurement() {
        scanTimer?.invalidate()
        scanTimer = nil
        isActivelyMeasuring = false
        cameraManager.lockCameraParameters(false)

        if let finalMetrics = signalProcessor.computeVitalMetrics() {
            self.latestResult = finalMetrics
            self.scanState = .completed(finalMetrics)
            self.showSummaryModal = true
            // Lưu vào lịch sử
            saveScanRecord(finalMetrics)
        } else {
            self.scanState = .failed(reason: "Tín hiệu không đủ rõ ràng. Vui lòng giữ yên khuôn mặt và đảm bảo đủ ánh sáng.")
        }
    }

    private func saveScanRecord(_ metrics: VitalMetrics) {
        let historyItem = ScanHistoryItem(
            heartRate: metrics.heartRateBPM,
            hrv: metrics.hrvRMSSD,
            respirationRate: metrics.respirationRateBPM,
            stressIndex: metrics.stressIndex,
            skinVitality: metrics.skinVitalityScore,
            skinAge: metrics.estimatedSkinAge
        )
        var list = loadHistory()
        list.insert(historyItem, at: 0)
        if let data = try? JSONEncoder().encode(list) {
            UserDefaults.standard.set(data, forKey: "vitalscan_history_records")
        }
    }

    public func loadHistory() -> [ScanHistoryItem] {
        guard let data = UserDefaults.standard.data(forKey: "vitalscan_history_records"),
              let list = try? JSONDecoder().decode([ScanHistoryItem].self, from: data) else {
            return []
        }
        return list
    }

    // MARK: - CameraFrameDelegate
    nonisolated public func didCaptureFrame(pixelBuffer: CVPixelBuffer, timestamp: TimeInterval) {
        // Nhận diện khuôn mặt
        guard let roi = faceTracker.detectFaceROI(in: pixelBuffer) else {
            Task { @MainActor in
                if self.isActivelyMeasuring {
                    self.consecutiveMissedFaceFrames += 1
                    // Chỉ hủy và báo lỗi nếu mất dấu liên tục trên 30 frames (~1 giây)
                    if self.consecutiveMissedFaceFrames > 30 {
                        self.scanState = .failed(reason: "Mất dấu khuôn mặt. Vui lòng nhìn thẳng vào gương.")
                        self.cancelScanning()
                    }
                } else {
                    self.scanState = .searchingFace
                    self.currentFaceROI = nil
                }
            }
            return
        }

        Task { @MainActor in
            self.consecutiveMissedFaceFrames = 0
            self.currentFaceROI = roi
            if !self.isActivelyMeasuring && roi.isFaceWellCentered {
                self.scanState = .faceAligned
                self.beginMeasurement()
            }
        }

        // Trích xuất màu RGB từ vùng ROI
        if let rgb = faceTracker.extractMeanRGB(from: pixelBuffer, roi: roi) {
            signalProcessor.appendRGB(red: rgb.r, green: rgb.g, blue: rgb.b, timestamp: timestamp)
        }
    }
}
