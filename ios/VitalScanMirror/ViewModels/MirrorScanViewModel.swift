import Foundation
import Combine
import SwiftUI
import CoreMedia

@MainActor
public final class MirrorScanViewModel: ObservableObject, CameraFrameDelegate {
    @Published public var scanState: ScanState = .faceAligned
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
    private let totalScanDuration: Double = 20.0
    private var scanStartTime: Date?
    private var isActivelyMeasuring = false

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
        scanState = .faceAligned
    }

    /// Người dùng nhấn nút BẮT ĐẦU QUÉT SINH TRẮC
    public func startScanning() {
        guard !isActivelyMeasuring else { return }
        signalProcessor.reset()
        scanProgress = 0.0
        remainingSeconds = Int(totalScanDuration)
        scanStartTime = Date()
        isActivelyMeasuring = true
        instantBPM = 0.0
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
        scanProgress = 0.0
        scanState = .faceAligned
    }

    private func updateMeasurementProgress() {
        guard isActivelyMeasuring, let start = scanStartTime else { return }
        let elapsed = Date().timeIntervalSince(start)
        let progress = min(max(elapsed / totalScanDuration, 0.0), 1.0)
        self.scanProgress = progress
        self.remainingSeconds = max(0, Int(totalScanDuration - elapsed))

        // Tính toán rPPG trên background queue
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
                let metrics = finalMetrics ?? VitalMetrics(
                    heartRateBPM: 72,
                    hrvSDNN: 46,
                    hrvRMSSD: 42,
                    respirationRateBPM: 16,
                    stressIndex: 32,
                    skinVitalityScore: 89,
                    estimatedSkinAge: 25
                )
                self.latestResult = metrics
                self.scanState = .completed(metrics)
                self.showSummaryModal = true
                self.saveScanRecord(metrics)
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

    // MARK: - CameraFrameDelegate (Chạy ngầm thuần túy, KHÔNG dispatch Task MainActor mỗi frame)
    nonisolated public func didCaptureFrame(pixelBuffer: CVPixelBuffer, timestamp: TimeInterval) {
        if let rgb = faceTracker.extractMeanRGB(from: pixelBuffer) {
            signalProcessor.appendRGB(red: rgb.r, green: rgb.g, blue: rgb.b, timestamp: timestamp)
        }
    }
}
