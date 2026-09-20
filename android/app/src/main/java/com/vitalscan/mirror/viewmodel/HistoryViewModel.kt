package com.vitalscan.mirror.viewmodel

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.vitalscan.mirror.data.VitalDatabase
import com.vitalscan.mirror.data.VitalRecordEntity
import com.vitalscan.mirror.data.VitalRepository
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

class HistoryViewModel(application: Application) : AndroidViewModel(application) {

    private val repository: VitalRepository

    val historyList: StateFlow<List<VitalRecordEntity>>

    init {
        val dao = VitalDatabase.getDatabase(application).vitalDao()
        repository = VitalRepository(dao)
        historyList = repository.allRecords.stateIn(
            viewModelScope,
            SharingStarted.WhileSubscribed(5000),
            emptyList()
        )
    }

    fun deleteRecord(record: VitalRecordEntity) {
        viewModelScope.launch {
            repository.deleteRecord(record)
        }
    }

    fun clearAll() {
        viewModelScope.launch {
            repository.clearHistory()
        }
    }
}
