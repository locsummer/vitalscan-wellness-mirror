package com.vitalscan.mirror.ui

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.StrokeJoin
import androidx.compose.ui.graphics.drawscope.Stroke
import com.vitalscan.mirror.ui.theme.NeonCyan
import com.vitalscan.mirror.ui.theme.NeonGreen

@Composable
fun RealtimePpgGraph(
    waveform: List<Double>,
    isMeasuring: Boolean,
    modifier: Modifier = Modifier
) {
    Canvas(modifier = modifier.fillMaxSize()) {
        val width = size.width
        val height = size.height
        val midY = height / 2f

        // Đường lưới giữa
        drawLine(
            color = NeonCyan.copy(alpha = 0.15f),
            start = Offset(0f, midY),
            end = Offset(width, midY),
            strokeWidth = 2f
        )

        if (!isMeasuring || waveform.size < 2) return@Canvas

        val maxVal = waveform.maxOrNull() ?: 0.0
        val minVal = waveform.minOrNull() ?: 0.0
        val range = (maxVal - minVal).coerceAtLeast(1e-4)

        val stepX = width / (waveform.size - 1)
        val path = Path()

        val points = waveform.mapIndexed { index, value ->
            val normalized = (value - minVal) / range
            val y = midY + (0.5f - normalized.toFloat()) * (height * 0.75f)
            val x = index * stepX
            Offset(x, y)
        }

        path.moveTo(points[0].x, points[0].y)

        for (i in 1 until points.size) {
            val prev = points[i - 1]
            val curr = points[i]
            val midPointX = (prev.x + curr.x) / 2f

            path.cubicTo(
                midPointX, prev.y,
                midPointX, curr.y,
                curr.x, curr.y
            )
        }

        drawPath(
            path = path,
            brush = Brush.horizontalGradient(
                listOf(NeonCyan.copy(alpha = 0.3f), NeonCyan, NeonGreen)
            ),
            style = Stroke(
                width = 5f,
                cap = StrokeCap.Round,
                join = StrokeJoin.Round
            )
        )
    }
}
