package com.vitalscan.mirror.ui

import androidx.compose.animation.core.*
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.PathEffect
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.vitalscan.mirror.rppg.FaceRoiData
import com.vitalscan.mirror.rppg.ScannerState
import com.vitalscan.mirror.ui.theme.*

@Composable
fun FaceScanMeshOverlay(
    scannerState: ScannerState,
    faceRoiData: FaceRoiData?,
    remainingSeconds: Int,
    modifier: Modifier = Modifier
) {
    val isMeasuring = scannerState is ScannerState.Measuring || scannerState is ScannerState.FaceAligned

    // Animation cho tia laser quét lên xuống
    val infiniteTransition = rememberInfiniteTransition(label = "laser")
    val laserOffset by infiniteTransition.animateFloat(
        initialValue = -150f,
        targetValue = 150f,
        animationSpec = infiniteRepeatable(
            animation = tween(1800, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "laser_y"
    )

    // Animation nhấp nháy đèn trạng thái
    val pulseAlpha by infiniteTransition.animateFloat(
        initialValue = 0.4f,
        targetValue = 1.0f,
        animationSpec = infiniteRepeatable(
            animation = tween(800),
            repeatMode = RepeatMode.Reverse
        ),
        label = "pulse"
    )

    Box(modifier = modifier.fillMaxSize()) {
        Canvas(modifier = Modifier.fillMaxSize()) {
            val canvasWidth = size.width
            val canvasHeight = size.height
            val ovalWidth = canvasWidth * 0.72f
            val ovalHeight = ovalWidth * 1.35f
            val centerX = canvasWidth / 2f
            val centerY = canvasHeight * 0.45f

            val ovalTopLeft = Offset(centerX - ovalWidth / 2f, centerY - ovalHeight / 2f)
            val ovalSize = Size(ovalWidth, ovalHeight)

            // 1. Khung Oval định vị mặt
            val strokeBrush = if (isMeasuring) {
                Brush.sweepGradient(listOf(NeonCyan, NeonGreen, NeonCyan))
            } else {
                Brush.linearGradient(listOf(Color.White.copy(alpha = 0.5f), NeonCyan.copy(alpha = 0.3f)))
            }

            drawOval(
                brush = strokeBrush,
                topLeft = ovalTopLeft,
                size = ovalSize,
                style = Stroke(width = if (isMeasuring) 8f else 4f)
            )

            // 2. Vòng tiến trình (Progress Arc) khi đang đo
            if (scannerState is ScannerState.Measuring) {
                val sweepAngle = scannerState.progress * 360f
                drawArc(
                    brush = Brush.sweepGradient(listOf(NeonCyan, NeonGreen, NeonCyan)),
                    startAngle = -90f,
                    sweepAngle = sweepAngle,
                    useCenter = false,
                    topLeft = Offset(ovalTopLeft.x - 12f, ovalTopLeft.y - 12f),
                    size = Size(ovalSize.width + 24f, ovalSize.height + 24f),
                    style = Stroke(width = 12f)
                )

                // 3. Tia laser quét
                val laserY = centerY + laserOffset
                drawLine(
                    brush = Brush.horizontalGradient(
                        listOf(Color.Transparent, NeonCyan.copy(alpha = 0.8f), Color.Transparent)
                    ),
                    start = Offset(centerX - ovalWidth / 2f + 20f, laserY),
                    end = Offset(centerX + ovalWidth / 2f - 20f, laserY),
                    strokeWidth = 6f
                )

                // 4. Khung ROI Trán & Má nét đứt
                val dashEffect = PathEffect.dashPathEffect(floatArrayOf(10f, 10f), 0f)
                
                // Trán
                drawRect(
                    color = NeonCyan.copy(alpha = 0.7f),
                    topLeft = Offset(centerX - ovalWidth * 0.25f, centerY - ovalHeight * 0.38f),
                    size = Size(ovalWidth * 0.5f, ovalHeight * 0.14f),
                    style = Stroke(width = 3f, pathEffect = dashEffect)
                )

                // Má trái
                drawRect(
                    color = NeonGreen.copy(alpha = 0.7f),
                    topLeft = Offset(centerX - ovalWidth * 0.40f, centerY - ovalHeight * 0.05f),
                    size = Size(ovalWidth * 0.25f, ovalHeight * 0.20f),
                    style = Stroke(width = 3f, pathEffect = dashEffect)
                )

                // Má phải
                drawRect(
                    color = NeonGreen.copy(alpha = 0.7f),
                    topLeft = Offset(centerX + ovalWidth * 0.15f, centerY - ovalHeight * 0.05f),
                    size = Size(ovalWidth * 0.25f, ovalHeight * 0.20f),
                    style = Stroke(width = 3f, pathEffect = dashEffect)
                )
            }
        }

        // Nhãn Badge trạng thái
        Box(
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .padding(bottom = 220.dp)
                .background(DarkSurface.copy(alpha = 0.85f), shape = RoundedCornerShape(24.dp))
                .border(1.dp, getStatusColor(scannerState).copy(alpha = 0.5f), RoundedCornerShape(24.dp))
                .padding(horizontal = 16.dp, vertical = 8.dp)
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Box(
                    modifier = Modifier
                        .size(10.dp)
                        .background(getStatusColor(scannerState).copy(alpha = pulseAlpha), shape = CircleShape)
                )
                Text(
                    text = getStatusText(scannerState, remainingSeconds),
                    color = TextPrimary,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.SemiBold
                )
            }
        }
    }
}

private fun getStatusColor(state: ScannerState): Color {
    return when (state) {
        is ScannerState.Idle -> TextSecondary
        is ScannerState.SearchingFace -> AccentYellow
        is ScannerState.FaceAligned -> NeonCyan
        is ScannerState.Measuring -> NeonGreen
        is ScannerState.Completed -> NeonCyan
        is ScannerState.Failed -> AccentRed
    }
}

private fun getStatusText(state: ScannerState, remainingSeconds: Int): String {
    return when (state) {
        is ScannerState.Idle -> "Sẵn sàng quét gương mặt"
        is ScannerState.SearchingFace -> "Đang tìm khuôn mặt... Nhìn thẳng vào camera"
        is ScannerState.FaceAligned -> "Đã phát hiện! Giữ yên để hiệu chuẩn"
        is ScannerState.Measuring -> "Đang quét mạch rPPG (${remainingSeconds}s) • ${state.currentBpm.toInt()} BPM"
        is ScannerState.Completed -> "Quét hoàn tất!"
        is ScannerState.Failed -> state.reason
    }
}
