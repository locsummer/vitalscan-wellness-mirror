package com.vitalscan.mirror.data

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase

@Database(entities = [VitalRecordEntity::class], version = 1, exportSchema = false)
abstract class VitalDatabase : RoomDatabase() {
    abstract fun vitalDao(): VitalDao

    companion object {
        @Volatile
        private var INSTANCE: VitalDatabase? = null

        fun getDatabase(context: Context): VitalDatabase {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    VitalDatabase::class.java,
                    "vitalscan_database"
                ).build()
                INSTANCE = instance
                instance
            }
        }
    }
}
