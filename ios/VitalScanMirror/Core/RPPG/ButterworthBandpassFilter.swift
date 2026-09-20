import Foundation

/// Bộ lọc dải thông kỹ thuật số Butterworth (Digital IIR Butterworth Bandpass Filter)
/// Thiết kế cho tần số lấy mẫu fs = 30 Hz, dải thông 0.75 Hz – 3.5 Hz (45 - 210 BPM)
public final class ButterworthBandpassFilter {
    private let sampleRate: Double
    private let lowCutoff: Double
    private let highCutoff: Double
    
    // Hệ số bộ lọc bậc 2 ghép tầng (Biquad cascade coefficients)
    // Coeffs calculated for fs=30Hz, fl=0.75Hz, fh=3.5Hz
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

    /// Lọc từng mẫu tín hiệu trực tiếp (Real-time stream)
    public func filterSample(_ x: Double) -> Double {
        let y = b0 * x + b1 * x1 + b2 * x2 - a1 * y1 - a2 * y2
        x2 = x1
        x1 = x
        y2 = y1
        y1 = y
        return y
    }

    /// Lọc toàn bộ mảng tín hiệu hai chiều thuận nghịch (Zero-Phase Forward-Backward Filter)
    public func filterSignal(_ signal: [Double]) -> [Double] {
        guard signal.count > 4 else { return signal }
        
        // 1. Forward pass
        var forward = [Double](repeating: 0.0, count: signal.count)
        reset()
        for i in 0..<signal.count {
            forward[i] = filterSample(signal[i])
        }

        // 2. Backward pass (để triệt tiêu độ lệch pha thời gian)
        var backward = [Double](repeating: 0.0, count: signal.count)
        reset()
        for i in (0..<signal.count).reversed() {
            backward[i] = filterSample(forward[i])
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
