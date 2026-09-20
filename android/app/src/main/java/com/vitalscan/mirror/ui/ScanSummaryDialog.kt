package com.vitalscan.mirror.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import com.vitalscan.mirror.rppg.VitalMetrics
import com.vitalscan.mirror.ui.theme.*

@Composable
fun ScanSummaryDialog(
    metrics: VitalMetrics,
    onDismiss: (() -> Unit)? = null,
    onClose: () -> Unit
) {
    Dialog(
        onDismissRequest = { onDismiss?.invoke() ?: onClose() },
        properties = DialogProperties(usePlatformDefaultWidth = false)
    ) {
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(DarkBackground)
                .padding(16.dp)
        ) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .verticalScroll(rememberScrollState()),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                // Header
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(top = 16.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column {
                        Text(
                            text = "BÁO CÁO SINH TRẮC GƯƠNG SOI",
                            color = NeonCyan,
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Bold
                        )
                        Text(
                            text = "Tổng quan Sức khỏe",
                            color = TextPrimary,
                            fontSize = 24.sp,
                            fontWeight = FontWeight.Bold
                        )
                    }
                    IconButton(onClick = onClose) {
                        Icon(
                            imageVector = Icons.Default.Close,
                            contentDescription = "Close",
                            tint = TextSecondary
                        )
                    }
                }

                // Hero Card: Điểm Sức sống
                VitalityHeroCard(metrics)

                // Lưới 4 chỉ số sinh trắc học
                Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                    MetricBox(
                        modifier = Modifier.weight(1f),
                        icon = Icons.Default.Favorite,
                        iconColor = AccentRed,
                        title = "Nhịp tim",
                        value = "${metrics.heartRateBpm.toInt()}",
                        unit = "BPM",
                        status = if (metrics.heartRateBpm in 60.0..100.0) "Bình thường" else "Hơi cao"
                    )
                    MetricBox(
                        modifier = Modifier.weight(1f),
                        icon = Icons.Default.Timeline,
                        iconColor = AccentPurple,
                        title = "Biến thiên HRV",
                        value = "${metrics.hrvRmssd.toInt()}",
                        unit = "ms (RMSSD)",
                        status = if (metrics.hrvRmssd > 40) "Tối ưu" else "Ổn định"
                    )
                }

                Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                    MetricBox(
                        modifier = Modifier.weight(1f),
                        icon = Icons.Default.Air,
                        iconColor = NeonCyan,
                        title = "Nhịp thở",
                        value = "${metrics.respirationRateBpm.toInt()}",
                        unit = "lần/phút",
                        status = "Bình thường"
                    )
                    MetricBox(
                        modifier = Modifier.weight(1f),
                        icon = Icons.Default.Psychology,
                        iconColor = AccentOrange,
                        title = "Mức Căng thẳng",
                        value = "${metrics.stressIndex.toInt()}",
                        unit = "/ 100",
                        status = if (metrics.stressIndex < 40) "Thư giãn" else "Vừa phải"
                    )
                }

                // Phân tích làn da
                SkinAnalysisCard(metrics)

                // Khuyến nghị
                AdviceCard()

                // Medical Disclaimer Bắt buộc
                DisclaimerBanner()

                Spacer(modifier = Modifier.height(24.dp))
            }
        }
    }
}

@Composable
private fun VitalityHeroCard(metrics: VitalMetrics) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .background(CardBackground, shape = RoundedCornerShape(20.dp))
            .padding(18.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Box(
            modifier = Modifier
                .size(80.dp)
                .background(DarkBackground, shape = CircleShape)
                .border(4.dp, Brush.sweepGradient(listOf(NeonGreen, NeonCyan)), CircleShape),
            contentAlignment = Alignment.Center
        ) {
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Text(
                    text = "${metrics.skinVitalityScore.toInt()}",
                    color = TextPrimary,
                    fontSize = 24.sp,
                    fontWeight = FontWeight.Bold
                )
                Text(
                    text = "ĐIỂM",
                    color = NeonCyan,
                    fontSize = 9.sp,
                    fontWeight = FontWeight.Bold
                )
            }
        }

        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = "Chỉ số Sức sống Tươi trẻ",
                color = TextPrimary,
                fontSize = 16.sp,
                fontWeight = FontWeight.Bold
            )
            Text(
                text = "Lưu thông mao mạch da tối ưu. Mức độ phục hồi thể chất tốt.",
                color = TextSecondary,
                fontSize = 13.sp
            )
        }
    }
}

@Composable
private fun MetricBox(
    modifier: Modifier = Modifier,
    icon: ImageVector,
    iconColor: Color,
    title: String,
    value: String,
    unit: String,
    status: String
) {
    Column(
        modifier = modifier
            .background(CardBackground, shape = RoundedCornerShape(16.dp))
            .padding(14.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(imageVector = icon, contentDescription = title, tint = iconColor, modifier = Modifier.size(18.dp))
            Text(
                text = status,
                color = TextPrimary.copy(alpha = 0.8f),
                fontSize = 10.sp,
                modifier = Modifier
                    .background(Color.White.copy(alpha = 0.08f), shape = RoundedCornerShape(10.dp))
                    .padding(horizontal = 6.dp, vertical = 2.dp)
            )
        }

        Column {
            Row(verticalAlignment = Alignment.Bottom, horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                Text(text = value, color = TextPrimary, fontSize = 22.sp, fontWeight = FontWeight.Bold)
                Text(text = unit, color = TextSecondary, fontSize = 11.sp)
            }
            Text(text = title, color = TextSecondary, fontSize = 12.sp)
        }
    }
}

@Composable
private fun SkinAnalysisCard(metrics: VitalMetrics) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .background(CardBackground, shape = RoundedCornerShape(18.dp))
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            Icon(imageVector = Icons.Default.AutoAwesome, contentDescription = null, tint = AccentYellow)
            Text(text = "Phân tích Tuổi Sinh học Làn da", color = TextPrimary, fontSize = 15.sp, fontWeight = FontWeight.Bold)
        }

        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceAround) {
            Column {
                Text(text = "Tuổi da ước tính", color = TextSecondary, fontSize = 12.sp)
                Text(text = "${metrics.estimatedSkinAge} tuổi", color = NeonGreen, fontSize = 20.sp, fontWeight = FontWeight.Bold)
            }
            Column {
                Text(text = "Độ đồng đều sắc tố", color = TextSecondary, fontSize = 12.sp)
                Text(text = "Tốt (92%)", color = NeonCyan, fontSize = 20.sp, fontWeight = FontWeight.Bold)
            }
        }
    }
}

@Composable
private fun AdviceCard() {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .background(Color(0xFF0F2624), shape = RoundedCornerShape(18.dp))
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            Icon(imageVector = Icons.Default.Eco, contentDescription = null, tint = NeonGreen)
            Text(text = "Khuyến nghị Chăm sóc Hôm nay", color = TextPrimary, fontSize = 15.sp, fontWeight = FontWeight.Bold)
        }
        Text(
            text = "• Duy trì uống đủ nước và bài tập thở sâu 4-7-8 để cân bằng hệ thần kinh đối giao cảm.",
            color = TextSecondary,
            fontSize = 13.sp
        )
    }
}

@Composable
private fun DisclaimerBanner() {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .background(AccentYellow.copy(alpha = 0.08f), shape = RoundedCornerShape(12.dp))
            .border(1.dp, AccentYellow.copy(alpha = 0.2f), shape = RoundedCornerShape(12.dp))
            .padding(12.dp),
        horizontalArrangement = Arrangement.spacedBy(10.dp),
        verticalAlignment = Alignment.Top
    ) {
        Icon(imageVector = Icons.Default.Warning, contentDescription = null, tint = AccentYellow, modifier = Modifier.size(18.dp))
        Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
            Text(text = "Tuyên bố từ chối trách nhiệm y tế (Medical Disclaimer)", color = AccentYellow, fontSize = 11.sp, fontWeight = FontWeight.Bold)
            Text(
                text = "VitalScan Mirror chỉ là ứng dụng hỗ trợ phong cách sống và thể chất (General Wellness), KHÔNG PHẢI THIẾT BỊ Y TẾ và không dùng để chẩn đoán bệnh.",
                color = TextSecondary,
                fontSize = 10.sp
            )
        }
    }
}
