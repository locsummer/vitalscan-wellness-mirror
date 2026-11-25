import SwiftUI

/// Mặt nạ cắt lỗ hình Oval trung tâm bằng thuật toán Even-Odd Fill (100% Native, không phụ thuộc shader Metal, không crash)
public struct FaceMaskHoleShape: Shape {
    public let ovalWidth: CGFloat
    public let ovalHeight: CGFloat

    public init(ovalWidth: CGFloat, ovalHeight: CGFloat) {
        self.ovalWidth = ovalWidth
        self.ovalHeight = ovalHeight
    }

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        guard rect.width > 1 && rect.height > 1 else { return path }
        path.addRect(rect)
        let ovalRect = CGRect(
            x: rect.midX - ovalWidth / 2.0,
            y: rect.midY - ovalHeight / 2.0,
            width: ovalWidth,
            height: ovalHeight
        )
        path.addEllipse(in: ovalRect)
        return path
    }
}

/// Lớp phủ giao diện công nghệ (Cyber-Wellness HUD) với khung định vị khuôn mặt và hiệu ứng quét sinh trắc
public struct FaceMeshOverlayView: View {
    public let scanState: ScanState
    public let progress: Double
    public let remainingSeconds: Int

    @State private var scanLineOffset: CGFloat = -140
    @State private var pulseScale: CGFloat = 1.0

    public init(scanState: ScanState, progress: Double, remainingSeconds: Int) {
        self.scanState = scanState
        self.progress = progress
        self.remainingSeconds = remainingSeconds
    }

    public var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let ovalWidth = width * 0.72
            let ovalHeight = ovalWidth * 1.35
            let isMeasuring = isMeasuringState

            ZStack {
                // 1. Vùng tối xung quanh (Vignette & Mask cắt lỗ Oval chuẩn Even-Odd 100% ổn định)
                FaceMaskHoleShape(ovalWidth: ovalWidth, ovalHeight: ovalHeight)
                    .fill(Color.black.opacity(0.4), style: FillStyle(eoFill: true))

                // 2. Khung Oval định vị mặt cơ sở
                Ellipse()
                    .stroke(
                        LinearGradient(
                            colors: isMeasuring 
                                ? [Color.cyan.opacity(0.8), Color.green.opacity(0.6), Color.cyan.opacity(0.8)]
                                : [Color.green, Color.mint],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: isMeasuring ? 3.0 : 2.5)
                    )
                    .frame(width: ovalWidth, height: ovalHeight)
                    .shadow(color: isMeasuring ? Color.cyan.opacity(0.6) : Color.green.opacity(0.4), radius: 8)

                // 3. Vòng tiến trình đồng tâm KHỚP 100% VỚI KHUNG OVAL
                if isMeasuring {
                    // Đường ray nền (Track)
                    Ellipse()
                        .stroke(Color.white.opacity(0.15), style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .frame(width: ovalWidth + 12, height: ovalHeight + 12)

                    // Vạch tiến trình chạy từ đỉnh (12 giờ) theo chiều kim đồng hồ
                    if progress > 0.005 {
                        Ellipse()
                            .trim(from: 0.0, to: min(1.0, max(0.01, CGFloat(progress))))
                            .stroke(
                                LinearGradient(
                                    colors: [.cyan, .green, .mint, .cyan],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 6, lineCap: .round)
                            )
                            .frame(width: ovalWidth + 12, height: ovalHeight + 12)
                            .rotationEffect(.degrees(-90))
                            .shadow(color: Color.cyan.opacity(0.9), radius: 8)
                            .animation(.linear(duration: 0.3), value: progress)
                    }

                    // Badge hiển thị % tiến trình phía trên khung
                    Text("\(progress.isNaN ? 0 : Int(progress * 100))%")
                        .font(.system(size: 13, weight: .black, design: .monospaced))
                        .foregroundColor(.cyan)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.cyan.opacity(0.6), lineWidth: 1))
                        .offset(y: -ovalHeight * 0.5 - 20)
                }

                // 4. Tia quét Laser di chuyển lên xuống trong lòng khung khi đang quét
                if isMeasuring {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.clear, .cyan.opacity(0.8), .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: ovalWidth - 30, height: 3)
                        .offset(y: scanLineOffset)
                        .onAppear {
                            withAnimation(Animation.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                                scanLineOffset = ovalHeight * 0.38
                            }
                        }
                }

                // 5. Khung đánh dấu các vùng ROI da (Trán & Má)
                if isMeasuring {
                    VStack(spacing: ovalHeight * 0.28) {
                        // Vùng trán
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.cyan.opacity(0.8), style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                            .frame(width: ovalWidth * 0.45, height: ovalHeight * 0.12)
                            .overlay(Text("ROI TRÁN").font(.system(size: 8, weight: .bold)).foregroundColor(.cyan).padding(2), alignment: .topTrailing)

                        // Vùng 2 bên má
                        HStack(spacing: ovalWidth * 0.3) {
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.green.opacity(0.8), style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                                .frame(width: ovalWidth * 0.22, height: ovalHeight * 0.15)
                            
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.green.opacity(0.8), style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                                .frame(width: ovalWidth * 0.22, height: ovalHeight * 0.15)
                        }
                    }
                    .offset(y: -ovalHeight * 0.05)
                }

                // 6. Nhãn trạng thái HUD
                VStack {
                    Spacer()
                    statusBadgeView
                        .padding(.bottom, 220)
                }
            }
        }
    }

    private var isMeasuringState: Bool {
        switch scanState {
        case .measuring, .calibrating:
            return true
        default:
            return false
        }
    }

    private var statusBadgeView: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(statusColor)
                .frame(width: 10, height: 10)
                .scaleEffect(pulseScale)
                .onAppear {
                    withAnimation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                        pulseScale = 1.4
                    }
                }

            Text(statusText)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(statusColor.opacity(0.5), lineWidth: 1)
        )
    }

    private var statusColor: Color {
        switch scanState {
        case .idle:
            return .gray
        case .searchingFace:
            return .yellow
        case .faceAligned:
            return .green
        case .calibrating:
            return .cyan
        case .measuring:
            return .green
        case .completed:
            return .blue
        case .failed:
            return .red
        }
    }

    private var statusText: String {
        switch scanState {
        case .idle:
            return "Sẵn sàng quét gương mặt"
        case .searchingFace:
            return "Nhìn thẳng vào gương để quét"
        case .faceAligned:
            return "Đã khớp khuôn mặt! Nhấn nút Bắt đầu quét"
        case .calibrating:
            return "Đang hiệu chuẩn độ sáng da..."
        case .measuring(_, let bpm):
            return "Đang quét mạch rPPG (\(remainingSeconds)s) • \(bpm.safeInt) BPM"
        case .completed:
            return "Quét hoàn tất!"
        case .failed(let reason):
            return reason
        }
    }
}
