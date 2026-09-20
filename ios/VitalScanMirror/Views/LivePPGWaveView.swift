import SwiftUI

/// Biểu đồ sóng quang học thể tích PPG (Photoplethysmography Waveform) thời gian thực
public struct LivePPGWaveView: View {
    public let waveform: [Double]
    public let isMeasuring: Bool

    public init(waveform: [Double], isMeasuring: Bool) {
        self.waveform = waveform
        self.isMeasuring = isMeasuring
    }

    public var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let points = normalizeWaveform(waveform, in: height)

            ZStack {
                // Đường nền lưới đo
                Path { path in
                    let midY = height / 2.0
                    path.move(to: CGPoint(x: 0, y: midY))
                    path.addLine(to: CGPoint(x: width, y: midY))
                }
                .stroke(Color.cyan.opacity(0.15), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))

                // Đường cong sóng PPG mượt mà (Bézier Curve)
                if isMeasuring && points.count > 1 {
                    Path { path in
                        let stepX = width / CGFloat(max(points.count - 1, 1))
                        path.move(to: CGPoint(x: 0, y: points[0]))

                        for i in 1..<points.count {
                            let currentX = CGFloat(i) * stepX
                            let prevX = CGFloat(i - 1) * stepX
                            let midX = (prevX + currentX) / 2.0
                            let prevY = points[i - 1]
                            let currentY = points[i]

                            path.addCurve(
                                to: CGPoint(x: currentX, y: currentY),
                                control1: CGPoint(x: midX, y: prevY),
                                control2: CGPoint(x: midX, y: currentY)
                            )
                        }
                    }
                    .stroke(
                        LinearGradient(
                            colors: [Color.cyan.opacity(0.3), Color.cyan, Color.green],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round)
                    )
                    .shadow(color: Color.cyan.opacity(0.8), radius: 4)
                }
            }
        }
    }

    private func normalizeWaveform(_ data: [Double], in height: CGFloat) -> [CGFloat] {
        guard !data.isEmpty else { return [] }
        let midY = height / 2.0
        guard let maxVal = data.max(), let minVal = data.min(), (maxVal - minVal) > 1e-4 else {
            return data.map { _ in midY }
        }

        let range = maxVal - minVal
        let usableHeight = height * 0.75

        return data.map { val in
            let normalized = (val - minVal) / range // 0.0 -> 1.0
            // Lật trục Y vì tọa độ màn hình iOS gốc ở trên cùng
            return midY + (0.5 - CGFloat(normalized)) * usableHeight
        }
    }
}
