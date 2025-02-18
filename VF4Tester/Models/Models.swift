import Foundation

// MARK: - Test Type
enum TestType: String, Codable {
    case lowFlow = "Low Flow"
    case highFlow = "High Flow"
}

// MARK: - Meter Reading
struct MeterReading: Codable {
    var smallMeterStart: Double
    var smallMeterEnd: Double
    var largeMeterStart: Double
    var largeMeterEnd: Double
    var totalVolume: Double
    var flowRate: Double
    
    var accuracy: Double {
        let smallMeterDiff = smallMeterEnd - smallMeterStart
        let largeMeterDiff = largeMeterEnd - largeMeterStart
        let totalMeterVolume = smallMeterDiff + largeMeterDiff
        return (totalMeterVolume / totalVolume) * 100
    }
}

// MARK: - Test Result
struct TestResult: Identifiable, Codable {
    let id: UUID
    let testType: TestType
    let date: Date
    let reading: MeterReading
    var notes: String
    
    var isPassing: Bool {
        switch testType {
        case .lowFlow:
            return reading.accuracy >= 95 && reading.accuracy <= 101
        case .highFlow:
            return reading.accuracy >= 98.5 && reading.accuracy <= 101.5
        }
    }
    
    init(id: UUID = UUID(), testType: TestType, date: Date = Date(), reading: MeterReading, notes: String = "") {
        self.id = id
        self.testType = testType
        self.date = date
        self.reading = reading
        self.notes = notes
    }
}