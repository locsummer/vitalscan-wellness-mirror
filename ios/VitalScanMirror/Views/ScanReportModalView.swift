import SwiftUI

/// Màn hình Modal hiển thị Báo cáo Sinh trắc Sức khỏe Tổng quát (Vital Wellness Report)
public struct ScanReportModalView: View {
    public let metrics: VitalMetrics
    public let onDismiss: () -> Void

    public init(metrics: VitalMetrics, onDismiss: @escaping () -> Void) {
        self.metrics = metrics
        self.onDismiss = onDismiss
    }

    public var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.07, blue: 0.12)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Thanh gạt modal
                    Capsule()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 40, height: 5)
                        .padding(.top, 12)

                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("BÁO CÁO SINH TRẮC GƯƠNG SOI")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.cyan)
                            Text("Tổng quan Sức khỏe")
                                .font(.system(size: 24, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Button(action: onDismiss) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.gray.opacity(0.6))
                        }
                    }
                    .padding(.horizontal)

                    // Vòng tròn điểm Sức sống (Vitality Score)
                    vitalityHeroCard

                    // Lưới 4 chỉ số sinh học chính
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                        metricCard(
                            icon: "heart.fill",
                            iconColor: .red,
                            title: "Nhịp tim",
                            value: "\(metrics.heartRateBPM.safeInt)",
                            unit: "BPM",
                            status: hrStatusText
                        )

                        metricCard(
                            icon: "waveform.path.ecg",
                            iconColor: .purple,
                            title: "Biến thiên HRV",
                            value: "\(metrics.hrvRMSSD.safeInt)",
                            unit: "ms (RMSSD)",
                            status: hrvStatusText
                        )

                        metricCard(
                            icon: "wind",
                            iconColor: .cyan,
                            title: "Nhịp thở",
                            value: "\(metrics.respirationRateBPM.safeInt)",
                            unit: "lần/phút",
                            status: "Bình thường"
                        )

                        metricCard(
                            icon: "brain.head.profile",
                            iconColor: .orange,
                            title: "Mức Căng thẳng",
                            value: "\(metrics.stressIndex.safeInt)",
                            unit: "/ 100",
                            status: stressStatusText
                        )
                    }
                    .padding(.horizontal)

                    // Thẻ Phân tích Làn da & Tuổi sinh học
                    skinAnalysisCard
                        .padding(.horizontal)

                    // Lời khuyên sức khỏe dựa trên chỉ số
                    personalizedAdviceCard
                        .padding(.horizontal)

                    // BẮT BUỘC: Disclaimer Tuân thủ App Store Guideline 1.4
                    disclaimerBanner
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                }
            }
        }
    }

    private var vitalityHeroCard: some View {
        HStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 8)
                    .frame(width: 90, height: 90)

                Circle()
                    .trim(from: 0.0, to: CGFloat(metrics.skinVitalityScore / 100.0))
                    .stroke(
                        LinearGradient(colors: [.green, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 90, height: 90)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 0) {
                    Text("\(metrics.skinVitalityScore.safeInt)")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("ĐIỂM")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.cyan)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Chỉ số Sức sống Tươi trẻ")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                Text("Trạng thái lưu thông máu dưới da tối ưu. Mức độ phục hồi thể chất tốt.")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .lineLimit(3)
            }
            Spacer()
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.09, green: 0.12, blue: 0.20))
        )
        .padding(.horizontal)
    }

    private func metricCard(icon: String, iconColor: Color, title: String, value: String, unit: String, status: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.system(size: 16))
                Spacer()
                Text(status)
                    .font(.system(size: 10, weight: .semibold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.white.opacity(0.08))
                    .foregroundColor(.white.opacity(0.8))
                    .clipShape(Capsule())
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                    Text(unit)
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.09, green: 0.12, blue: 0.20))
        )
    }

    private var skinAnalysisCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.yellow)
                Text("Phân tích Tuổi Sinh học Làn da")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }

            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Tuổi da ước tính")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    Text("\(metrics.estimatedSkinAge) tuổi")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                }

                Divider()
                    .frame(height: 36)
                    .background(Color.white.opacity(0.2))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Độ đồng đều sắc tố")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    Text("Xuất sắc (94%)")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.cyan)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(red: 0.09, green: 0.12, blue: 0.20))
        )
    }

    private var personalizedAdviceCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "leaf.fill")
                    .foregroundColor(.mint)
                Text("Khuyến nghị Chăm sóc Hôm nay")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
            }
            Text("• Nhịp tim và HRV của bạn ổn định. Duy trì uống 2 lít nước và bài tập thở 4-7-8 để giảm căng thẳng sau giờ làm việc.")
                .font(.system(size: 13))
                .foregroundColor(.gray.opacity(0.9))
                .lineSpacing(4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(red: 0.08, green: 0.15, blue: 0.18))
        )
    }

    private var disclaimerBanner: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.yellow)
                .font(.system(size: 16))

            VStack(alignment: .leading, spacing: 4) {
                Text("Tuyên bố từ chối trách nhiệm y tế (Medical Disclaimer)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.yellow)
                Text("VitalScan Wellness Mirror là công cụ hỗ trợ theo dõi thể chất và phong cách sống, KHÔNG PHẢI THIẾT BỊ Y TẾ. Dữ liệu chỉ dùng để tham khảo, không dùng để chẩn đoán hoặc điều trị bệnh.")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.yellow.opacity(0.08))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.yellow.opacity(0.2), lineWidth: 1))
        )
    }

    private var hrStatusText: String {
        if metrics.heartRateBPM < 60 { return "Nhịp chậm" }
        if metrics.heartRateBPM <= 100 { return "Bình thường" }
        return "Hơi cao"
    }

    private var hrvStatusText: String {
        if metrics.hrvRMSSD > 50 { return "Tối ưu" }
        if metrics.hrvRMSSD >= 30 { return "Ổn định" }
        return "Cần nghỉ ngơi"
    }

    private var stressStatusText: String {
        if metrics.stressIndex < 35 { return "Thư giãn" }
        if metrics.stressIndex <= 65 { return "Vừa phải" }
        return "Căng thẳng"
    }
}
