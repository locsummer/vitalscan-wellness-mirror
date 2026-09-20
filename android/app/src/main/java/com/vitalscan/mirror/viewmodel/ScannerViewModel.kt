package com.vitalscan.mirror.viewmodel

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.vitalscan.mirror.camera.OnFaceRoiExtractedListener
import com.vitalscan.mirror.data.VitalDatabase
import com.vitalscan.mirror.data.VitalRepository
import com.vitalscan.mirror.rppg.*
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

class ScannerViewModel(application: Application) : AndroidViewModel(application), OnFaceRoiExtractedListener {

    private val repository: VitalRepository
    private val signalProcessor = PosSignalProcessor()

    private val _scannerState = MutableStateFlow<ScannerState>(ScannerState.Idle)
    val scannerState: StateFlow<ScannerState> = _scannerState.asStateFlow()

    private val _faceRoi = MutableStateFlow<FaceRoiData?>(null)
    val faceRoi: StateFlow<FaceRoiData?> = _faceRoi.asStateFlow()

    private val _liveWaveform = MutableStateFlow<List<Double>>(List(60) { 0.0 })
    val liveWaveform: StateFlow<List<Double>> = _liveWaveform.asStateFlow()

    private val _instantBpm = MutableStateFlow(0.0)
    val instantBpm: StateFlow<Double> = _instantBpm.asStateFlow()

    private val _remainingSeconds = MutableStateFlow(20)
    val remainingSeconds: StateFlow<Int> = _remainingSeconds.asStateFlow()

    private val _showDisclaimer = MutableStateFlow(false)
    val showDisclaimer: StateFlow<Boolean> = _showDisclaimer.asStateFlow()

    private var scanJob: Job? = null
    private var isActivelyMeasuring = false
    private val totalScanSeconds = 20

    init {
        val dao = VitalDatabase.getDatabase(application).vitalDao()
        repository = VitalRepository(dao)

        val prefs = application.getSharedPreferences("vitalscan_prefs", Application.MODE_PRIVATE)
        val agreed = prefs.getBoolean("disclaimer_agreed", false)
        if (!agreed) {
            _showDisclaimer.value = true
        }
    }

    fun acceptDisclaimer() {
        val prefs = getApplication<Application>().getSharedPreferences("vitalscan_prefs", Application.MODE_PRIVATE)
        prefs.edit().putBoolean("disclaimer_agreed", true).apply()
        _showDisclaimer.value = false
        startScanning()
    }

    fun startScanning() {
        signalProcessor.reset()
        isActivelyMeasuring = false
        _scannerState.value = ScannerState.SearchingFace
        _remainingSeconds.value = totalScanSeconds
    }

    fun cancelScanning() {
        scanJob?.cancel()
        scanJob = null
        isActivelyMeasuring = false
        _scannerState.value = ScannerState.Idle
    }

    private fun beginMeasurement() {
        if (isActivelyMeasuring) return
        isActivelyMeasuring = true
        _scannerState.value = ScannerState.Measuring(0f, 0.0)

        scanJob?.cancel()
        scanJob = viewModelScope.launch(Dispatchers.Default) {
            val startTime = System.currentTimeMillis()
            val totalMillis = totalScanSeconds * 1000L

            while (isActive) {
                delay(300)
                val elapsed = System.currentTimeMillis() - startTime
                val progress = (elapsed.toFloat() / totalMillis).coerceIn(0f, 1f)
                val remaining = maxOf(0, ((totalMillis - elapsed) / 1000).toInt())

                _remainingSeconds.value = remaining
                _liveWaveform.value = signalProcessor.getLatestFilteredWaveform(60)

                val metrics = signalProcessor.computeVitalMetrics()
                if (metrics != null) {
                    _instantBpm.value = metrics.heartRateBpm
                    _scannerState.value = ScannerState.Measuring(progress, metrics.heartRateBpm)
                }

                if (elapsed >= totalMillis) {
                    finishMeasurement()
                    break
                }
            }
        }
    }

    private suspend fun finishMeasurement() {
        isActivelyMeasuring = false
        val finalMetrics = signalProcessor.computeVitalMetrics()

        withContext(Dispatchers.Main) {
            if (finalMetrics != null) {
                _scannerState.value = ScannerState.Completed(finalMetrics)
                repository.saveMetrics(finalMetrics)
            } else {
                _scannerState.value = ScannerState.Failed("Tín hiệu chưa đủ ổn định. Vui lòng giữ yên và thử lại.")
            }
        }
    }

    override fun onFaceRoiDetected(roiData: FaceRoiData?) {
        _faceRoi.value = roiData
        if (roiData == null) {
            if (isActivelyMeasuring) {
                cancelScanning()
                _scannerState.value = ScannerState.Failed("Mất dấu khuôn mặt. Vui lòng nhìn thẳng vào camera.")
            } else if (_scannerState.value != ScannerState.Idle) {
                _scannerState.value = ScannerState.SearchingFace
            }
            return
        }

        if (!isActivelyMeasuring && roiData.isFaceWellCentered && _scannerState.value is ScannerState.SearchingFace) {
            _scannerState.value = ScannerState.FaceAligned
            beginMeasurement()
        }
    }

    override fun onRgbDataExtracted(r: Double, g: Double, b: Double, timestamp: Long) {
        signalProcessor.appendRgb(r, g, b, timestamp)
    }
}
