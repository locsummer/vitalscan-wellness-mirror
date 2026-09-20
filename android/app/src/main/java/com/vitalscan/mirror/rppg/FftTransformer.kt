package com.vitalscan.mirror.rppg

import kotlin.math.*

/**
 * Triển khai Biến đổi Fourier Nhanh (Cooley-Tukey Radix-2 FFT) thuần Kotlin
 */
class FftTransformer(private val sampleRate: Double = 30.0) {

    data class SpectralResult(
        val peakFrequency: Double,
        val peakMagnitude: Double,
        val snr: Double,
        val frequencies: DoubleArray,
        val magnitudes: DoubleArray
    )

    fun analyze(signal: DoubleArray, minFreq: Double = 0.75, maxFreq: Double = 3.5): SpectralResult? {
        val n = signal.size
        if (n < 32) return null

        // Tìm lũy thừa của 2 lớn hơn hoặc bằng n (Zero-padding)
        var fftSize = 1
        while (fftSize < n) {
            fftSize = fftSize shl 1
        }

        val real = DoubleArray(fftSize)
        val imag = DoubleArray(fftSize)

        // Áp dụng cửa sổ Hanning (Hanning Window)
        for (i in 0 until n) {
            val window = 0.5 * (1.0 - cos(2.0 * Math.PI * i / (n - 1)))
            real[i] = signal[i] * window
        }

        // Biến đổi FFT
        fft(real, imag)

        // Tính biên độ phổ (Magnitudes)
        val halfSize = fftSize / 2
        val magnitudes = DoubleArray(halfSize)
        val frequencies = DoubleArray(halfSize)
        val freqResolution = sampleRate / fftSize

        for (i in 0 until halfSize) {
            magnitudes[i] = sqrt(real[i] * real[i] + imag[i] * imag[i])
            frequencies[i] = i * freqResolution
        }

        // Tìm đỉnh tần số cực đại trong dải [minFreq, maxFreq]
        var peakFreq = 0.0
        var maxMag = 0.0
        var peakIdx = -1
        var totalInBandEnergy = 0.0

        for (i in 0 until halfSize) {
            val f = frequencies[i]
            if (f in minFreq..maxFreq) {
                totalInBandEnergy += magnitudes[i]
                if (magnitudes[i] > maxMag) {
                    maxMag = magnitudes[i]
                    peakFreq = f
                    peakIdx = i
                }
            }
        }

        if (peakIdx < 0 || maxMag <= 0.0) return null

        val noiseFloor = (totalInBandEnergy - maxMag) / max(1, halfSize / 4)
        val snr = if (noiseFloor > 1e-6) (maxMag / noiseFloor) else 1.0

        return SpectralResult(
            peakFrequency = peakFreq,
            peakMagnitude = maxMag,
            snr = snr,
            frequencies = frequencies,
            magnitudes = magnitudes
        )
    }

    private fun fft(real: DoubleArray, imag: DoubleArray) {
        val n = real.size
        if (n <= 1) return

        // Bit-reversal permutation
        var j = 0
        for (i in 0 until n - 1) {
            if (i < j) {
                val tempR = real[i]
                real[i] = real[j]
                real[j] = tempR

                val tempI = imag[i]
                imag[i] = imag[j]
                imag[j] = tempI
            }
            var k = n shr 1
            while (k <= j) {
                j -= k
                k = k shr 1
            }
            j += k
        }

        // Cooley-Tukey Computation
        var len = 2
        while (len <= n) {
            val halfLen = len / 2
            val angle = -2.0 * Math.PI / len
            val wStepR = cos(angle)
            val wStepI = sin(angle)

            var i = 0
            while (i < n) {
                var wR = 1.0
                var wI = 0.0
                for (k in 0 until halfLen) {
                    val uR = real[i + k]
                    val uI = imag[i + k]
                    val vR = real[i + k + halfLen] * wR - imag[i + k + halfLen] * wI
                    val vI = real[i + k + halfLen] * wI + imag[i + k + halfLen] * wR

                    real[i + k] = uR + vR
                    imag[i + k] = uI + vI
                    real[i + k + halfLen] = uR - vR
                    imag[i + k + halfLen] = uI - vI

                    val nextWR = wR * wStepR - wI * wStepI
                    val nextWI = wR * wStepI + wI * wStepR
                    wR = nextWR
                    wI = nextWI
                }
                i += len
            }
            len = len shl 1
        }
    }
}
