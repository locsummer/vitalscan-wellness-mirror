import Foundation
import Combine
import SwiftUI

@MainActor
public final class HistoryViewModel: ObservableObject {
    @Published public var historyList: [ScanHistoryItem] = []
    @Published public var averageHR: Double = 0.0
    @Published public var averageHRV: Double = 0.0
    @Published public var averageStress: Double = 0.0

    public init() {
        loadData()
    }

    public func loadData() {
        if let data = UserDefaults.standard.data(forKey: "vitalscan_history_records"),
           let items = try? JSONDecoder().decode([ScanHistoryItem].self, from: data) {
            self.historyList = items
        } else {
            // Mẫu demo dữ liệu ban đầu
            self.historyList = [
                ScanHistoryItem(date: Date().addingTimeInterval(-86400 * 2), heartRate: 72, hrv: 45, respirationRate: 15, stressIndex: 32, skinVitality: 88, skinAge: 26),
                ScanHistoryItem(date: Date().addingTimeInterval(-86400 * 1), heartRate: 76, hrv: 38, respirationRate: 16, stressIndex: 45, skinVitality: 84, skinAge: 27),
                ScanHistoryItem(date: Date(), heartRate: 70, hrv: 52, respirationRate: 14, stressIndex: 28, skinVitality: 90, skinAge: 25)
            ]
        }
        calculateAverages()
    }

    private func calculateAverages() {
        guard !historyList.isEmpty else {
            averageHR = 0
            averageHRV = 0
            averageStress = 0
            return
        }
        let totalHR = historyList.reduce(0.0) { $0 + $1.heartRate }
        let totalHRV = historyList.reduce(0.0) { $0 + $1.hrv }
        let totalStress = historyList.reduce(0.0) { $0 + $1.stressIndex }

        let count = Double(historyList.count)
        averageHR = totalHR / count
        averageHRV = totalHRV / count
        averageStress = totalStress / count
    }

    public func deleteItem(at offsets: IndexSet) {
        historyList.remove(atOffsets: offsets)
        if let data = try? JSONEncoder().encode(historyList) {
            UserDefaults.standard.set(data, forKey: "vitalscan_history_records")
        }
        calculateAverages()
    }
}
