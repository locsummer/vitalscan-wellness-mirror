import Foundation

public struct ScanHistoryItem: Identifiable, Codable {
    public let id: UUID
    public let date: Date
    public let heartRate: Double
    public let hrv: Double
    public let respirationRate: Double
    public let stressIndex: Double
    public let skinVitality: Double
    public let skinAge: Int
    public let notes: String?

    public init(
        id: UUID = UUID(),
        date: Date = Date(),
        heartRate: Double,
        hrv: Double,
        respirationRate: Double,
        stressIndex: Double,
        skinVitality: Double,
        skinAge: Int,
        notes: String? = nil
    ) {
        self.id = id
        self.date = date
        self.heartRate = heartRate
        self.hrv = hrv
        self.respirationRate = respirationRate
        self.stressIndex = stressIndex
        self.skinVitality = skinVitality
        self.skinAge = skinAge
        self.notes = notes
    }
}
