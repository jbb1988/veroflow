import Foundation

// MARK: - Volume Unit
enum VolumeUnit: String, CaseIterable, Codable, Identifiable {
    case gallons = "Gallons"
    case liters = "Liters"
    case cubicFeet = "Cubic Feet"
    
    var id: Self { self }
}

// MARK: - Test Type
enum TestType: String, CaseIterable, Codable {
    case lowFlow = "Low Flow"
    case highFlow = "High Flow"
}

// MARK: - Meter Reading
struct MeterReading: Codable {
    let smallMeterStart: Double
    let smallMeterEnd: Double
    let largeMeterStart: Double
    let largeMeterEnd: Double
    let totalVolume: Double
    let flowRate: Double
    
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
    let reading: MeterReading
    var notes: String
    let date: Date
    var meterImageData: Data?
    
    var isPassing: Bool {
        switch testType {
        case .lowFlow:
            return reading.accuracy >= 95 && reading.accuracy <= 101
        case .highFlow:
            return reading.accuracy >= 98.5 && reading.accuracy <= 101.5
        }
    }
}

// MARK: - Configuration
struct Configuration: Codable {
    var preferredVolumeUnit: VolumeUnit = .gallons
}
