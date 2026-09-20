package com.vitalscan.mirror.camera

import android.graphics.RectF
import androidx.annotation.OptIn
import androidx.camera.core.ExperimentalGetImage
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageProxy
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.face.Face
import com.google.mlkit.vision.face.FaceDetection
import com.google.mlkit.vision.face.FaceDetectorOptions
import com.vitalscan.mirror.rppg.FaceRoiData
import java.nio.ByteBuffer

interface OnFaceRoiExtractedListener {
    fun onFaceRoiDetected(roiData: FaceRoiData?)
    fun onRgbDataExtracted(r: Double, g: Double, b: Double, timestamp: Long)
}

class FaceRoiAnalyzer(
    private val listener: OnFaceRoiExtractedListener
) : ImageAnalysis.Analyzer {

    private val detectorOptions = FaceDetectorOptions.Builder()
        .setPerformanceMode(FaceDetectorOptions.PERFORMANCE_MODE_FAST)
        .setLandmarkMode(FaceDetectorOptions.LANDMARK_MODE_NONE)
        .setClassificationMode(FaceDetectorOptions.CLASSIFICATION_MODE_NONE)
        .setMinFaceSize(0.25f)
        .build()

    private val detector = FaceDetection.getClient(detectorOptions)

    @OptIn(ExperimentalGetImage::class)
    override fun analyze(imageProxy: ImageProxy) {
        val mediaImage = imageProxy.image
        if (mediaImage == null) {
            imageProxy.close()
            return
        }

        val imageWidth = imageProxy.width
        val imageHeight = imageProxy.height
        val rotationDegrees = imageProxy.imageInfo.rotationDegrees
        val inputImage = InputImage.fromMediaImage(mediaImage, rotationDegrees)

        detector.process(inputImage)
            .addOnSuccessListener { faces ->
                if (faces.isNotEmpty()) {
                    val primaryFace = faces[0]
                    val roiData = computeFaceRoi(primaryFace, imageWidth, imageHeight)
                    listener.onFaceRoiDetected(roiData)

                    // Trích xuất màu RGB từ YUV Image
                    extractRgbFromYuv(imageProxy, roiData)
                } else {
                    listener.onFaceRoiDetected(null)
                }
            }
            .addOnFailureListener {
                listener.onFaceRoiDetected(null)
            }
            .addOnCompleteListener {
                imageProxy.close()
            }
    }

    private fun computeFaceRoi(face: Face, imgWidth: Int, imgHeight: Int): FaceRoiData {
        val box = face.boundingBox
        val normLeft = box.left.toFloat() / imgWidth
        val normTop = box.top.toFloat() / imgHeight
        val normWidth = box.width().toFloat() / imgWidth
        val normHeight = box.height().toFloat() / imgHeight

        val isCentered = (normLeft >= 0.1f && normLeft + normWidth <= 0.9f) &&
                         (normTop >= 0.1f && normTop + normHeight <= 0.9f)

        // Trán: 50% chiều ngang, 18% chiều cao ở đỉnh mặt
        val forehead = RectF(
            box.left + box.width() * 0.25f,
            box.top + box.height() * 0.05f,
            box.left + box.width() * 0.75f,
            box.top + box.height() * 0.22f
        )

        // Gò má trái
        val leftCheek = RectF(
            box.left + box.width() * 0.15f,
            box.top + box.height() * 0.45f,
            box.left + box.width() * 0.38f,
            box.top + box.height() * 0.65f
        )

        // Gò má phải
        val rightCheek = RectF(
            box.left + box.width() * 0.62f,
            box.top + box.height() * 0.45f,
            box.left + box.width() * 0.85f,
            box.top + box.height() * 0.65f
        )

        return FaceRoiData(
            foreheadRect = forehead,
            leftCheekRect = leftCheek,
            rightCheekRect = rightCheek,
            isFaceWellCentered = isCentered,
            confidence = 0.9f
        )
    }

    @OptIn(ExperimentalGetImage::class)
    private fun extractRgbFromYuv(imageProxy: ImageProxy, roiData: FaceRoiData) {
        val image = imageProxy.image ?: return
        val planes = image.planes
        val yPlane = planes[0].buffer
        val uPlane = planes[1].buffer
        val vPlane = planes[2].buffer

        val yRowStride = planes[0].rowStride
        val yPixelStride = planes[0].pixelStride
        val uvRowStride = planes[1].rowStride
        val uvPixelStride = planes[1].pixelStride

        val width = image.width
        val height = image.height

        val rois = listOf(roiData.foreheadRect, roiData.leftCheekRect, roiData.rightCheekRect)
        var sumR = 0.0
        var sumG = 0.0
        var sumB = 0.0
        var count = 0

        val step = 3 // Bước nhảy lấy mẫu tối ưu tốc độ CPU

        for (rect in rois) {
            val startX = maxOf(0, rect.left.toInt())
            val startY = maxOf(0, rect.top.toInt())
            val endX = minOf(width - 1, rect.right.toInt())
            val endY = minOf(height - 1, rect.bottom.toInt())

            for (y in startY until endY step step) {
                for (x in startX until endX step step) {
                    val yIndex = y * yRowStride + x * yPixelStride
                    val yVal = (yPlane.get(yIndex).toInt() and 0xFF)

                    val uvIndex = (y / 2) * uvRowStride + (x / 2) * uvPixelStride
                    val uVal = (uPlane.get(uvIndex).toInt() and 0xFF) - 128
                    val vVal = (vPlane.get(uvIndex).toInt() and 0xFF) - 128

                    // Chuyển đổi YUV sang RGB
                    val r = (yVal + 1.370705 * vVal).coerceIn(0.0, 255.0)
                    val g = (yVal - 0.337633 * uVal - 0.698001 * vVal).coerceIn(0.0, 255.0)
                    val b = (yVal + 1.732446 * uVal).coerceIn(0.0, 255.0)

                    val brightness = (r + g + b) / 3.0
                    if (brightness in 25.0..240.0) {
                        sumR += r
                        sumG += g
                        sumB += b
                        count++
                    }
                }
            }
        }

        if (count > 50) {
            listener.onRgbDataExtracted(
                sumR / count,
                sumG / count,
                sumB / count,
                System.currentTimeMillis()
            )
        }
    }
}
