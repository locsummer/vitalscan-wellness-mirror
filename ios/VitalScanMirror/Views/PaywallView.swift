import SwiftUI

/// Màn hình Đăng ký Gói Nâng cao (In-App Purchase / Paywall)
public struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlanIndex: Int = 1
    @State private var isPurchasing: Bool = false

    public init() {}

    public var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.07, blue: 0.12)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.gray.opacity(0.7))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)

                Image(systemName: "crown.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.yellow)
                    .shadow(color: .yellow.opacity(0.5), radius: 10)

                VStack(spacing: 6) {
                    Text("VitalScan PRO Mirror")
                        .font(.system(size: 26, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                    Text("Mở khóa toàn bộ chỉ số sinh trắc học chuyên sâu")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }

                VStack(alignment: .leading, spacing: 14) {
                    featureRow(icon: "infinity", text: "Số lần quét gương mặt không giới hạn")
                    featureRow(icon: "waveform.path.ecg.rectangle", text: "Phân tích biến thiên HRV & Độ phục hồi tim mạch")
                    featureRow(icon: "face.smiling", text: "Báo cáo tuổi sinh học làn da & Độ căng bóng 3D")
                    featureRow(icon: "doc.text.below.ecg.fill", text: "Xuất file PDF báo cáo sức khỏe gửi huấn luyện viên")
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 10)

                // Các gói lựa chọn
                HStack(spacing: 14) {
                    planCard(
                        title: "Gói Tháng",
                        price: "99.000 đ",
                        period: "/ tháng",
                        badge: nil,
                        isSelected: selectedPlanIndex == 0
                    ) {
                        selectedPlanIndex = 0
                    }

                    planCard(
                        title: "Gói Năm",
                        price: "499.000 đ",
                        period: "/ năm",
                        badge: "TIẾT KIỆM 58%",
                        isSelected: selectedPlanIndex == 1
                    ) {
                        selectedPlanIndex = 1
                    }
                }
                .padding(.horizontal)

                Spacer()

                Button(action: handlePurchase) {
                    HStack {
                        if isPurchasing {
                            ProgressView()
                                .tint(.black)
                        } else {
                            Text("Bắt đầu Dùng thử 3 Ngày Miễn phí")
                                .font(.system(size: 16, weight: .bold))
                        }
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(27)
                    .shadow(color: .yellow.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .disabled(isPurchasing)
                .padding(.horizontal, 20)

                Text("Hủy bất kỳ lúc nào trong cài đặt App Store. Điều khoản & Bảo mật.")
                    .font(.system(size: 10))
                    .foregroundColor(.gray.opacity(0.7))
                    .padding(.bottom, 20)
            }
        }
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.cyan)
                .font(.system(size: 16))
                .frame(width: 24)
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
        }
    }

    private func planCard(title: String, price: String, period: String, badge: String?, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                if let badge = badge {
                    Text(badge)
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundColor(.black)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.yellow)
                        .clipShape(Capsule())
                } else {
                    Spacer().frame(height: 18)
                }

                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)

                Text(price)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(isSelected ? .yellow : .white)

                Text(period)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(red: 0.09, green: 0.12, blue: 0.20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.yellow : Color.white.opacity(0.1), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
    }

    private func handlePurchase() {
        isPurchasing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            isPurchasing = false
            dismiss()
        }
    }
}
