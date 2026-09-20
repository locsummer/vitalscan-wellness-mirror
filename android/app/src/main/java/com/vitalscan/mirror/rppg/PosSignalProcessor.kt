package com.vitalscan.mirror.rppg

import kotlin.math.*

/**
 * Bộ xử lý tín hiệu rPPG toàn diện trên Android bằng thuật toán POS (Plane-Orthogonal-to-Skin)
 */
class PosSignalProcessor(
    private val sampleRate: Double = 30.0,
    private val bufferCapacity: Int = 300, // 10 giây tại 30 fps
    private val windowSize: Int = 45       // 1.5 giây sliding window
) {
    private val redBuffer = ArrayList<Double>()
    private val greenBuffer = ArrayList<Double>()
    private val blueBuffer = ArrayList<Double>()
    private val timestamps = ArrayList<Long>()

    private val bandpassFilter = BandpassFilter(sampleRate, 0.75, 3.5)
    private val respirationFilter = BandpassFilter(sampleRate, 0.15, 0.4)
    private val fftTransformer = FftTransformer(sampleRate)

    @Synchronized
    fun appendRgb(r: Double, g: Double, b: Double, timestamp: Long) {
        redBuffer.add(r)
        greenBuffer.add(g)
        blueBuffer.add(b)
        timestamps.add(timestamp)

        if (redBuffer.size > bufferCapacity) {
            redBuffer.removeAt(0)
            greenBuffer.removeAt(0)
            blueBuffer.removeAt(0)
            timestamps.removeAt(0)
        }
    }

    @Synchronized
    fun getLatestFilteredWaveform(count: Int = 60): List<Double> {
        if (redBuffer.size < windowSize) {
            return List(count) { 0.0 }
        }
        val posRaw = extractPosPulse(redBuffer.toDoubleArray(), greenBuffer.toDoubleArray(), blueBuffer.toDoubleArray())
        val filtered = bandpassFilter.filterSignal(posRaw)

        val startIdx = max(0, filtered.size - count)
        val result = ArrayList<Double>()
        for (i in startIdx until filtered.size) {
            result.add(filtered[i])
        }
        return result
    }

    @Synchronized
    fun computeVitalMetrics(): VitalMetrics? {
        if (redBuffer.size < 90) return null // Cần tối thiểu 3 giây tín hiệu

        val rArray = redBuffer.toDoubleArray()
        val gArray = greenBuffer.toDoubleArray()
        val bArray = blueBuffer.toDoubleArray()

        // 1. Tách mạch đập bằng POS
        val posRaw = extractPosPulse(rArray, gArray, bArray)
        val ppgSignal = bandpassFilter.filterSignal(posRaw)

        // 2. Phân tích phổ nhịp tim (0.75 - 3.5 Hz)
        val hrSpectral = fftTransformer.analyze(ppgSignal, 0.75, 3.5) ?: return null
        val hrBpm = hrSpectral.peakFrequency * 60.0

        // 3. Phân tích HRV (SDNN, RMSSD)
        val (sdnn, rmssd) = calculateHrv(ppgSignal)

        // 4. Nhịp thở (0.15 - 0.4 Hz)
        val respSignal = respirationFilter.filterSignal(posRaw)
        val respSpectral = fftTransformer.analyze(respSignal, 0.15, 0.4)
        val respBpm = (respSpectral?.peakFrequency ?: 0.25) * 60.0

        // 5. Mức độ Stress
        val normalizedRmssd = min(max(rmssd, 10.0), 100.0)
        val rawStress = 100.0 - (normalizedRmssd - 10.0) * (60.0 / 90.0) + (if (hrBpm > 85) (hrBpm - 85) * 0.5 else 0.0)
        val stressIndex = min(max(rawStress, 5.0), 95.0)

        // 6. Điểm sức sống và tuổi sinh học làn da
        val signalQuality = min(max(hrSpectral.snr / 5.0, 0.2), 1.0)
        val skinVitality = min(max(70.0 + (100.0 - stressIndex) * 0.2 + signalQuality * 10.0, 40.0), 98.0)
        val estimatedSkinAge = max(20, min(65, (28.0 + (stressIndex - 40.0) * 0.15).toInt()))

        return VitalMetrics(
            heartRateBpm = hrBpm,
            hrvSdnn = sdnn,
            hrvRmssd = rmssd,
            respirationRateBpm = respBpm,
            stressIndex = stressIndex,
            skinVitalityScore = skinVitality,
            estimatedSkinAge = estimatedSkinAge,
            signalQuality = signalQuality,
            timestamp = System.currentTimeMillis()
        )
    }

    private fun extractPosPulse(red: DoubleArray, green: DoubleArray, blue: DoubleArray): DoubleArray {
        val length = min(red.size, min(green.size, blue.size))
        if (length < windowSize) {
            val simple = DoubleArray(length)
            for (i in 0 until length) {
                simple[i] = green[i] - 0.5 * red[i]
            }
            return simple
        }

        val hSignal = DoubleArray(length)
        val overlapCount = DoubleArray(length)

        for (start in 0..(length - windowSize)) {
            val end = start + windowSize

            var sumR = 0.0
            var sumG = 0.0
            var sumB = 0.0
            for (i in start until end) {
                sumR += red[i]
                sumG += green[i]
                sumB += blue[i]
            }
            val meanR = sumR / windowSize
            val meanG = sumG / windowSize
            val meanB = sumB / windowSize

            if (meanR <= 1e-6 || meanG <= 1e-6 || meanB <= 1e-6) continue

            val s1 = DoubleArray(windowSize)
            val s2 = DoubleArray(windowSize)

            for (i in 0 until windowSize) {
                val rNorm = red[start + i] / meanR
                val gNorm = green[start + i] / meanG
                val bNorm = blue[start + i] / meanB

                s1[i] = gNorm - bNorm
                s2[i] = gNorm + bNorm - 2.0 * rNorm
            }

            val stdS1 = calculateStdDev(s1)
            val stdS2 = calculateStdDev(s2)
            val alpha = if (stdS2 > 1e-6) (stdS1 / stdS2) else 1.0

            var sumH = 0.0
            val hTemp = DoubleArray(windowSize)
            for (i in 0 until windowSize) {
                val hVal = s1[i] + alpha * s2[i]
                hTemp[i] = hVal
                sumH += hVal
            }
            val meanH = sumH / windowSize

            for (i in 0 until windowSize) {
                val targetIdx = start + i
                hSignal[targetIdx] += (hTemp[i] - meanH)
                overlapCount[targetIdx] += 1.0
            }
        }

        for (i in 0 until length) {
            if (overlapCount[i] > 0.0) {
                hSignal[i] /= overlapCount[i]
            }
        }

        return hSignal
    }

    private fun calculateHrv(signal: DoubleArray): Pair<Double, Double> {
        val peakIndices = ArrayList<Int>()
        val minPeakDistance = (sampleRate * 0.35).toInt() // 350ms tối thiểu

        for (i in 2 until signal.size - 2) {
            if (signal[i] > signal[i - 1] && signal[i] > signal[i - 2] &&
                signal[i] > signal[i + 1] && signal[i] > signal[i + 2] &&
                signal[i] > 0.0
            ) {
                if (peakIndices.isEmpty() || (i - peakIndices.last()) >= minPeakDistance) {
                    peakIndices.add(i)
                }
            }
        }

        if (peakIndices.size < 3) return Pair(42.0, 38.0)

        val rrIntervals = ArrayList<Double>()
        for (i in 0 until peakIndices.size - 1) {
            val diffMs = ((peakIndices[i + 1] - peakIndices[i]).toDouble() / sampleRate) * 1000.0
            if (diffMs in 300.0..1500.0) {
                rrIntervals.add(diffMs)
            }
        }

        if (rrIntervals.size < 2) return Pair(42.0, 38.0)

        val meanRR = rrIntervals.sum() / rrIntervals.size
        var variance = 0.0
        for (rr in rrIntervals) {
            variance += (rr - meanRR).pow(2.0)
        }
        val sdnn = sqrt(variance / (rrIntervals.size - 1))

        var sumSqDiff = 0.0
        for (i in 0 until rrIntervals.size - 1) {
            sumSqDiff += (rrIntervals[i + 1] - rrIntervals[i]).pow(2.0)
        }
        val rmssd = sqrt(sumSqDiff / (rrIntervals.size - 1))

        return Pair(min(max(sdnn, 15.0), 120.0), min(max(rmssd, 12.0), 110.0))
    }

    private fun calculateStdDev(array: DoubleArray): Double {
        if (array.size <= 1) return 0.0
        val mean = array.sum() / array.size
        var variance = 0.0
        for (x in array) {
            variance += (x - mean).pow(2.0)
        }
        return sqrt(max(0.0, variance / (array.size - 1)))
    }

    @Synchronized
    fun reset() {
        redBuffer.clear()
        greenBuffer.clear()
        blueBuffer.clear()
        timestamps.clear()
        bandpassFilter.reset()
        respirationFilter.reset()
    }
}
