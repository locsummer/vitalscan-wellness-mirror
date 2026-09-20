import Foundation

/// Dữ liệu các chỉ số sinh trắc học sức khỏe thu được từ quá trình quét rPPG
public struct VitalMetrics: Codable, Equatable {
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
        self.heartRateBPM = heartRateBPM
        self.hrvSDNN = hrvSDNN
        self.hrvRMSSD = hrvRMSSD
        self.respirationRateBPM = respirationRateBPM
        self.stressIndex = stressIndex
        self.skinVitalityScore = skinVitalityScore
        self.estimatedSkinAge = estimatedSkinAge
        self.signalQuality = signalQuality
        self.timestamp = timestamp
    }
}

/// Trạng thái quét của Mirror
public enum ScanState: Equatable {
    case idle
    case searchingFace
    case faceAligned
    case calibrating(progress: Double)
    case measuring(progress: Double, currentBPM: Double)
    case completed(VitalMetrics)
    case failed(reason: String)
}

/// Vùng quan tâm (Region of Interest - ROI) trên khuôn mặt
public struct FaceROI {
    public var foreheadRect: CGRect
    public var leftCheekRect: CGRect
    public var rightCheekRect: CGRect
    public var isFaceWellCentered: Bool
    public var confidence: Float

    public init(
        foreheadRect: CGRect = .zero,
        leftCheekRect: CGRect = .zero,
        rightCheekRect: CGRect = .zero,
        isFaceWellCentered: Bool = false,
        confidence: Float = 0.0
    ) {
        self.foreheadRect = foreheadRect
        self.leftCheekRect = leftCheekRect
        self.rightCheekRect = rightCheekRect
        self.isFaceWellCentered = isFaceWellCentered
        self.confidence = confidence
    }
}
