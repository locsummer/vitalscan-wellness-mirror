package com.vitalscan.mirror.data

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "vital_records")
data class VitalRecordEntity(
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0,
    val timestamp: Long,
    val heartRate: Double,
    val hrvRmssd: Double,
    val hrvSdnn: Double,
    val respirationRate: Double,
    val stressIndex: Double,
    val skinVitality: Double,
    val skinAge: Int
)
