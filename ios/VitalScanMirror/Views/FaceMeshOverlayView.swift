import SwiftUI

/// Lớp phủ giao diện công nghệ (Cyber-Wellness HUD) với khung định vị khuôn mặt và hiệu ứng quét sinh trắc
public struct FaceMeshOverlayView: View {
    public let scanState: ScanState
    public let progress: Double
    public let roi: FaceROI?
    public let remainingSeconds: Int

    @State private var scanLineOffset: CGFloat = -150
    @State private var pulseScale: CGFloat = 1.0

    public init(scanState: ScanState, progress: Double, roi: FaceROI?, remainingSeconds: Int) {
        self.scanState = scanState
        self.progress = progress
        self.roi = roi
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
                // 1. Vùng tối xung quanh (Vignette & Mask)
                Color.black.opacity(0.4)
                    .mask(
                        ZStack {
                            Rectangle()
                            Ellipse()
                                .frame(width: ovalWidth, height: ovalHeight)
                                .blendMode(.destinationOut)
                        }
                        .compositingGroup()
                    )

                // 2. Khung Oval định vị mặt
                Ellipse()
                    .strokeBorder(
                        LinearGradient(
                            colors: isMeasuring ? [Color.cyan, Color.green, Color.cyan] : [Color.white.opacity(0.6), Color.cyan.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isMeasuring ? 3.5 : 2.0
                    )
                    .frame(width: ovalWidth, height: ovalHeight)
                    .shadow(color: isMeasuring ? Color.cyan.opacity(0.8) : Color.white.opacity(0.2), radius: 10)

                // 3. Vòng tiến trình tròn bao quanh (Progress Circle)
                if isMeasuring {
                    Ellipse()
                        .trim(from: 0.0, to: CGFloat(progress))
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [.cyan, .green, .mint, .cyan]),
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .frame(width: ovalWidth + 16, height: ovalHeight + 16)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.5), value: progress)
                }

                // 4. Tia quét Laser di chuyển lên xuống
                if isMeasuring {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.clear, .cyan.opacity(0.7), .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: ovalWidth - 20, height: 4)
                        .offset(y: scanLineOffset)
                        .onAppear {
                            withAnimation(Animation.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                                scanLineOffset = 150
                            }
                        }
                }

                // 5. Khung đánh dấu các vùng ROI (Trán & Má)
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
        case .measuring, .calibrating, .faceAligned:
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
        case .faceAligned, .calibrating:
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
            return "Đang tìm khuôn mặt... Nhìn thẳng vào camera"
        case .faceAligned:
            return "Đã phát hiện! Giữ yên để hiệu chuẩn"
        case .calibrating:
            return "Đang hiệu chuẩn độ sáng da..."
        case .measuring(_, let bpm):
            return "Đang quét mạch rPPG (\(remainingSeconds)s) • \(Int(bpm)) BPM"
        case .completed:
            return "Quét hoàn tất!"
        case .failed(let reason):
            return reason
        }
    }
}
