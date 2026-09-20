package com.vitalscan.mirror.data

import com.vitalscan.mirror.rppg.VitalMetrics
import kotlinx.coroutines.flow.Flow

class VitalRepository(private val vitalDao: VitalDao) {

    val allRecords: Flow<List<VitalRecordEntity>> = vitalDao.getAllRecords()

    suspend fun saveMetrics(metrics: VitalMetrics) {
        val entity = VitalRecordEntity(
            timestamp = metrics.timestamp,
            heartRate = metrics.heartRateBpm,
            hrvRmssd = metrics.hrvRmssd,
            hrvSdnn = metrics.hrvSdnn,
            respirationRate = metrics.respirationRateBpm,
            stressIndex = metrics.stressIndex,
            skinVitality = metrics.skinVitalityScore,
            skinAge = metrics.estimatedSkinAge
        )
        vitalDao.insertRecord(entity)
    }

    suspend fun deleteRecord(record: VitalRecordEntity) {
        vitalDao.deleteRecord(record)
    }

    suspend fun clearHistory() {
        vitalDao.clearAll()
    }
}
