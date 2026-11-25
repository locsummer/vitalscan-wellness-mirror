import SwiftUI

/// Màn hình Lịch sử & Xu hướng Sinh trắc học (History & Trends)
public struct HistoryTrendView: View {
    @StateObject private var viewModel = HistoryViewModel()
    @Environment(\.dismiss) private var dismiss

    public init() {}

    public var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.05, green: 0.07, blue: 0.12)
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    // Thẻ thống kê trung bình
                    summaryAveragesHeader
                        .padding(.horizontal)
                        .padding(.top, 8)

                    // Danh sách các lần đo trước đây
                    if viewModel.historyList.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 48))
                                .foregroundColor(.gray.opacity(0.4))
                            Text("Chưa có dữ liệu đo nào")
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    } else {
                        List {
                            ForEach(viewModel.historyList) { item in
                                historyRow(item: item)
                                    .listRowBackground(Color(red: 0.09, green: 0.12, blue: 0.20))
                                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            }
                            .onDelete(perform: viewModel.deleteItem)
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Lịch sử Sinh trắc")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Đóng") {
                        dismiss()
                    }
                    .foregroundColor(.cyan)
                }
            }
        }
        .onAppear {
            viewModel.loadData()
        }
    }

    private var summaryAveragesHeader: some View {
        HStack(spacing: 12) {
            averageStatBox(title: "Trung bình HR", value: "\(viewModel.averageHR.safeInt)", unit: "BPM", color: .red)
            averageStatBox(title: "Trung bình HRV", value: "\(viewModel.averageHRV.safeInt)", unit: "ms", color: .purple)
            averageStatBox(title: "Chỉ số Stress", value: "\(viewModel.averageStress.safeInt)", unit: "/100", color: .orange)
        }
    }

    private func averageStatBox(title: String, value: String, unit: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(.gray)
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(color)
                Text(unit)
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(red: 0.09, green: 0.12, blue: 0.20))
        )
    }

    private func historyRow(item: ScanHistoryItem) -> some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.date, style: .date)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                Text(item.date, style: .time)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }

            Spacer()

            HStack(spacing: 16) {
                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 3) {
                        Image(systemName: "heart.fill").font(.system(size: 10)).foregroundColor(.red)
                        Text("\(item.heartRate.safeInt)").font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                    }
                    Text("BPM").font(.system(size: 9)).foregroundColor(.gray)
                }

                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 3) {
                        Image(systemName: "sparkles").font(.system(size: 10)).foregroundColor(.yellow)
                        Text("\(item.skinAge)t").font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                    }
                    Text("Tuổi da").font(.system(size: 9)).foregroundColor(.gray)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
