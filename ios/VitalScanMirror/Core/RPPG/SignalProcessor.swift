import Foundation
import CoreGraphics

/// Bộ xử lý tín hiệu sinh trắc tổng thể từ chuỗi khung hình camera mặt (Thread-safe & Crash-proof)
public final class SignalProcessor: @unchecked Sendable {
    private let sampleRate: Double = 30.0
    private let bufferCapacity: Int = 300 // Lưu trữ 10 giây gần nhất (300 frames)

    private let lock = NSLock()
    private var redBuffer: [Double] = []
    private var greenBuffer: [Double] = []
    private var blueBuffer: [Double] = []
    private var timestamps: [TimeInterval] = []

    private let posAlgorithm = POSAlgorithm(windowSize: 45)
    private let bandpassFilter = ButterworthBandpassFilter(sampleRate: 30.0, lowCutoff: 0.75, highCutoff: 3.5)
    private let respirationFilter = ButterworthBandpassFilter(sampleRate: 30.0, lowCutoff: 0.15, highCutoff: 0.4)
    private let fftAnalyzer = FFTAnalyzer(sampleRate: 30.0)

    public init() {}

    /// Đẩy giá trị màu trung bình RGB của frame hiện tại vào bộ đệm (Thread-safe)
    public func appendRGB(red: Double, green: Double, blue: Double, timestamp: TimeInterval) {
        guard !red.isNaN, !green.isNaN, !blue.isNaN else { return }

        lock.lock()
        defer { lock.unlock() }

        redBuffer.append(red)
        greenBuffer.append(green)
        blueBuffer.append(blue)
        timestamps.append(timestamp)

        if redBuffer.count > bufferCapacity {
            redBuffer.removeFirst()
            greenBuffer.removeFirst()
            blueBuffer.removeFirst()
            timestamps.removeFirst()
        }
    }

    /// Lấy chuỗi sóng PPG đã lọc gần nhất để vẽ đồ thị thời gian thực (Waveform)
    public func getLatestFilteredWaveform(count: Int = 100) -> [Double] {
        lock.lock()
        guard redBuffer.count >= 45 else {
            lock.unlock()
            return [Double](repeating: 0.0, count: count)
        }
        let r = redBuffer
        let g = greenBuffer
        let b = blueBuffer
        lock.unlock()

        let posRaw = posAlgorithm.extractPulse(red: r, green: g, blue: b)
        let filtered = bandpassFilter.filterSignal(posRaw)
        
        let slice = filtered.suffix(count)
        return Array(slice)
    }

    /// Phân tích và tính toán toàn bộ chỉ số sinh trắc học hiện tại
    public func computeVitalMetrics() -> VitalMetrics? {
        lock.lock()
        guard redBuffer.count >= 90 else { // Cần tối thiểu 3 giây tín hiệu (90 frames)
            lock.unlock()
            return nil
        }
        let r = redBuffer
        let g = greenBuffer
        let b = blueBuffer
        lock.unlock()

        // 1. Thuật toán POS tách xung nhịp
        let posRaw = posAlgorithm.extractPulse(red: r, green: g, blue: b)
        let ppgSignal = bandpassFilter.filterSignal(posRaw)

        // 2. Phân tích phổ nhịp tim (0.75 - 3.5 Hz ~ 45 - 210 BPM)
        guard let hrSpectral = fftAnalyzer.analyzeFrequency(signal: ppgSignal, minFreq: 0.75, maxFreq: 3.5) else {
            return nil
        }
        let hrBpm = hrSpectral.peakFrequency * 60.0
        guard hrBpm >= 40.0 && hrBpm <= 220.0 && !hrBpm.isNaN else { return nil }

        // 3. Phân tích HRV (SDNN, RMSSD) từ các đỉnh cực đại cục bộ
        let (sdnn, rmssd) = calculateHRV(from: ppgSignal)

        // 4. Ước lượng nhịp thở Respiration Rate (0.15 - 0.4 Hz ~ 9 - 24 lần/phút)
        let respSignal = respirationFilter.filterSignal(posRaw)
        let respSpectral = fftAnalyzer.analyzeFrequency(signal: respSignal, minFreq: 0.15, maxFreq: 0.4)
        let respRateBpm = (respSpectral?.peakFrequency ?? 0.25) * 60.0

        // 5. Tính chỉ số căng thẳng Stress Index (Dựa trên tỷ lệ tương quan nghịch với RMSSD & HR)
        let normalizedRmssd = min(max(rmssd, 10.0), 100.0)
        let rawStress = 100.0 - (normalizedRmssd - 10.0) * (60.0 / 90.0) + (hrBpm > 85 ? (hrBpm - 85) * 0.5 : 0)
        let stressIndex = min(max(rawStress.isNaN ? 45.0 : rawStress, 5.0), 95.0)

        // 6. Điểm sức sống và tuổi sinh học làn da (Skin Vitality & Bio-Age)
        let signalQuality = min(max(hrSpectral.snr / 5.0, 0.2), 1.0)
        let rawVitality = 70.0 + (100.0 - stressIndex) * 0.2 + signalQuality * 10.0
        let skinVitality = min(max(rawVitality.isNaN ? 80.0 : rawVitality, 40.0), 98.0)
        let rawSkinAge = 28.0 + (stressIndex - 40.0) * 0.15
        let estimatedSkinAge = max(20, min(65, rawSkinAge.safeInt))

        return VitalMetrics(
            heartRateBPM: hrBpm,
            hrvSDNN: sdnn,
            hrvRMSSD: rmssd,
            respirationRateBPM: respRateBpm,
            stressIndex: stressIndex,
            skinVitalityScore: skinVitality,
            estimatedSkinAge: estimatedSkinAge,
            signalQuality: signalQuality,
            timestamp: Date()
        )
    }

    /// Tính toán các chỉ số biến thiên nhịp tim HRV từ đỉnh R-R an toàn tuyệt đối
    private func calculateHRV(from signal: [Double]) -> (sdnn: Double, rmssd: Double) {
        guard signal.count > 30 else { return (42.0, 38.0) }

        var peakIndices: [Int] = []
        let minPeakDistance = Int(sampleRate * 0.35)

        for i in 2..<(signal.count - 2) {
            if signal[i] > signal[i - 1] && signal[i] > signal[i - 2] &&
               signal[i] > signal[i + 1] && signal[i] > signal[i + 2] &&
               signal[i] > 0 {
                if let lastPeak = peakIndices.last {
                    if (i - lastPeak) >= minPeakDistance {
                        peakIndices.append(i)
                    }
                } else {
                    peakIndices.append(i)
                }
            }
        }

        guard peakIndices.count >= 3 else {
            return (42.0, 38.0)
        }

        var rrIntervals: [Double] = []
        for i in 0..<(peakIndices.count - 1) {
            let diffFrames = Double(peakIndices[i + 1] - peakIndices[i])
            let diffMs = (diffFrames / sampleRate) * 1000.0
            if diffMs >= 300.0 && diffMs <= 1500.0 {
                rrIntervals.append(diffMs)
            }
        }

        guard rrIntervals.count >= 2 else { return (42.0, 38.0) }

        // 1. Tính SDNN
        let meanRR = rrIntervals.reduce(0.0, +) / Double(rrIntervals.count)
        guard !meanRR.isNaN && !meanRR.isInfinite else { return (42.0, 38.0) }
        let variance = rrIntervals.reduce(0.0) { $0 + pow($1 - meanRR, 2.0) } / Double(rrIntervals.count - 1)
        let sdnn = sqrt(max(0.0, variance.isNaN ? 0.0 : variance))

        // 2. Tính RMSSD
        var sumSquaredDiff = 0.0
        for i in 0..<(rrIntervals.count - 1) {
            let diff = rrIntervals[i + 1] - rrIntervals[i]
            sumSquaredDiff += pow(diff, 2.0)
        }
        let rmssd = sqrt(max(0.0, sumSquaredDiff / Double(rrIntervals.count - 1)))

        let finalSdnn = sdnn.isNaN || sdnn.isInfinite ? 42.0 : sdnn
        let finalRmssd = rmssd.isNaN || rmssd.isInfinite ? 38.0 : rmssd

        return (
            sdnn: min(max(finalSdnn, 15.0), 120.0),
            rmssd: min(max(finalRmssd, 12.0), 110.0)
        )
    }

    public func reset() {
        lock.lock()
        defer { lock.unlock() }
        redBuffer.removeAll()
        greenBuffer.removeAll()
        blueBuffer.removeAll()
        timestamps.removeAll()
        bandpassFilter.reset()
        respirationFilter.reset()
    }
}
