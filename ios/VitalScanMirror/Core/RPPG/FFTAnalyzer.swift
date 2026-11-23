import Foundation
import Accelerate

/// Phân tích phổ tần số bằng Biến đổi Fourier Nhanh (FFT) sử dụng Apple Accelerate Framework vDSP (100% Safe Memory)
public final class FFTAnalyzer {
    private let sampleRate: Double

    public init(sampleRate: Double = 30.0) {
        self.sampleRate = sampleRate
    }

    /// Cấu trúc kết quả phân tích phổ
    public struct SpectralResult {
        public let peakFrequency: Double
        public let peakMagnitude: Double
        public let snr: Double // Signal-to-Noise Ratio
        public let frequencies: [Double]
        public let magnitudes: [Double]
    }

    /// Tính toán mật độ phổ công suất (PSD) và tìm tần số ưu thế trong khoảng dải tần [minFreq, maxFreq]
    public func analyzeFrequency(signal: [Double], minFreq: Double = 0.75, maxFreq: Double = 3.5) -> SpectralResult? {
        let n = signal.count
        guard n >= 32 else { return nil }

        // Tìm lũy thừa bậc 2 gần nhất lớn hơn hoặc bằng N (Zero-padding)
        let log2n = vDSP_Length(ceil(log2(Double(n))))
        let fftSize = Int(1 << log2n)
        let halfSize = fftSize / 2

        guard let fftSetup = vDSP_create_fftsetup(log2n, FFTRadix(kFFTRadix2)) else { return nil }
        defer { vDSP_destroy_fftsetup(fftSetup) }

        // Chuẩn bị cửa sổ Hanning giảm rò rỉ phổ
        var window = [Double](repeating: 0.0, count: n)
        vDSP_hann_windowD(&window, vDSP_Length(n), Int32(vDSP_HANN_NORM))

        // Cấp phát mảng đầu vào đúng kích thước fftSize (Zero-padded hoàn toàn)
        var paddedSignal = [Double](repeating: 0.0, count: fftSize)
        for i in 0..<n {
            let val = signal[i] * window[i]
            paddedSignal[i] = val.isNaN || val.isInfinite ? 0.0 : val
        }

        // Tách thành phần chẵn (even) và lẻ (odd) cho split-complex real FFT trực tiếp trong Swift
        var realParts = [Double](repeating: 0.0, count: halfSize)
        var imagParts = [Double](repeating: 0.0, count: halfSize)

        for i in 0..<halfSize {
            realParts[i] = paddedSignal[2 * i]
            imagParts[i] = paddedSignal[2 * i + 1]
        }

        // Thực hiện biến đổi FFT 1 chiều với con trỏ hợp lệ tuyệt đối (KHÔNG bị dangling pointer)
        realParts.withUnsafeMutableBufferPointer { realBuf in
            imagParts.withUnsafeMutableBufferPointer { imagBuf in
                guard let realPtr = realBuf.baseAddress, let imagPtr = imagBuf.baseAddress else { return }
                var splitComplex = DSPDoubleSplitComplex(realp: realPtr, imagp: imagPtr)
                vDSP_fft_zripD(fftSetup, &splitComplex, 1, log2n, FFTDirection(FFT_FORWARD))
            }
        }

        // Tính biên độ công suất (Magnitudes)
        var magnitudes = [Double](repeating: 0.0, count: halfSize)
        for i in 0..<halfSize {
            let r = realParts[i]
            let im = imagParts[i]
            let mag = sqrt(r * r + im * im)
            magnitudes[i] = mag.isNaN || mag.isInfinite ? 0.0 : mag
        }

        // Tạo mảng tần số tương ứng cho từng bin
        var frequencies = [Double](repeating: 0.0, count: halfSize)
        let freqResolution = sampleRate / Double(fftSize)
        for i in 0..<halfSize {
            frequencies[i] = Double(i) * freqResolution
        }

        // Tìm đỉnh cực đại trong dải tần quan tâm [minFreq, maxFreq]
        var peakFreq = 0.0
        var maxMag = 0.0
        var peakIdx = -1
        var totalInBandEnergy = 0.0

        for i in 0..<halfSize {
            let f = frequencies[i]
            if f >= minFreq && f <= maxFreq {
                let m = magnitudes[i]
                totalInBandEnergy += m
                if m > maxMag {
                    maxMag = m
                    peakFreq = f
                    peakIdx = i
                }
            }
        }

        guard peakIdx >= 0 && maxMag > 0 else { return nil }

        // Tính tỷ lệ SNR tương đối
        let noiseFloor = (totalInBandEnergy - maxMag) / Double(max(1, halfSize / 4))
        let snr = noiseFloor > 1e-6 ? (maxMag / noiseFloor) : 1.0

        return SpectralResult(
            peakFrequency: peakFreq,
            peakMagnitude: maxMag,
            snr: snr.isNaN ? 1.0 : snr,
            frequencies: frequencies,
            magnitudes: magnitudes
        )
    }
}
