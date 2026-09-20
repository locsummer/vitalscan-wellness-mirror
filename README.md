# VitalScan Wellness Mirror - Native iOS & Android

Hệ thống ứng dụng đo lường và theo dõi chỉ số sinh trắc học sức khỏe không tiếp xúc (Contactless Health & Vital Signs Monitoring) qua gương mặt dựa trên công nghệ **rPPG (Remote Photoplethysmography)**.

Được phát triển **100% bằng Native Code**:
- **iOS:** Swift + SwiftUI + AVFoundation + Apple Vision Framework + Accelerate/vDSP
- **Android:** Kotlin + Jetpack Compose + CameraX + Google ML Kit Face Detection + Room Database

---

## 📸 Tính năng nổi bật (Features)

1. **Quét nhịp tim rPPG thời gian thực (Real-time rPPG Pulse Scan):**
   - Tự động nhận diện khuôn mặt và trích xuất vùng da trán (Forehead) và hai bên má (Cheeks) tại tốc độ 30 FPS.
   - Thuật toán **POS (Plane-Orthogonal-to-Skin)** loại bỏ ảnh hưởng của ánh sáng môi trường và chuyển động nhỏ.
   - Bộ lọc số Butterworth Bandpass (0.75 - 3.5 Hz) và biến đổi Fourier FFT phân tích phổ nhịp tim.
2. **Bộ chỉ số sinh trắc toàn diện (Comprehensive Biometrics):**
   - Nhịp tim tức thời & trung bình (Heart Rate: BPM).
   - Biến thiên nhịp tim (HRV: RMSSD, SDNN).
   - Nhịp thở ước tính (Respiration Rate: 9 - 24 lần/phút).
   - Mức độ căng thẳng & chỉ số phục hồi (Stress Index & Recovery).
   - Phân tích tuổi sinh học & độ tươi trẻ của làn da (Skin Bio-Age & Vitality Score).
3. **Giao diện Cyber-Wellness Mirror HUD:**
   - Khung căn chỉnh khuôn mặt với hiệu ứng quét laser, vòng tiến trình tròn động và đèn tín hiệu trạng thái.
   - Đồ thị sóng nhịp tim PPG (PPG Waveform) trực quan theo thời gian thực.
   - Thẻ báo cáo tổng quan (Wellness Report Card) phong cách Glassmorphism.
4. **Tuân thủ chính sách App Store & Google Play (Store Compliance):**
   - Màn hình Onboarding bắt buộc chấp nhận Disclaimer y tế (Health Consent).
   - Banner từ chối trách nhiệm y tế chuẩn hóa theo Apple Guideline 1.4 & Google Play Health Policy.
   - Phân tích On-device 100% — không lưu trữ hoặc tải hình ảnh khuôn mặt lên Cloud.

---

## 📂 Cấu trúc dự án (Project Structure)

```
vitalscan-wellness-mirror/
├── docs/
│   ├── RPPG_ALGORITHM_SPEC.md       # Giải thuật POS, công thức toán học & xử lý tín hiệu
│   └── STORE_COMPLIANCE_GUIDE.md   # Hướng dẫn pass kiểm duyệt App Store & Google Play
├── ios/                             # 100% Native iOS (Swift / SwiftUI)
│   └── VitalScanMirror/
│       ├── App/VitalScanApp.swift
│       ├── Core/
│       │   ├── Camera/CameraManager.swift
│       │   ├── Vision/FaceTracker.swift
│       │   └── RPPG/ (POSAlgorithm, ButterworthBandpassFilter, FFTAnalyzer, SignalProcessor)
│       ├── Models/ (VitalMetrics, ScanHistoryItem)
│       ├── ViewModels/ (MirrorScanViewModel, HistoryViewModel)
│       └── Views/ (MirrorScanView, FaceMeshOverlayView, LivePPGWaveView, ScanReportModalView, etc.)
└── android/                         # 100% Native Android (Kotlin / Jetpack Compose)
    └── app/src/main/
        ├── AndroidManifest.xml
        └── java/com/vitalscan/mirror/
            ├── camera/ (FaceRoiAnalyzer)
            ├── rppg/ (PosSignalProcessor, BandpassFilter, FftTransformer, VitalMetrics)
            ├── data/ (VitalDatabase, VitalDao, VitalRecordEntity, VitalRepository)
            ├── viewmodel/ (ScannerViewModel, HistoryViewModel)
            └── ui/ (ScannerScreen, FaceScanMeshOverlay, RealtimePpgGraph, ScanSummaryDialog, etc.)
```

---

## 🚀 Hướng dẫn Cài đặt & Khởi chạy (Getting Started)

### 1. Dành cho iOS (Xcode)
1. Mở thư mục `ios/` bằng **Xcode** (yêu cầu Xcode 15.0+ và iOS 16.0+).
2. Chọn thiết bị iPhone thật (Physical Device) hoặc Simulator có hỗ trợ camera ảo.
3. Đảm bảo Bundle Identifier và Signing Certificate đã được chọn trong Target Settings.
4. Nhấn **Run (⌘ + R)**.

### 2. Dành cho Android (Android Studio)
1. Mở thư mục `android/` bằng **Android Studio** (Hedgehog / Iguana / Jellyfish trở lên).
2. Chờ Gradle đồng bộ các thư viện (CameraX, ML Kit, Jetpack Compose, Room).
3. Kết nối thiết bị Android thật (hỗ trợ Android 7.0 / API 24 trở lên) và nhấn **Run (Shift + F10)**.

---

## 📑 Tài liệu tham khảo & Đặc tả
- Xem chi tiết thuật toán trong [docs/RPPG_ALGORITHM_SPEC.md](file:///d:/vitalscan-wellness-mirror/docs/RPPG_ALGORITHM_SPEC.md).
- Xem hướng dẫn kiểm duyệt kho ứng dụng trong [docs/STORE_COMPLIANCE_GUIDE.md](file:///d:/vitalscan-wellness-mirror/docs/STORE_COMPLIANCE_GUIDE.md).
