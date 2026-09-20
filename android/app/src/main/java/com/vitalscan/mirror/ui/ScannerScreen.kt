package com.vitalscan.mirror.ui

import android.view.ViewGroup
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.Preview
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalLifecycleOwner
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.core.content.ContextCompat
import com.vitalscan.mirror.camera.FaceRoiAnalyzer
import com.vitalscan.mirror.rppg.ScannerState
import com.vitalscan.mirror.ui.theme.*
import com.vitalscan.mirror.viewmodel.ScannerViewModel
import java.util.concurrent.Executors

@Composable
fun ScannerScreen(
    viewModel: ScannerViewModel,
    onOpenHistory: () -> Unit
) {
    val context = LocalContext.current
    val lifecycleOwner = LocalLifecycleOwner.current

    val scannerState by viewModel.scannerState.collectAsState()
    val faceRoi by viewModel.faceRoi.collectAsState()
    val liveWaveform by viewModel.liveWaveform.collectAsState()
    val instantBpm by viewModel.instantBpm.collectAsState()
    val remainingSeconds by viewModel.remainingSeconds.collectAsState()
    val showDisclaimer by viewModel.showDisclaimer.collectAsState()

    val isMeasuring = scannerState is ScannerState.Measuring || scannerState is ScannerState.FaceAligned

    Box(modifier = Modifier.fillMaxSize()) {
        // 1. CameraX Preview View
        AndroidView(
            modifier = Modifier.fillMaxSize(),
            factory = { ctx ->
                val previewView = PreviewView(ctx).apply {
                    layoutParams = ViewGroup.LayoutParams(
                        ViewGroup.LayoutParams.MATCH_PARENT,
                        ViewGroup.LayoutParams.MATCH_PARENT
                    )
                    scaleType = PreviewView.ScaleType.FILL_CENTER
                }

                val cameraProviderFuture = ProcessCameraProvider.getInstance(ctx)
                cameraProviderFuture.addListener({
                    val cameraProvider = cameraProviderFuture.get()
                    val preview = Preview.Builder().build().also {
                        it.setSurfaceProvider(previewView.surfaceProvider)
                    }

                    val imageAnalyzer = ImageAnalysis.Builder()
                        .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                        .setOutputImageFormat(ImageAnalysis.OUTPUT_IMAGE_FORMAT_YUV_420_888)
                        .build()
                        .also {
                            it.setAnalyzer(Executors.newSingleThreadExecutor(), FaceRoiAnalyzer(viewModel))
                        }

                    val cameraSelector = CameraSelector.DEFAULT_FRONT_CAMERA

                    try {
                        cameraProvider.unbindAll()
                        cameraProvider.bindToLifecycle(
                            lifecycleOwner,
                            cameraSelector,
                            preview,
                            imageAnalyzer
                        )
                    } catch (exc: Exception) {
                        exc.printStackTrace()
                    }
                }, ContextCompat.getMainExecutor(ctx))

                previewView
            }
        )

        // 2. HUD Lớp phủ quét gương mặt
        FaceScanMeshOverlay(
            scannerState = scannerState,
            faceRoiData = faceRoi,
            remainingSeconds = remainingSeconds
        )

        // 3. Header Bar trên cùng
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp, vertical = 48.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            IconButton(
                onClick = onOpenHistory,
                modifier = Modifier
                    .size(44.dp)
                    .background(DarkSurface.copy(alpha = 0.8f), shape = CircleShape)
            ) {
                Icon(imageVector = Icons.Default.History, contentDescription = "History", tint = TextPrimary)
            }

            Box(
                modifier = Modifier
                    .background(DarkSurface.copy(alpha = 0.8f), shape = RoundedCornerShape(20.dp))
                    .border(1.dp, NeonCyan.copy(alpha = 0.4f), RoundedCornerShape(20.dp))
                    .padding(horizontal = 14.dp, vertical = 6.dp)
            ) {
                Text(
                    text = "VITALSCAN MIRROR",
                    color = NeonCyan,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Black,
                    fontFamily = FontFamily.Monospace,
                    letterSpacing = 2.sp
                )
            }

            IconButton(
                onClick = { /* PRO Paywall */ },
                modifier = Modifier
                    .size(44.dp)
                    .background(DarkSurface.copy(alpha = 0.8f), shape = CircleShape)
            ) {
                Icon(imageVector = Icons.Default.WorkspacePremium, contentDescription = "PRO", tint = AccentYellow)
            }
        }

        // 4. Khối điều khiển và Đồ thị sóng dưới cùng
        Column(
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .padding(bottom = 36.dp, start = 20.dp, end = 20.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            if (isMeasuring) {
                // Card hiển thị sóng PPG và nhịp tim
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .background(DarkSurface.copy(alpha = 0.85f), shape = RoundedCornerShape(18.dp))
                        .border(1.dp, NeonCyan.copy(alpha = 0.3f), RoundedCornerShape(18.dp))
                        .padding(14.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                            Icon(imageVector = Icons.Default.Favorite, contentDescription = null, tint = AccentRed)
                            Text(text = "${instantBpm.toInt()}", color = TextPrimary, fontSize = 24.sp, fontWeight = FontWeight.Bold)
                            Text(text = "BPM", color = TextSecondary, fontSize = 11.sp, fontWeight = FontWeight.Bold)
                        }
                        Text(text = "Tín hiệu rPPG Quang học", color = NeonCyan, fontSize = 11.sp)
                    }

                    RealtimePpgGraph(
                        waveform = liveWaveform,
                        isMeasuring = true,
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(55.dp)
                    )
                }
            }

            // Nút Bắt đầu / Hủy
            if (isMeasuring) {
                Button(
                    onClick = { viewModel.cancelScanning() },
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(50.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = AccentRed.copy(alpha = 0.85f)),
                    shape = RoundedCornerShape(25.dp)
                ) {
                    Text(text = "HỦY QUÉT", color = Color.White, fontWeight = FontWeight.Bold)
                }
            } else {
                Button(
                    onClick = { viewModel.startScanning() },
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(52.dp),
                    shape = RoundedCornerShape(26.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = Color.Transparent),
                    contentPadding = PaddingValues()
                ) {
                    Box(
                        modifier = Modifier
                            .fillMaxSize()
                            .background(
                                Brush.horizontalGradient(listOf(NeonCyan, NeonGreen)),
                                shape = RoundedCornerShape(26.dp)
                            ),
                        contentAlignment = Alignment.Center
                    ) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            Icon(imageVector = Icons.Default.Face, contentDescription = null, tint = Color.Black)
                            Text(
                                text = "BẮT ĐẦU QUÉT SINH TRẮC",
                                color = Color.Black,
                                fontSize = 15.sp,
                                fontWeight = FontWeight.Bold
                            )
                        }
                    }
                }
            }
        }

        // Dialogs
        if (showDisclaimer) {
            MedicalDisclaimerDialog(onAccept = { viewModel.acceptDisclaimer() })
        }

        if (scannerState is ScannerState.Completed) {
            val metrics = (scannerState as ScannerState.Completed).metrics
            ScanSummaryDialog(metrics = metrics, onClose = { viewModel.cancelScanning() })
        }
    }
}
