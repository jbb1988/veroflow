import SwiftUI

// MARK: - Test Types
enum TestType: String, Codable {
    case lowFlow = "Low Flow"
    case highFlow = "High Flow"
}

// MARK: - Meter Types
enum MeterSize: String, CaseIterable, Codable {
    case one = "1\""
    case oneAndHalf = "1.5\""
    case two = "2\""
    case twoAndHalf = "2.5\""
    case three = "3\""
    case four = "4\""
    case five = "5\""
    case six = "6\""
    case eight = "8\""
}

enum MeterType: String, CaseIterable, Codable {
    case neptune = "Neptune"
    case sensus = "Sensus"
    case kamstrup = "Kamstrup"
    case masterMeter = "Master Meter"
    case badger = "Badger"
    case zenner = "Zenner"
    case diehl = "Diehl"
    case other = "Other"
}

enum VolumeUnit: String, CaseIterable, Identifiable, Codable {
    case gallons = "Gallons"
    case cubicFeet = "Cubic Feet"
    
    var id: Self { self }
}

// MARK: - Test Data Structures
struct TestData {
    let totalVolume: Double
    let flowRate: Double
    let meterSize: MeterSize
    let meterType: MeterType
    let jobNumber: String
    let additionalRemarks: String
    let testType: TestType
}

struct MeterReading: Codable {
    let smallMeterStart: Double
    let smallMeterEnd: Double
    let largeMeterStart: Double
    let largeMeterEnd: Double
    let totalVolume: Double
    let flowRate: Double
    
    var accuracy: Double {
        // Calculate the total meter volume (difference between end and start readings)
        let meterVolume = smallMeterEnd - smallMeterStart
        
        // Avoid division by zero
        guard totalVolume > 0 else { return 0 }
        
        // Calculate accuracy as (meter volume / actual volume) * 100
        return (meterVolume / totalVolume) * 100.0
    }
    
    var isPassing: Bool {
        // For low flow tests (0.75-40 GPM): 95% - 101%
        // For high flow tests (25-650 GPM): 98.5% - 101.5%
        if flowRate <= 40 {
            return accuracy >= 95.0 && accuracy <= 101.0
        } else {
            return accuracy >= 98.5 && accuracy <= 101.5
        }
    }
}

struct TestResult: Identifiable, Codable {
    let id: UUID
    let testType: TestType
    let reading: MeterReading
    let notes: String
    let date: Date
    let meterImageData: Data?
    let meterSize: String
    let meterType: String
    let jobNumber: String
    
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
    // Add other configuration options as needed
}
