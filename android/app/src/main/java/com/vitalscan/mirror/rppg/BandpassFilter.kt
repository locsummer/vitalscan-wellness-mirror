package com.vitalscan.mirror.rppg

import kotlin.math.cos
import kotlin.math.sin
import kotlin.math.sqrt

/**
 * Bộ lọc dải thông kỹ thuật số Butterworth (Digital IIR Butterworth Bandpass Filter)
 * Mặc định: fs = 30 Hz, dải thông 0.75 Hz – 3.5 Hz (45 - 210 BPM)
 */
class BandpassFilter(
    private val sampleRate: Double = 30.0,
    private val lowCutoff: Double = 0.75,
    private val highCutoff: Double = 3.5
) {
    private var b0: Double = 0.0
    private var b1: Double = 0.0
    private var b2: Double = 0.0
    private var a1: Double = 0.0
    private var a2: Double = 0.0

    private var x1: Double = 0.0
    private var x2: Double = 0.0
    private var y1: Double = 0.0
    private var y2: Double = 0.0

    init {
        calculateCoefficients()
    }

    private fun calculateCoefficients() {
        val centerFreq = sqrt(lowCutoff * highCutoff)
        val bandwidth = highCutoff - lowCutoff
        val omega = 2.0 * Math.PI * centerFreq / sampleRate
        val q = centerFreq / bandwidth
        val alpha = sin(omega) / (2.0 * q)

        val a0 = 1.0 + alpha
        b0 = alpha / a0
        b1 = 0.0
        b2 = -alpha / a0
        a1 = (-2.0 * cos(omega)) / a0
        a2 = (1.0 - alpha) / a0
    }

    fun filterSample(x: Double): Double {
        val y = b0 * x + b1 * x1 + b2 * x2 - a1 * y1 - a2 * y2
        x2 = x1
        x1 = x
        y2 = y1
        y1 = y
        return y
    }

    /**
     * Lọc hai chiều thuận nghịch (Zero-Phase Forward-Backward Filter) để triệt tiêu độ lệch pha
     */
    fun filterSignal(signal: DoubleArray): DoubleArray {
        if (signal.size < 4) return signal

        val forward = DoubleArray(signal.size)
        reset()
        for (i in signal.indices) {
            forward[i] = filterSample(signal[i])
        }

        val backward = DoubleArray(signal.size)
        reset()
        for (i in signal.indices.reversed()) {
            backward[i] = filterSample(forward[i])
        }

        return backward
    }

    fun reset() {
        x1 = 0.0
        x2 = 0.0
        y1 = 0.0
        y2 = 0.0
    }
}
