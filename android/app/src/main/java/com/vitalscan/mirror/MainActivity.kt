package com.vitalscan.mirror

import android.Manifest
import android.content.pm.PackageManager
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.viewModels
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Surface
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.core.content.ContextCompat
import com.vitalscan.mirror.ui.HistoryDashboardScreen
import com.vitalscan.mirror.ui.ScannerScreen
import com.vitalscan.mirror.ui.theme.DarkBackground
import com.vitalscan.mirror.ui.theme.VitalScanTheme
import com.vitalscan.mirror.viewmodel.HistoryViewModel
import com.vitalscan.mirror.viewmodel.ScannerViewModel

class MainActivity : ComponentActivity() {

    private val scannerViewModel: ScannerViewModel by viewModels()
    private val historyViewModel: HistoryViewModel by viewModels()

    private var hasCameraPermission by mutableStateOf(false)

    private val requestPermissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { isGranted: Boolean ->
        hasCameraPermission = isGranted
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        checkCameraPermission()

        setContent {
            VitalScanTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = DarkBackground
                ) {
                    var currentScreen by remember { mutableStateOf<Screen>(Screen.Scanner) }

                    if (hasCameraPermission) {
                        when (currentScreen) {
                            Screen.Scanner -> {
                                ScannerScreen(
                                    viewModel = scannerViewModel,
                                    onOpenHistory = { currentScreen = Screen.History }
                                )
                            }
                            Screen.History -> {
                                val historyList by historyViewModel.historyList.collectAsState()
                                HistoryDashboardScreen(
                                    historyList = historyList,
                                    onDeleteRecord = { historyViewModel.deleteRecord(it) },
                                    onBack = { currentScreen = Screen.Scanner }
                                )
                            }
                        }
                    }
                }
            }
        }
    }

    private fun checkCameraPermission() {
        when {
            ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.CAMERA
            ) == PackageManager.PERMISSION_GRANTED -> {
                hasCameraPermission = true
            }
            else -> {
                requestPermissionLauncher.launch(Manifest.permission.CAMERA)
            }
        }
    }

    enum class Screen {
        Scanner,
        History
    }
}
