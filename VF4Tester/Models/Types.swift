import SwiftUI
import Foundation

// MARK: - Test Types
enum TestType: String, Codable {
    case lowFlow = "Low Flow"
    case midFlow = "Mid Flow"
    case highFlow = "High Flow"
}

// Note: The 'Field' enum is defined in SharedComponents.swift.

// MARK: - Meter Types
enum MeterSize: String, CaseIterable, Codable {
    case fiveEighth = "5/8\""
    case threeQuarter = "3/4\""
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

enum MeterModel: String, CaseIterable, Codable {
    case positiveDisplacement = "Positive Displacement"
    case singleJet = "Single-Jet"
    case multiJet = "Multi-Jet"
    case turbine = "Turbine"
    case typeI = "Type I"
    case typeII = "Type II"
    case fireservice = "Fire Service"
    case compound = "Compound"
    case electromagnetic = "Electromagnetic (Mag)"
    case ultrasonic = "Ultrasonic"
    case other = "Other"
}

enum ChartType: String, CaseIterable, Codable {
    case line = "Line"
    case area = "Area"
    case scatter = "Scatter"
}

// MARK: - Volume Units
enum VolumeUnit: String, CaseIterable, Identifiable, Codable {
    case gallons = "Gallons"
    case cubicFeet = "Cubic Feet"
    
    var id: Self { self }
}

// MARK: - MeterReadingType Enum
enum MeterReadingType: String, Codable {
    case small, large, compound
}

// MARK: - Test Data Structures
struct MeterReading: Codable {
    // Double values for calculations
    var smallMeterStart: Double
    var smallMeterEnd: Double
    var largeMeterStart: Double
    var largeMeterEnd: Double
    var totalVolume: Double
    var flowRate: Double
    var readingType: MeterReadingType
    
    // Raw string values for display
    var rawSmallMeterStart: String = ""
    var rawSmallMeterEnd: String = ""
    var rawLargeMeterStart: String = ""
    var rawLargeMeterEnd: String = ""
    var rawTotalVolume: String = ""
    var rawFlowRate: String = ""
    
    // Add cubic feet conversion constant
    private static let cubicFeetToGallons: Double = 7.48052
    
    // Updated accuracy calculation with proper unit conversion
    var accuracy: Double {
        let meterVolume: Double
        switch readingType {
        case .small:
            meterVolume = smallMeterEnd - smallMeterStart
        case .large:
            meterVolume = largeMeterEnd - largeMeterStart
        case .compound:
            meterVolume = (smallMeterEnd - smallMeterStart) + (largeMeterEnd - largeMeterStart)
        }
        guard totalVolume > 0 else { return 0 }
        
        // Convert readings to gallons if in cubic feet
        let volumeInGallons = totalVolume * MeterReading.cubicFeetToGallons
        let meterVolumeInGallons = meterVolume * MeterReading.cubicFeetToGallons
        
        return (meterVolumeInGallons / volumeInGallons) * 100.0
    }
    
    // Helper method to convert gallons to cubic feet
    func convertToGallons(_ cubicFeet: Double) -> Double {
        return cubicFeet * MeterReading.cubicFeetToGallons
    }
}

struct TestResult: Codable, Identifiable {
    let id: UUID
    let testType: TestType
    let date: Date
    let reading: MeterReading
    let notes: String
    let meterImageData: [Data]?
    let meterSize: String
    let meterType: String
    let meterModel: String
    let jobNumber: String
    let latitude: Double?
    let longitude: Double?
    let locationDescription: String?
    
    var isPassing: Bool {
        let acc = reading.accuracy
        let (minTol, maxTol): (Double, Double) = {
            switch meterModel {
            case MeterModel.positiveDisplacement.rawValue,
                 MeterModel.singleJet.rawValue:
                switch testType {
                case .lowFlow:
                    return (95.0, 101.0)
                case .midFlow, .highFlow:
                    return (98.5, 101.5)
                }
            case MeterModel.multiJet.rawValue:
                switch testType {
                case .lowFlow:
                    return (97.0, 103.0)
                case .midFlow, .highFlow:
                    return (98.5, 101.5)
                }
            case MeterModel.turbine.rawValue:
                // For Turbine
                return (98.5, 101.5)
            case MeterModel.typeI.rawValue,
                 MeterModel.typeII.rawValue,
                 MeterModel.electromagnetic.rawValue,
                 MeterModel.ultrasonic.rawValue:
                switch testType {
                case .lowFlow:
                    return (95.0, 105.0)
                case .midFlow, .highFlow:
                    return (98.5, 101.5)
                }
            case MeterModel.fireservice.rawValue:
                switch testType {
                case .lowFlow:
                    return (95.0, 101.5)
                case .midFlow, .highFlow:
                    return (98.5, 101.5)
                }
            case MeterModel.compound.rawValue:
                switch testType {
                case .lowFlow:
                    return (95.0, 101.0)
                case .midFlow:
                    return (98.5, 101.5)
                case .highFlow:
                    return (97.0, 103.0)
                }
            default:
                // Fallback ranges if meterModel doesn't match above
                switch testType {
                case .lowFlow:
                    return (95.0, 101.0)
                case .midFlow:
                    return (97.0, 101.5)
                case .highFlow:
                    return (98.5, 101.5)
                }
            }
        }()
        return acc >= minTol && acc <= maxTol
    }
}

extension TestResult: Equatable {
    static func == (lhs: TestResult, rhs: TestResult) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Configuration
struct Configuration: Codable {
    var preferredVolumeUnit: VolumeUnit = .gallons
    
    // Add conversion factor
    var gallonsToUnitFactor: Double {
        switch preferredVolumeUnit {
        case .gallons: return 1.0
        case .cubicFeet: return 0.133681  // 1 gallon = 0.133681 cubic feet
        }
    }
    
    func formatVolume(_ volumeGallons: Double) -> String {
        let convertedVolume = volumeGallons * gallonsToUnitFactor
        return String(format: "%.3f %@", convertedVolume, preferredVolumeUnit.rawValue)
    }
}

// MARK: - Error Types
struct SimpleError: Identifiable {
    let id = UUID()
    let message: String
}

// MARK: - Test History Filter Option
enum TestHistoryFilterOption: String, CaseIterable, Codable, Identifiable {
    case all = "All Tests"
    case lowFlow = "Low Flow Tests"
    case midFlow = "Mid Flow Tests"
    case highFlow = "High Flow Tests"
    case passed = "Passed Tests"
    case failing = "Failed Tests"
    
    var id: Self { self }
}

// MARK: - Test Data
struct TestData {
    var totalVolume: Double
    var flowRate: Double
    var testType: TestType
    var additionalRemarks: String
    var meterSize: MeterSize
    var meterType: MeterType
    var meterModel: MeterModel
    var jobNumber: String
}
