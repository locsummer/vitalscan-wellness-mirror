package com.vitalscan.mirror.rppg

import android.graphics.RectF

data class VitalMetrics(
    val heartRateBpm: Double = 0.0,
    val hrvSdnn: Double = 0.0,
    val hrvRmssd: Double = 0.0,
    val respirationRateBpm: Double = 0.0,
    val stressIndex: Double = 0.0,
    val skinVitalityScore: Double = 0.0,
    val estimatedSkinAge: Int = 25,
    val signalQuality: Double = 0.0,
    val timestamp: Long = System.currentTimeMillis()
)

sealed class ScannerState {
    object Idle : ScannerState()
    object SearchingFace : ScannerState()
    object FaceAligned : ScannerState()
    data class Measuring(val progress: Float, val currentBpm: Double) : ScannerState()
    data class Completed(val metrics: VitalMetrics) : ScannerState()
    data class Failed(val reason: String) : ScannerState()
}

data class FaceRoiData(
    val foreheadRect: RectF,
    val leftCheekRect: RectF,
    val rightCheekRect: RectF,
    val isFaceWellCentered: Boolean,
    val confidence: Float
)
