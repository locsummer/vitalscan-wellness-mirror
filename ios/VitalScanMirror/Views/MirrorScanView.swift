import SwiftUI
import AVFoundation

/// Định danh Sheet Modal duy nhất tránh xung đột hiển thị
enum ActiveSheet: Identifiable {
    case summary(VitalMetrics)
    case history
    case paywall

    var id: String {
        switch self {
        case .summary: return "summary"
        case .history: return "history"
        case .paywall: return "paywall"
        }
    }
}

/// Màn hình Gương soi Sức khỏe Chính (Main Mirror Scan View - Chuẩn Defensive Coding)
public struct MirrorScanView: View {
    @StateObject private var viewModel = MirrorScanViewModel()
    @State private var activeSheet: ActiveSheet? = nil

    public init() {}

    public var body: some View {
        Group {
            if viewModel.showDisclaimerConsent {
                MedicalDisclaimerSheet {
                    viewModel.acceptDisclaimer()
                }
            } else {
                mainMirrorView
            }
        }
        .sheet(item: $activeSheet) { item in
            switch item {
            case .summary(let metrics):
                ScanReportModalView(metrics: metrics) {
                    activeSheet = nil
                }
            case .history:
                HistoryTrendView()
            case .paywall:
                PaywallView()
            }
        }
        .onChange(of: viewModel.showSummaryModal) { show in
            if show, let metrics = viewModel.latestResult {
                activeSheet = .summary(metrics)
                viewModel.showSummaryModal = false
            }
        }
    }

    private var mainMirrorView: some View {
        ZStack {
            // 1. Luồng Camera nền (Live Camera Preview)
            CameraPreviewWrapper(session: viewModel.cameraManager.session)
                .ignoresSafeArea()

            // 2. Lớp phủ HUD công nghệ nhận diện và quét mặt
            FaceMeshOverlayView(
                scanState: viewModel.scanState,
                progress: viewModel.scanProgress,
                remainingSeconds: viewModel.remainingSeconds
            )
            .ignoresSafeArea()

            // 3. Giao diện điều khiển và đồ thị sóng phía trên & dưới
            VStack {
                // Top Header Bar
                HStack {
                    Button(action: { activeSheet = .history }) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }

                    Spacer()

                    Text("VITALSCAN MIRROR")
                        .font(.system(size: 15, weight: .black, design: .monospaced))
                        .tracking(2)
                        .foregroundColor(.cyan)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())

                    Spacer()

                    Button(action: { activeSheet = .paywall }) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.yellow)
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 50)

                Spacer()

                // Bottom Controls & Live Waveform Card
                VStack(spacing: 16) {
                    if isMeasuring {
                        // Card hiển thị đồ thị sóng nhịp tim và BPM tức thời
                        VStack(spacing: 8) {
                            HStack {
                                HStack(spacing: 6) {
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(.red)
                                    Text("\(viewModel.instantBPM.safeInt)")
                                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                                        .foregroundColor(.white)
                                    Text("BPM")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.gray)
                                }

                                Spacer()

                                Text("Tín hiệu rPPG Quang học")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.cyan)
                            }
                            .padding(.horizontal, 14)
                            .padding(.top, 8)

                            // Biểu đồ sóng
                            LivePPGWaveView(waveform: viewModel.liveWaveform, isMeasuring: true)
                                .frame(height: 55)
                                .padding(.horizontal, 10)
                        }
                        .background(.ultraThinMaterial)
                        .cornerRadius(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                    }

                    // Nút bấm Bắt đầu / Hủy quét
                    HStack(spacing: 20) {
                        if isMeasuring {
                            Button(action: { viewModel.cancelScanning() }) {
                                Text("HỦY QUÉT")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color.red.opacity(0.8))
                                    .cornerRadius(25)
                            }
                        } else {
                            Button(action: { viewModel.startScanning() }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "faceid")
                                        .font(.system(size: 20))
                                    Text("BẮT ĐẦU QUÉT SINH TRẮC")
                                        .font(.system(size: 15, weight: .bold))
                                }
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(
                                    LinearGradient(colors: [.cyan, .green], startPoint: .leading, endPoint: .trailing)
                                )
                                .cornerRadius(26)
                                .shadow(color: .cyan.opacity(0.4), radius: 10, x: 0, y: 5)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 36)
                }
            }
        }
        .onAppear {
            viewModel.cameraManager.start()
        }
        .onDisappear {
            viewModel.cameraManager.stop()
        }
    }

    private var isMeasuring: Bool {
        switch viewModel.scanState {
        case .measuring, .calibrating:
            return true
        default:
            return false
        }
    }
}

/// Wrapper UIKit AVCaptureVideoPreviewLayer cho SwiftUI (An toàn tuyệt đối)
struct CameraPreviewWrapper: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> CameraPreviewUIView {
        let view = CameraPreviewUIView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: CameraPreviewUIView, context: Context) {
        if uiView.previewLayer.session !== session {
            uiView.previewLayer.session = session
        }
    }
}

class CameraPreviewUIView: UIView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }

    var previewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        previewLayer.frame = bounds
        CATransaction.commit()
    }
}
