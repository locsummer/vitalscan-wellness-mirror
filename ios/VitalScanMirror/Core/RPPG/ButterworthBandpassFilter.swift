import Foundation

/// Bộ lọc dải thông kỹ thuật số Butterworth (Digital IIR Butterworth Bandpass Filter)
/// Thiết kế cho tần số lấy mẫu fs = 30 Hz, dải thông 0.75 Hz – 3.5 Hz (45 - 210 BPM)
public final class ButterworthBandpassFilter: @unchecked Sendable {
    private let sampleRate: Double
    private let lowCutoff: Double
    private let highCutoff: Double
    
    // Hệ số bộ lọc bậc 2 ghép tầng
    private var b0: Double = 0.0
    private var b1: Double = 0.0
    private var b2: Double = 0.0
    private var a1: Double = 0.0
    private var a2: Double = 0.0

    private var x1: Double = 0.0
    private var x2: Double = 0.0
    private var y1: Double = 0.0
    private var y2: Double = 0.0

    public init(sampleRate: Double = 30.0, lowCutoff: Double = 0.75, highCutoff: Double = 3.5) {
        self.sampleRate = sampleRate
        self.lowCutoff = lowCutoff
        self.highCutoff = highCutoff
        calculateCoefficients()
    }

    private func calculateCoefficients() {
        let centerFreq = sqrt(lowCutoff * highCutoff)
        let bandwidth = highCutoff - lowCutoff
        let omega = 2.0 * Double.pi * centerFreq / sampleRate
        let q = centerFreq / bandwidth
        let alpha = sin(omega) / (2.0 * q)

        let a0 = 1.0 + alpha
        b0 = (alpha) / a0
        b1 = 0.0
        b2 = (-alpha) / a0
        a1 = (-2.0 * cos(omega)) / a0
        a2 = (1.0 - alpha) / a0
    }

    /// Lọc từng mẫu tín hiệu trực tiếp với cơ chế chống nhiễm độc NaN/Infinity
    public func filterSample(_ x: Double) -> Double {
        let cleanX = x.isNaN || x.isInfinite ? 0.0 : x
        let y = b0 * cleanX + b1 * x1 + b2 * x2 - a1 * y1 - a2 * y2
        let cleanY = y.isNaN || y.isInfinite ? 0.0 : y
        x2 = x1
        x1 = cleanX
        y2 = y1
        y1 = cleanY
        return cleanY
    }

    /// Lọc toàn bộ mảng tín hiệu hai chiều thuận nghịch (Zero-Phase Forward-Backward Filter, Thread-safe tuyệt đối)
    public func filterSignal(_ signal: [Double]) -> [Double] {
        guard signal.count > 4 else { return signal }
        
        // 1. Forward pass với state cục bộ
        var forward = [Double](repeating: 0.0, count: signal.count)
        var fx1 = 0.0, fx2 = 0.0, fy1 = 0.0, fy2 = 0.0
        for i in 0..<signal.count {
            let x = signal[i]
            let cleanX = x.isNaN || x.isInfinite ? 0.0 : x
            let y = b0 * cleanX + b1 * fx1 + b2 * fx2 - a1 * fy1 - a2 * fy2
            let cleanY = y.isNaN || y.isInfinite ? 0.0 : y
            fx2 = fx1
            fx1 = cleanX
            fy2 = fy1
            fy1 = cleanY
            forward[i] = cleanY
        }

        // 2. Backward pass với state cục bộ (triệt tiêu độ lệch pha thời gian)
        var backward = [Double](repeating: 0.0, count: signal.count)
        var bx1 = 0.0, bx2 = 0.0, by1 = 0.0, by2 = 0.0
        for i in (0..<signal.count).reversed() {
            let x = forward[i]
            let cleanX = x.isNaN || x.isInfinite ? 0.0 : x
            let y = b0 * cleanX + b1 * bx1 + b2 * bx2 - a1 * by1 - a2 * by2
            let cleanY = y.isNaN || y.isInfinite ? 0.0 : y
            bx2 = bx1
            bx1 = cleanX
            by2 = by1
            by1 = cleanY
            backward[i] = cleanY
        }

        return backward
    }

    public func reset() {
        x1 = 0.0
        x2 = 0.0
        y1 = 0.0
        y2 = 0.0
    }
}
