import SwiftUI
import Combine
import Foundation

class TestViewModel: ObservableObject {
    // MARK: - Test Recording Properties
    private let testResultsKey = "storedTestResults"
    private let configurationKey = "storedConfiguration"
    private let appearanceKey = "storedAppearance"
    private let selectedHistoryFilterKey = "storedHistoryFilter"
    private let hasCompletedOnboardingKey = "hasCompletedOnboarding"

    @Published var hasCompletedOnboarding = false
    @Published var currentTest: TestType = .lowFlow
    @Published var smallMeterStart: String = ""
    @Published var smallMeterEnd: String = ""
    @Published var largeMeterStart: String = ""
    @Published var largeMeterEnd: String = ""
    @Published var totalVolume: Double = 0.0
    @Published var flowRate: Double = 0.0
    @Published var notes: String = ""
    @Published var testResults: [TestResult] = [] {
        didSet {
            if let encoded = try? JSONEncoder().encode(testResults) {
                UserDefaults.standard.set(encoded, forKey: testResultsKey)
            }
        }
    }
    @Published var errorMessage: String? = nil
    @Published var isCalculatingResults: Bool = false
    @Published var showingResults: Bool = false

    // MARK: - Configuration
    struct Configuration: Codable {
        var preferredVolumeUnit: VolumeUnit = .gallons
        var defaultMeterManufacturer: String = "Neptune"
        
        func formatVolume(_ volume: Double) -> String {
            String(format: "%.1f %@", volume, preferredVolumeUnit.rawValue)
        }
    }

    @Published var configuration: Configuration = Configuration() {
        didSet {
            if let encoded = try? JSONEncoder().encode(configuration) {
                UserDefaults.standard.set(encoded, forKey: configurationKey)
            }
        }
    }

    // MARK: - History Filter
    @Published var selectedHistoryFilter: TestHistoryFilterOption = .all {
        didSet {
            UserDefaults.standard.set(selectedHistoryFilter.rawValue, forKey: selectedHistoryFilterKey)
        }
    }

    // MARK: - Appearance
    enum AppearanceOption: String, CaseIterable, Identifiable, Codable {
        case system = "System"
        case light = "Light"
        case dark = "Dark"

        var id: Self { self }

        var colorScheme: ColorScheme? {
            switch self {
            case .system: return nil
            case .light: return .light
            case .dark: return .dark
            }
        }
    }

    @Published var appearance: AppearanceOption = .system {
        didSet {
            UserDefaults.standard.set(appearance.rawValue, forKey: appearanceKey)
        }
    }

    // MARK: - Initialization & Data Loading
    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: hasCompletedOnboardingKey)
        loadData()
        
        if let defaultMfg = UserDefaults.standard.string(forKey: "defaultMeterManufacturer") {
            self.configuration.defaultMeterManufacturer = defaultMfg
        }
    }

    func loadData() {
        if let data = UserDefaults.standard.data(forKey: testResultsKey),
           let decoded = try? JSONDecoder().decode([TestResult].self, from: data) {
            testResults = decoded
        }
        if let data = UserDefaults.standard.data(forKey: configurationKey),
           let decoded = try? JSONDecoder().decode(Configuration.self, from: data) {
            configuration = decoded
        }
        if let storedAppearance = UserDefaults.standard.string(forKey: appearanceKey),
           let decodedAppearance = AppearanceOption(rawValue: storedAppearance) {
            appearance = decodedAppearance
        }
        if let storedFilter = UserDefaults.standard.string(forKey: selectedHistoryFilterKey),
           let decodedFilter = TestHistoryFilterOption(rawValue: storedFilter) {
            selectedHistoryFilter = decodedFilter
        }
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: hasCompletedOnboardingKey)
        UserDefaults.standard.synchronize()
    }

    func recordTest(_ testData: TestData) {
        let reading = MeterReading(
            smallMeterStart: Double(smallMeterStart) ?? 0,
            smallMeterEnd: Double(smallMeterEnd) ?? 0,
            largeMeterStart: Double(largeMeterStart) ?? 0,
            largeMeterEnd: Double(largeMeterEnd) ?? 0,
            totalVolume: testData.totalVolume,
            flowRate: testData.flowRate,
            readingType: .small // default for legacy usage
        )

        let result = TestResult(
            id: UUID(),
            testType: testData.testType,
            reading: reading,
            notes: testData.additionalRemarks,
            date: Date(),
            meterImageData: nil,
            meterSize: testData.meterSize.rawValue,
            meterType: testData.meterType.rawValue,
            meterModel: testData.meterModel.rawValue,
            jobNumber: testData.jobNumber
        )

        testResults.append(result)
        showingResults = true
    }

    func calculateResults(
        with image: Data?,
        meterSize: String,
        meterType: String,
        meterModel: String,
        jobNumber: String = "",
        readingType: MeterReadingType
    ) {
        let reading = MeterReading(
            smallMeterStart: Double(smallMeterStart) ?? 0,
            smallMeterEnd: Double(smallMeterEnd) ?? 0,
            largeMeterStart: Double(largeMeterStart) ?? 0,
            largeMeterEnd: Double(largeMeterEnd) ?? 0,
            totalVolume: totalVolume,
            flowRate: flowRate,
            readingType: readingType
        )

        let result = TestResult(
            id: UUID(),
            testType: currentTest,
            reading: reading,
            notes: notes,
            date: Date(),
            meterImageData: image,
            meterSize: meterSize,
            meterType: meterType,
            meterModel: meterModel,
            jobNumber: jobNumber
        )

        testResults.append(result)
        showingResults = true
    }

    func deleteTest(at indexSet: IndexSet) {
        testResults.remove(atOffsets: indexSet)
    }
}

