import Foundation
import Vision
import CoreMedia
import CoreImage

/// Bộ theo dõi và nhận diện các vùng da quan tâm (ROI) trên khuôn mặt bằng Apple Vision Framework (Đa định dạng pixel, an toàn bộ nhớ tuyệt đối)
public final class FaceTracker: @unchecked Sendable {
    public init() {}

    /// Nhận diện khuôn mặt và trích xuất tọa độ các vùng ROI (Trán, 2 bên gò má) với autoreleasepool chống rò rỉ bộ nhớ
    public func detectFaceROI(in pixelBuffer: CVPixelBuffer) -> FaceROI? {
        return autoreleasepool { () -> FaceROI? in
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
            let isCentered = (faceBounds.midX >= 0.15 && faceBounds.midX <= 0.85) &&
                             (faceBounds.midY >= 0.15 && faceBounds.midY <= 0.85) &&
                             (faceBounds.width >= 0.18 && faceBounds.height >= 0.22)

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
    }

    /// Trích xuất giá trị màu trung bình RGB từ các vùng ROI của CVPixelBuffer (Hỗ trợ cả BGRA và YUV Planar với Rec.601 YCbCr->RGB)
    public func extractMeanRGB(from pixelBuffer: CVPixelBuffer, roi: FaceROI) -> (r: Double, g: Double, b: Double)? {
        return autoreleasepool { () -> (r: Double, g: Double, b: Double)? in
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
                let maxByteOffset = height * bytesPerRow
                let rawPtr = UnsafeRawPointer(baseAddress)

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
                            guard pixelOffset + 3 < maxByteOffset else { continue }
                            let b = Double(rawPtr.load(fromByteOffset: pixelOffset, as: UInt8.self))
                            let g = Double(rawPtr.load(fromByteOffset: pixelOffset + 1, as: UInt8.self))
                            let r = Double(rawPtr.load(fromByteOffset: pixelOffset + 2, as: UInt8.self))

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
                let yRawPtr = UnsafeRawPointer(yBase)

                let uvBase = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1)
                let uvBytesPerRow = uvBase != nil ? CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1) : 0
                let uvHeight = uvBase != nil ? CVPixelBufferGetHeightOfPlane(pixelBuffer, 1) : 0
                let uvMaxOffset = uvBytesPerRow * uvHeight
                let uvRawPtr = uvBase != nil ? UnsafeRawPointer(uvBase!) : nil

                for rect in rois {
                    let startX = max(0, min(width - 1, Int(rect.origin.x * Double(width))))
                    let startY = max(0, min(height - 1, Int((1.0 - (rect.origin.y + rect.size.height)) * Double(height))))
                    let endX = max(0, min(width - 1, Int((rect.origin.x + rect.size.width) * Double(width))))
                    let endY = max(0, min(height - 1, Int((1.0 - rect.origin.y) * Double(height))))

                    guard startX < endX && startY < endY else { continue }

                    let step = 3
                    for y in stride(from: startY, to: endY, by: step) {
                        let yRowOffset = y * yBytesPerRow
                        let uvRowOffset = (y / 2) * uvBytesPerRow

                        for x in stride(from: startX, to: endX, by: step) {
                            let yOffset = yRowOffset + x
                            guard yOffset < yMaxOffset else { continue }
                            let yVal = Double(yRawPtr.load(fromByteOffset: yOffset, as: UInt8.self))

                            var rVal = yVal
                            var gVal = yVal
                            var bVal = yVal

                            if let uvPtr = uvRawPtr {
                                let uvOffset = uvRowOffset + (x / 2) * 2
                                if uvOffset + 1 < uvMaxOffset {
                                    let cb = Double(uvPtr.load(fromByteOffset: uvOffset, as: UInt8.self)) - 128.0
                                    let cr = Double(uvPtr.load(fromByteOffset: uvOffset + 1, as: UInt8.self)) - 128.0

                                    let r = yVal + 1.402 * cr
                                    let g = yVal - 0.344136 * cb - 0.714136 * cr
                                    let b = yVal + 1.772 * cb

                                    rVal = min(max(r, 0.0), 255.0)
                                    gVal = min(max(g, 0.0), 255.0)
                                    bVal = min(max(b, 0.0), 255.0)
                                }
                            }

                            let brightness = (rVal + gVal + bVal) / 3.0
                            if brightness > 25.0 && brightness < 240.0 {
                                totalR += rVal
                                totalG += gVal
                                totalB += bVal
                                sampleCount += 1.0
                            }
                        }
                    }
                }
            }

            guard sampleCount > 30 else { return nil }

            return (
                r: totalR / sampleCount,
                g: totalG / sampleCount,
                b: totalB / sampleCount
            )
        }
    }
}
