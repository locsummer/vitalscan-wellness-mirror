import SwiftUI

/// Màn hình đồng ý Điều khoản Sức khỏe & Miễn trừ Y tế (Bắt buộc cho App Store Review)
public struct MedicalDisclaimerSheet: View {
    public let onAccept: () -> Void

    public init(onAccept: @escaping () -> Void) {
        self.onAccept = onAccept
    }

    public var body: some View {
        ZStack {
            Color(red: 0.06, green: 0.08, blue: 0.14)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "cross.case.fill")
                    .font(.system(size: 54))
                    .foregroundColor(.cyan)
                    .padding(.top, 40)

                VStack(spacing: 8) {
                    Text("VitalScan Wellness Mirror")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    Text("Thông báo Quan trọng về Sức khỏe")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.cyan)
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        disclaimerPoint(
                            icon: "stethoscope",
                            title: "Không phải Thiết bị Y tế",
                            desc: "Ứng dụng chỉ phục vụ mục đích rèn luyện thể chất, theo dõi mức độ thư giãn và phong cách sống (General Wellness & Fitness). Ứng dụng không thay thế thiết bị y tế chuyên dụng."
                        )

                        disclaimerPoint(
                            icon: "cross.circle",
                            title: "Không dùng để Chẩn đoán Bệnh",
                            desc: "Các chỉ số đo qua camera gương mặt (rPPG) chỉ mang tính chất tham khảo. Không sử dụng kết quả để tự chẩn đoán, điều trị bệnh hoặc trong các tình huống cấp cứu y tế."
                        )

                        disclaimerPoint(
                            icon: "lock.shield",
                            title: "Bảo mật & Quyền riêng tư",
                            desc: "Quá trình quét khuôn mặt được tính toán hoàn toàn trực tiếp trên thiết bị (On-device Processing). Không có hình ảnh hay video khuôn mặt nào được lưu trữ hoặc gửi lên đám mây."
                        )
                    }
                    .padding(.horizontal, 24)
                }

                Button(action: onAccept) {
                    Text("Tôi Đã Hiểu & Đồng Ý")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            LinearGradient(colors: [.cyan, .green], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(26)
                        .shadow(color: .cyan.opacity(0.4), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
            }
        }
        .interactiveDismissDisabled()
    }

    private func disclaimerPoint(icon: String, title: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.cyan)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                Text(desc)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .lineSpacing(3)
            }
        }
    }
}
