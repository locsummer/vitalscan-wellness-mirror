import Foundation
import Vision
import CoreMedia
import CoreImage

/// Bộ theo dõi và nhận diện các vùng da quan tâm (ROI) trên khuôn mặt bằng Apple Vision Framework
public final class FaceTracker {
    private var sequenceHandler = VNSequenceRequestHandler()

    public init() {}

    /// Nhận diện khuôn mặt và trích xuất tọa độ các vùng ROI (Trán, 2 bên gò má)
    public func detectFaceROI(in pixelBuffer: CVPixelBuffer) -> FaceROI? {
        let request = VNDetectFaceLandmarksRequest()
        #if targetEnvironment(simulator)
        request.usesCPUOnly = true
        #endif

        do {
            try sequenceHandler.perform([request], on: pixelBuffer, orientation: .up)
        } catch {
            return nil
        }

        guard let results = request.results as? [VNFaceObservation],
              let primaryFace = results.first else {
            return nil
        }

        let faceBounds = primaryFace.boundingBox
        let isCentered = (faceBounds.midX >= 0.25 && faceBounds.midX <= 0.75) &&
                         (faceBounds.midY >= 0.25 && faceBounds.midY <= 0.75) &&
                         (faceBounds.width >= 0.25 && faceBounds.height >= 0.3)

        // Trích xuất vùng trán (Forehead): Vùng phía trên lông mày
        let foreheadRect = CGRect(
            x: faceBounds.origin.x + faceBounds.size.width * 0.25,
            y: faceBounds.origin.y + faceBounds.size.height * 0.70,
            width: faceBounds.size.width * 0.50,
            height: faceBounds.size.height * 0.18
        )

        // Trích xuất vùng má trái (Left Cheek)
        let leftCheekRect = CGRect(
            x: faceBounds.origin.x + faceBounds.size.width * 0.15,
            y: faceBounds.origin.y + faceBounds.size.height * 0.30,
            width: faceBounds.size.width * 0.22,
            height: faceBounds.size.height * 0.22
        )

        // Trích xuất vùng má phải (Right Cheek)
        let rightCheekRect = CGRect(
            x: faceBounds.origin.x + faceBounds.size.width * 0.63,
            y: faceBounds.origin.y + faceBounds.size.height * 0.30,
            width: faceBounds.size.width * 0.22,
            height: faceBounds.size.height * 0.22
        )

        return FaceROI(
            foreheadRect: foreheadRect,
            leftCheekRect: leftCheekRect,
            rightCheekRect: rightCheekRect,
            isFaceWellCentered: isCentered,
            confidence: primaryFace.confidence
        )
    }

    /// Trích xuất giá trị màu trung bình RGB từ các vùng ROI của CVPixelBuffer
    public func extractMeanRGB(from pixelBuffer: CVPixelBuffer, roi: FaceROI) -> (r: Double, g: Double, b: Double)? {
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }

        guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else { return nil }

        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let bufferPtr = baseAddress.assumingMemoryBound(to: UInt8.self)

        // Lấy mẫu từ các vùng ROI: Forehead + Cheeks
        let rois = [roi.foreheadRect, roi.leftCheekRect, roi.rightCheekRect]
        var totalR: Double = 0.0
        var totalG: Double = 0.0
        var totalB: Double = 0.0
        var sampleCount: Double = 0.0

        for rect in rois {
            // Chuyển tọa độ Vision chuẩn hóa [0, 1] sang pixel
            let startX = max(0, min(width - 1, Int(rect.origin.x * Double(width))))
            let startY = max(0, min(height - 1, Int((1.0 - (rect.origin.y + rect.size.height)) * Double(height))))
            let endX = max(0, min(width - 1, Int((rect.origin.x + rect.size.width) * Double(width))))
            let endY = max(0, min(height - 1, Int((1.0 - rect.origin.y) * Double(height))))

            let step = 3 // Lấy mẫu cách bước để tối ưu CPU 30 FPS
            for y in stride(from: startY, to: endY, by: step) {
                let rowOffset = y * bytesPerRow
                for x in stride(from: startX, to: endX, by: step) {
                    let pixelOffset = rowOffset + x * 4
                    // Định dạng kCVPixelFormatType_32BGRA
                    let b = Double(bufferPtr[pixelOffset])
                    let g = Double(bufferPtr[pixelOffset + 1])
                    let r = Double(bufferPtr[pixelOffset + 2])

                    // Lọc loại trừ điểm ảnh quá sáng/cháy sáng hoặc quá tối
                    let brightness = (r + g + b) / 3.0
                    if brightness > 25.0 && brightness < 240.0 {
                        totalR += r
                        totalG += g
                        totalB += b
                        sampleCount += 1.0
                    }
                }
            }
        }

        guard sampleCount > 50 else { return nil }

        return (
            r: totalR / sampleCount,
            g: totalG / sampleCount,
            b: totalB / sampleCount
        )
    }
}
