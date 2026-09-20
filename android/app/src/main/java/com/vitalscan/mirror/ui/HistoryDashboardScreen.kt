package com.vitalscan.mirror.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.vitalscan.mirror.data.VitalRecordEntity
import com.vitalscan.mirror.ui.theme.*
import java.text.SimpleDateFormat
import java.util.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HistoryDashboardScreen(
    historyList: List<VitalRecordEntity>,
    onDeleteRecord: (VitalRecordEntity) -> Unit,
    onBack: () -> Unit
) {
    val avgHr = if (historyList.isNotEmpty()) historyList.map { it.heartRate }.average().toInt() else 0
    val avgHrv = if (historyList.isNotEmpty()) historyList.map { it.hrvRmssd }.average().toInt() else 0
    val avgStress = if (historyList.isNotEmpty()) historyList.map { it.stressIndex }.average().toInt() else 0

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Lịch sử Sinh trắc", color = TextPrimary, fontSize = 18.sp, fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(imageVector = Icons.Default.ArrowBack, contentDescription = "Back", tint = TextPrimary)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = DarkBackground)
            )
        },
        containerColor = DarkBackground
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Summary Header
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                StatCard(modifier = Modifier.weight(1f), title = "Trung bình HR", value = "$avgHr", unit = "BPM", color = AccentRed)
                StatCard(modifier = Modifier.weight(1f), title = "Trung bình HRV", value = "$avgHrv", unit = "ms", color = AccentPurple)
                StatCard(modifier = Modifier.weight(1f), title = "Chỉ số Stress", value = "$avgStress", unit = "/100", color = AccentOrange)
            }

            if (historyList.isEmpty()) {
                Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(8.dp)) {
                        Icon(imageVector = Icons.Default.Assessment, contentDescription = null, tint = TextSecondary, modifier = Modifier.size(48.dp))
                        Text(text = "Chưa có dữ liệu đo nào", color = TextSecondary, fontSize = 14.sp)
                    }
                }
            } else {
                LazyColumn(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                    items(historyList, key = { it.id }) { record ->
                        HistoryItemCard(record = record, onDelete = { onDeleteRecord(record) })
                    }
                }
            }
        }
    }
}

@Composable
private fun StatCard(modifier: Modifier = Modifier, title: String, value: String, unit: String, color: Color) {
    Column(
        modifier = modifier
            .background(CardBackground, shape = RoundedCornerShape(14.dp))
            .padding(12.dp)
    ) {
        Text(text = title, color = TextSecondary, fontSize = 11.sp)
        Row(verticalAlignment = Alignment.Bottom, horizontalArrangement = Arrangement.spacedBy(2.dp)) {
            Text(text = value, color = color, fontSize = 20.sp, fontWeight = FontWeight.Bold)
            Text(text = unit, color = TextSecondary, fontSize = 10.sp)
        }
    }
}

@Composable
private fun HistoryItemCard(record: VitalRecordEntity, onDelete: () -> Unit) {
    val sdf = SimpleDateFormat("dd/MM/yyyy • HH:mm", Locale.getDefault())
    val dateStr = sdf.format(Date(record.timestamp))

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .background(CardBackground, shape = RoundedCornerShape(16.dp))
            .padding(14.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
            Text(text = dateStr, color = TextPrimary, fontSize = 13.sp, fontWeight = FontWeight.SemiBold)
            Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                    Icon(imageVector = Icons.Default.Favorite, contentDescription = null, tint = AccentRed, modifier = Modifier.size(12.dp))
                    Text(text = "${record.heartRate.toInt()} BPM", color = TextSecondary, fontSize = 12.sp)
                }
                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                    Icon(imageVector = Icons.Default.AutoAwesome, contentDescription = null, tint = AccentYellow, modifier = Modifier.size(12.dp))
                    Text(text = "${record.skinAge} tuổi da", color = TextSecondary, fontSize = 12.sp)
                }
            }
        }

        IconButton(onClick = onDelete) {
            Icon(imageVector = Icons.Default.DeleteOutline, contentDescription = "Delete", tint = TextSecondary)
        }
    }
}
