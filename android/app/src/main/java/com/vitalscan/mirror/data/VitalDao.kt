package com.vitalscan.mirror.data

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Delete
import kotlinx.coroutines.flow.Flow

@Dao
interface VitalDao {
    @Query("SELECT * FROM vital_records ORDER BY timestamp DESC")
    fun getAllRecords(): Flow<List<VitalRecordEntity>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertRecord(record: VitalRecordEntity): Long

    @Delete
    suspend fun deleteRecord(record: VitalRecordEntity)

    @Query("DELETE FROM vital_records")
    suspend fun clearAll()
}
