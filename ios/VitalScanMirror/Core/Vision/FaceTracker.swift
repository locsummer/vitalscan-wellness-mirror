import Foundation
import CoreMedia
import CoreVideo
import CoreGraphics

/// Bộ trích xuất tín hiệu quang học vùng da mặt trung tâm (Siêu nhẹ, không xung đột, an toàn 100%)
public final class FaceTracker: @unchecked Sendable {
    public init() {}

    /// Trích xuất giá trị màu trung bình RGB từ vùng khuôn mặt bên trong khung gương soi (Hỗ trợ cả NV12 và 32BGRA)
    public func extractMeanRGB(from pixelBuffer: CVPixelBuffer) -> (r: Double, g: Double, b: Double)? {
        let lockStatus = CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        guard lockStatus == kCVReturnSuccess else { return nil }
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }

        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        guard width > 20 && height > 20 else { return nil }

        let isPlanar = CVPixelBufferIsPlanar(pixelBuffer)

        // Các vùng ROI chuẩn bên trong khung Oval: Trán (Forehead) và 2 bên Má (Cheeks)
        let sampleRects = [
            CGRect(x: 0.35, y: 0.22, width: 0.30, height: 0.15), // Trán
            CGRect(x: 0.25, y: 0.45, width: 0.20, height: 0.18), // Má trái
            CGRect(x: 0.55, y: 0.45, width: 0.20, height: 0.18)  // Má phải
        ]

        var totalR: Double = 0.0
        var totalG: Double = 0.0
        var totalB: Double = 0.0
        var count: Double = 0.0

        if isPlanar {
            // Định dạng camera chuẩn NV12 (YUV 420 BiPlanar) có kiểm tra biên tối đa từng byte
            guard CVPixelBufferGetPlaneCount(pixelBuffer) >= 1,
                  let yBase = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0) else { return nil }
            let yBytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0)
            let yHeight = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0)
            let yMaxOffset = yBytesPerRow * yHeight
            let yRaw = UnsafeRawPointer(yBase)

            let hasUV = CVPixelBufferGetPlaneCount(pixelBuffer) >= 2
            let uvBase = hasUV ? CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1) : nil
            let uvBytesPerRow = hasUV && uvBase != nil ? CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1) : 0
            let uvHeight = hasUV && uvBase != nil ? CVPixelBufferGetHeightOfPlane(pixelBuffer, 1) : 0
            let uvMaxOffset = uvBytesPerRow * uvHeight
            let uvRaw = uvBase != nil ? UnsafeRawPointer(uvBase!) : nil

            for rect in sampleRects {
                let startX = max(0, min(width - 1, Int(rect.origin.x * Double(width))))
                let endX = max(startX, min(width, Int((rect.origin.x + rect.size.width) * Double(width))))
                let startY = max(0, min(height - 1, Int(rect.origin.y * Double(height))))
                let endY = max(startY, min(height, Int((rect.origin.y + rect.size.height) * Double(height))))

                let step = 4
                for y in stride(from: startY, to: endY, by: step) {
                    let yRowOffset = y * yBytesPerRow
                    let uvRowOffset = (y / 2) * uvBytesPerRow

                    for x in stride(from: startX, to: endX, by: step) {
                        let yOffset = yRowOffset + x
                        guard yOffset < yMaxOffset else { continue }
                        let yVal = Double(yRaw.load(fromByteOffset: yOffset, as: UInt8.self))

                        var rVal = yVal
                        var gVal = yVal
                        var bVal = yVal

                        if let uv = uvRaw {
                            let uvOffset = uvRowOffset + (x / 2) * 2
                            if uvOffset + 1 < uvMaxOffset {
                                let cb = Double(uv.load(fromByteOffset: uvOffset, as: UInt8.self)) - 128.0
                                let cr = Double(uv.load(fromByteOffset: uvOffset + 1, as: UInt8.self)) - 128.0

                                rVal = min(max(yVal + 1.402 * cr, 0), 255)
                                gVal = min(max(yVal - 0.344136 * cb - 0.714136 * cr, 0), 255)
                                bVal = min(max(yVal + 1.772 * cb, 0), 255)
                            }
                        }

                        if yVal > 15 && yVal < 248 {
                            totalR += rVal
                            totalG += gVal
                            totalB += bVal
                            count += 1.0
                        }
                    }
                }
            }
        } else {
            // Định dạng 32BGRA chuẩn có kiểm tra biên tuyệt đối
            guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else { return nil }
            let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
            guard bytesPerRow >= width * 4 else { return nil }
            let maxOffset = bytesPerRow * height
            let raw = UnsafeRawPointer(baseAddress)

            for rect in sampleRects {
                let startX = max(0, min(width - 1, Int(rect.origin.x * Double(width))))
                let endX = max(startX, min(width, Int((rect.origin.x + rect.size.width) * Double(width))))
                let startY = max(0, min(height - 1, Int(rect.origin.y * Double(height))))
                let endY = max(startY, min(height, Int((rect.origin.y + rect.size.height) * Double(height))))

                let step = 4
                for y in stride(from: startY, to: endY, by: step) {
                    let rowOffset = y * bytesPerRow
                    for x in stride(from: startX, to: endX, by: step) {
                        let offset = rowOffset + x * 4
                        guard offset + 3 < maxOffset else { continue }

                        let b = Double(raw.load(fromByteOffset: offset, as: UInt8.self))
                        let g = Double(raw.load(fromByteOffset: offset + 1, as: UInt8.self))
                        let r = Double(raw.load(fromByteOffset: offset + 2, as: UInt8.self))

                        let brightness = (r + g + b) / 3.0
                        if brightness > 15 && brightness < 248 {
                            totalR += r
                            totalG += g
                            totalB += b
                            count += 1.0
                        }
                    }
                }
            }
        }

        guard count > 15 else { return nil }
        return (r: totalR / count, g: totalG / count, b: totalB / count)
    }
}
