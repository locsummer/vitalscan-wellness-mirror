package com.vitalscan.mirror.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.HealthAndSafety
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.MedicalServices
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
import com.vitalscan.mirror.ui.theme.*

@Composable
fun MedicalDisclaimerDialog(
    onAccept: () -> Unit
) {
    Dialog(
        onDismissRequest = {},
        properties = DialogProperties(dismissOnBackPress = false, dismissOnClickOutside = false, usePlatformDefaultWidth = false)
    ) {
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(DarkBackground)
                .padding(24.dp)
        ) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .verticalScroll(rememberScrollState()),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.SpaceBetween
            ) {
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(16.dp)
                ) {
                    Spacer(modifier = Modifier.height(24.dp))
                    Icon(
                        imageVector = Icons.Default.HealthAndSafety,
                        contentDescription = null,
                        tint = NeonCyan,
                        modifier = Modifier.size(56.dp)
                    )

                    Text(
                        text = "VitalScan Wellness Mirror",
                        color = TextPrimary,
                        fontSize = 22.sp,
                        fontWeight = FontWeight.Bold
                    )
                    Text(
                        text = "Thông báo Quan trọng về Sức khỏe",
                        color = NeonCyan,
                        fontSize = 15.sp,
                        fontWeight = FontWeight.SemiBold
                    )

                    Spacer(modifier = Modifier.height(8.dp))

                    DisclaimerPoint(
                        icon = Icons.Default.MedicalServices,
                        title = "Không phải Thiết bị Y tế",
                        desc = "Ứng dụng được thiết kế cho mục đích rèn luyện thể chất, theo dõi mức độ thư giãn (General Wellness & Fitness). Không thay thế thiết bị y tế chuyên dụng."
                    )

                    DisclaimerPoint(
                        icon = Icons.Default.HealthAndSafety,
                        title = "Không dùng để Chẩn đoán Bệnh",
                        desc = "Các chỉ số đo qua camera rPPG chỉ mang tính chất tham khảo. Không dùng kết quả để tự chẩn đoán, điều trị bệnh hoặc trong trường hợp cấp cứu."
                    )

                    DisclaimerPoint(
                        icon = Icons.Default.Lock,
                        title = "Bảo mật & Quyền riêng tư",
                        desc = "Toàn bộ việc phân tích quang học được xử lý trực tiếp trên thiết bị (On-Device). Không có hình ảnh hay video khuôn mặt nào được gửi lên máy chủ bên ngoài."
                    )
                }

                Button(
                    onClick = onAccept,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(52.dp)
                        .padding(top = 16.dp),
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
                        Text(
                            text = "Tôi Đã Hiểu & Đồng Ý",
                            color = Color.Black,
                            fontSize = 16.sp,
                            fontWeight = FontWeight.Bold
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun DisclaimerPoint(icon: ImageVector, title: String, desc: String) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(14.dp),
        verticalAlignment = Alignment.Top
    ) {
        Icon(imageVector = icon, contentDescription = null, tint = NeonCyan, modifier = Modifier.size(24.dp))
        Column(verticalArrangement = Arrangement.spacedBy(2.dp)) {
            Text(text = title, color = TextPrimary, fontSize = 15.sp, fontWeight = FontWeight.Bold)
            Text(text = desc, color = TextSecondary, fontSize = 13.sp, lineHeight = 18.sp)
        }
    }
}
