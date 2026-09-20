import Foundation
import Accelerate

/// Triển khai thuật toán POS (Plane-Orthogonal-to-Skin) trích xuất tín hiệu xung nhịp rPPG
/// Wang, W., et al. (2017). Algorithmic principles of remote PPG. IEEE TBME.
public final class POSAlgorithm {
    private let windowSize: Int

    public init(windowSize: Int = 45) { // Cửa sổ trượt ~1.5 giây tại 30 fps
        self.windowSize = windowSize
    }

    /// Trích xuất tín hiệu rPPG 1D từ mảng 3 kênh màu trung bình RGB theo thời gian
    /// - Parameters:
    ///   - red: Chuỗi giá trị trung bình kênh Đỏ
    ///   - green: Chuỗi giá trị trung bình kênh Xanh lá
    ///   - blue: Chuỗi giá trị trung bình kênh Xanh dương
    /// - Returns: Chuỗi tín hiệu xung nhịp thô H(t)
    public func extractPulse(red: [Double], green: [Double], blue: [Double]) -> [Double] {
        let length = min(red.count, green.count, blue.count)
        guard length >= windowSize else {
            // Nếu chưa đủ kích thước cửa sổ, dùng Green-Red difference đơn giản
            return zip(green, red).map { $0.0 - 0.5 * $0.1 }
        }

        var hSignal = [Double](repeating: 0.0, count: length)
        var overlapCounts = [Double](repeating: 0.0, count: length)

        // Cửa sổ trượt tính toán POS
        let strideStep = 1
        for start in stride(from: 0, through: length - windowSize, by: strideStep) {
            let end = start + windowSize
            
            let rSub = Array(red[start..<end])
            let gSub = Array(green[start..<end])
            let bSub = Array(blue[start..<end])

            // 1. Chuẩn hóa thời gian (Temporal Normalization)
            let meanR = rSub.reduce(0.0, +) / Double(windowSize)
            let meanG = gSub.reduce(0.0, +) / Double(windowSize)
            let meanB = bSub.reduce(0.0, +) / Double(windowSize)

            guard meanR > 1e-6, meanG > 1e-6, meanB > 1e-6 else { continue }

            let rNorm = rSub.map { $0 / meanR }
            let gNorm = gSub.map { $0 / meanG }
            let bNorm = bSub.map { $0 / meanB }

            // 2. Chiếu trực giao 2 thành phần tín hiệu
            // S1 = G - B
            // S2 = G + B - 2*R
            var s1 = [Double](repeating: 0.0, count: windowSize)
            var s2 = [Double](repeating: 0.0, count: windowSize)

            for i in 0..<windowSize {
                s1[i] = gNorm[i] - bNorm[i]
                s2[i] = gNorm[i] + bNorm[i] - 2.0 * rNorm[i]
            }

            // 3. Tính tỷ số độ lệch chuẩn alpha = std(S1) / std(S2)
            let stdS1 = standardDeviation(s1)
            let stdS2 = standardDeviation(s2)
            let alpha = stdS2 > 1e-6 ? (stdS1 / stdS2) : 1.0

            // 4. Tổng hợp h = S1 + alpha * S2 và trừ giá trị trung bình
            let hWindow = (0..<windowSize).map { s1[$0] + alpha * s2[$0] }
            let meanH = hWindow.reduce(0.0, +) / Double(windowSize)

            for i in 0..<windowSize {
                let targetIdx = start + i
                hSignal[targetIdx] += (hWindow[i] - meanH)
                overlapCounts[targetIdx] += 1.0
            }
        }

        // Trung bình hóa các vùng chồng lấn (Overlap-Add)
        for i in 0..<length {
            if overlapCounts[i] > 0 {
                hSignal[i] /= overlapCounts[i]
            }
        }

        return hSignal
    }

    private func standardDeviation(_ array: [Double]) -> Double {
        guard array.count > 1 else { return 0.0 }
        let mean = array.reduce(0.0, +) / Double(array.count)
        let variance = array.reduce(0.0) { $0 + pow($1 - mean, 2.0) } / Double(array.count - 1)
        return sqrt(max(0.0, variance))
    }
}
