import Foundation
import Vision
import CoreMedia
import CoreImage

/// Bộ theo dõi và nhận diện các vùng da quan tâm (ROI) trên khuôn mặt bằng Apple Vision Framework (Đa định dạng pixel, an toàn bộ nhớ tuyệt đối)
public final class FaceTracker: @unchecked Sendable {
    public init() {}

    /// Nhận diện khuôn mặt và trích xuất tọa độ các vùng ROI (Trán, 2 bên gò má)
    public func detectFaceROI(in pixelBuffer: CVPixelBuffer) -> FaceROI? {
        let request = VNDetectFaceRectanglesRequest()
        #if targetEnvironment(simulator)
        request.usesCPUOnly = true
        #endif

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        do {
            try handler.perform([request])
        } catch {
            return nil
        }

        guard let results = request.results,
              let primaryFace = results.first else {
            return nil
        }

        let faceBounds = primaryFace.boundingBox
        let isCentered = (faceBounds.midX >= 0.18 && faceBounds.midX <= 0.82) &&
                         (faceBounds.midY >= 0.18 && faceBounds.midY <= 0.82) &&
                         (faceBounds.width >= 0.20 && faceBounds.height >= 0.25)

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

    /// Trích xuất giá trị màu trung bình RGB từ các vùng ROI của CVPixelBuffer (Hỗ trợ cả BGRA và YUV Planar)
    public func extractMeanRGB(from pixelBuffer: CVPixelBuffer, roi: FaceROI) -> (r: Double, g: Double, b: Double)? {
        let lockStatus = CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        guard lockStatus == kCVReturnSuccess else { return nil }
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }

        let pixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer)
        let isPlanar = CVPixelBufferIsPlanar(pixelBuffer)

        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        guard width > 10 && height > 10 else { return nil }

        let rois = [roi.foreheadRect, roi.leftCheekRect, roi.rightCheekRect]
        var totalR: Double = 0.0
        var totalG: Double = 0.0
        var totalB: Double = 0.0
        var sampleCount: Double = 0.0

        if !isPlanar && pixelFormat == kCVPixelFormatType_32BGRA {
            // Định dạng 32BGRA
            guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else { return nil }
            let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
            let maxOffset = height * bytesPerRow
            let bufferPtr = baseAddress.assumingMemoryBound(to: UInt8.self)

            for rect in rois {
                let startX = max(0, min(width - 1, Int(rect.origin.x * Double(width))))
                let startY = max(0, min(height - 1, Int((1.0 - (rect.origin.y + rect.size.height)) * Double(height))))
                let endX = max(0, min(width - 1, Int((rect.origin.x + rect.size.width) * Double(width))))
                let endY = max(0, min(height - 1, Int((1.0 - rect.origin.y) * Double(height))))

                guard startX < endX && startY < endY else { continue }

                let step = 3
                for y in stride(from: startY, to: endY, by: step) {
                    let rowOffset = y * bytesPerRow
                    for x in stride(from: startX, to: endX, by: step) {
                        let pixelOffset = rowOffset + x * 4
                        guard pixelOffset + 3 <= maxOffset else { continue }
                        let b = Double(bufferPtr[pixelOffset])
                        let g = Double(bufferPtr[pixelOffset + 1])
                        let r = Double(bufferPtr[pixelOffset + 2])

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
        } else if isPlanar {
            // Định dạng camera chuẩn NV12 (YUV 420 BiPlanar)
            guard let yBase = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0) else { return nil }
            let yBytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0)
            let yMaxOffset = height * yBytesPerRow
            let yPtr = yBase.assumingMemoryBound(to: UInt8.self)

            for rect in rois {
                let startX = max(0, min(width - 1, Int(rect.origin.x * Double(width))))
                let startY = max(0, min(height - 1, Int((1.0 - (rect.origin.y + rect.size.height)) * Double(height))))
                let endX = max(0, min(width - 1, Int((rect.origin.x + rect.size.width) * Double(width))))
                let endY = max(0, min(height - 1, Int((1.0 - rect.origin.y) * Double(height))))

                guard startX < endX && startY < endY else { continue }

                let step = 3
                for y in stride(from: startY, to: endY, by: step) {
                    let rowOffset = y * yBytesPerRow
                    for x in stride(from: startX, to: endX, by: step) {
                        let pixelOffset = rowOffset + x
                        guard pixelOffset < yMaxOffset else { continue }
                        let yVal = Double(yPtr[pixelOffset])
                        if yVal > 25.0 && yVal < 240.0 {
                            totalR += yVal
                            totalG += yVal
                            totalB += yVal
                            sampleCount += 1.0
                        }
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
