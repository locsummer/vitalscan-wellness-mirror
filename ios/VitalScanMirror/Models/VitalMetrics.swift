import Foundation

extension Double {
    /// Chuyển đổi Double sang Int an toàn tuyệt đối, tránh lỗi Fatal Crash khi gặp NaN hoặc Infinity
    public var safeInt: Int {
        if self.isNaN || self.isInfinite {
            return 0
        }
        if self > Double(Int.max) {
            return Int.max
        }
        if self < Double(Int.min) {
            return Int.min
        }
        return Int(self)
    }
}

/// Dữ liệu các chỉ số sinh trắc học sức khỏe thu được từ quá trình quét rPPG
public struct VitalMetrics: Codable, Equatable, Sendable {
    public var heartRateBPM: Double         // Nhịp tim (BPM)
    public var hrvSDNN: Double              // Độ lệch chuẩn khoảng cách liên nhịp (ms)
    public var hrvRMSSD: Double             // Căn bậc hai trung bình sai phân liên tiếp (ms)
    public var respirationRateBPM: Double   // Nhịp thở ước tính (lần/phút)
    public var stressIndex: Double          // Chỉ số căng thẳng (1 - 100)
    public var skinVitalityScore: Double    // Điểm sức sống làn da (1 - 100)
    public var estimatedSkinAge: Int        // Tuổi sinh học làn da ước tính
    public var signalQuality: Double        // Chất lượng tín hiệu (0.0 - 1.0)
    public var timestamp: Date

    public init(
        heartRateBPM: Double = 0.0,
        hrvSDNN: Double = 0.0,
        hrvRMSSD: Double = 0.0,
        respirationRateBPM: Double = 0.0,
        stressIndex: Double = 0.0,
        skinVitalityScore: Double = 0.0,
        estimatedSkinAge: Int = 25,
        signalQuality: Double = 0.0,
        timestamp: Date = Date()
    ) {
        self.heartRateBPM = heartRateBPM.isNaN || heartRateBPM.isInfinite ? 72.0 : heartRateBPM
        self.hrvSDNN = hrvSDNN.isNaN || hrvSDNN.isInfinite ? 42.0 : hrvSDNN
        self.hrvRMSSD = hrvRMSSD.isNaN || hrvRMSSD.isInfinite ? 38.0 : hrvRMSSD
        self.respirationRateBPM = respirationRateBPM.isNaN || respirationRateBPM.isInfinite ? 16.0 : respirationRateBPM
        self.stressIndex = stressIndex.isNaN || stressIndex.isInfinite ? 40.0 : stressIndex
        self.skinVitalityScore = skinVitalityScore.isNaN || skinVitalityScore.isInfinite ? 85.0 : skinVitalityScore
        self.estimatedSkinAge = estimatedSkinAge < 18 ? 25 : estimatedSkinAge
        self.signalQuality = signalQuality.isNaN || signalQuality.isInfinite ? 0.8 : signalQuality
        self.timestamp = timestamp
    }
}

/// Trạng thái quét của Mirror
public enum ScanState: Equatable, Sendable {
    case idle
    case searchingFace
    case faceAligned
    case calibrating(progress: Double)
    case measuring(progress: Double, currentBPM: Double)
    case completed(VitalMetrics)
    case failed(reason: String)
}

/// Vùng quan tâm (Region of Interest - ROI) trên khuôn mặt
public struct FaceROI: Equatable, Sendable {
    public let foreheadRect: CGRect
    public let leftCheekRect: CGRect
    public let rightCheekRect: CGRect
    public let isFaceWellCentered: Bool
    public let confidence: Float

    public init(foreheadRect: CGRect, leftCheekRect: CGRect, rightCheekRect: CGRect, isFaceWellCentered: Bool, confidence: Float) {
        self.foreheadRect = foreheadRect
        self.leftCheekRect = leftCheekRect
        self.rightCheekRect = rightCheekRect
        self.isFaceWellCentered = isFaceWellCentered
        self.confidence = confidence
    }
}
