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
    private let processingQueue = DispatchQueue(label: "com.vitalscan.processingQueue", qos: .userInitiated)

    private var scanTimer: Timer?
    private let totalScanDuration: Double = 20.0 // Quét trong 20 giây
    private var scanStartTime: Date?
    private var isActivelyMeasuring = false
    private var consecutiveMissedFaceFrames = 0

    public init() {
        cameraManager.frameDelegate = self
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

    /// Người dùng nhấn nút BẮT ĐẦU QUÉT SINH TRẮC
    public func startScanning() {
        guard !isActivelyMeasuring else { return }
        signalProcessor.reset()
        consecutiveMissedFaceFrames = 0
        scanProgress = 0.0
        remainingSeconds = Int(totalScanDuration)
        scanStartTime = Date()
        isActivelyMeasuring = true
        scanState = .measuring(progress: 0.0, currentBPM: 0.0)

        cameraManager.start()

        scanTimer?.invalidate()
        scanTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.updateMeasurementProgress()
        }
    }

    public func cancelScanning() {
        scanTimer?.invalidate()
        scanTimer = nil
        isActivelyMeasuring = false
        consecutiveMissedFaceFrames = 0
        scanProgress = 0.0
        scanState = currentFaceROI?.isFaceWellCentered == true ? .faceAligned : .searchingFace
    }

    private func updateMeasurementProgress() {
        guard isActivelyMeasuring, let start = scanStartTime else { return }
        let elapsed = Date().timeIntervalSince(start)
        let progress = min(max(elapsed / totalScanDuration, 0.0), 1.0)
        self.scanProgress = progress
        self.remainingSeconds = max(0, Int(totalScanDuration - elapsed))

        // Chạy thuật toán rPPG ngầm trên processingQueue, không bao giờ chặn Main UI
        processingQueue.async { [weak self] in
            guard let self = self else { return }
            let wave = self.signalProcessor.getLatestFilteredWaveform(count: 60)
            let metrics = self.signalProcessor.computeVitalMetrics()

            DispatchQueue.main.async {
                guard self.isActivelyMeasuring else { return }
                if !wave.isEmpty {
                    self.liveWaveform = wave
                }
                if let currentMetrics = metrics {
                    self.instantBPM = currentMetrics.heartRateBPM
                }
                self.scanState = .measuring(progress: progress, currentBPM: self.instantBPM)

                if progress >= 1.0 {
                    self.finishMeasurement()
                }
            }
        }
    }

    private func finishMeasurement() {
        scanTimer?.invalidate()
        scanTimer = nil
        isActivelyMeasuring = false

        processingQueue.async { [weak self] in
            guard let self = self else { return }
            let finalMetrics = self.signalProcessor.computeVitalMetrics()

            DispatchQueue.main.async {
                if let metrics = finalMetrics {
                    self.latestResult = metrics
                    self.scanState = .completed(metrics)
                    self.showSummaryModal = true
                    self.saveScanRecord(metrics)
                } else {
                    self.scanState = .failed(reason: "Tín hiệu không đủ rõ ràng. Vui lòng giữ yên khuôn mặt và đảm bảo đủ ánh sáng.")
                }
            }
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

    // MARK: - CameraFrameDelegate (Chạy ngầm trên sampleQueue)
    nonisolated public func didCaptureFrame(pixelBuffer: CVPixelBuffer, timestamp: TimeInterval) {
        // Nhận diện khuôn mặt với autoreleasepool
        guard let roi = faceTracker.detectFaceROI(in: pixelBuffer) else {
            Task { @MainActor in
                if self.isActivelyMeasuring {
                    self.consecutiveMissedFaceFrames += 1
                    if self.consecutiveMissedFaceFrames > 45 {
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
            if !self.isActivelyMeasuring {
                self.scanState = roi.isFaceWellCentered ? .faceAligned : .searchingFace
            }
        }

        // Trích xuất màu RGB từ vùng ROI
        if let rgb = faceTracker.extractMeanRGB(from: pixelBuffer, roi: roi) {
            signalProcessor.appendRGB(red: rgb.r, green: rgb.g, blue: rgb.b, timestamp: timestamp)
        }
    }
}
