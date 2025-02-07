import SwiftUI
import Combine

class TestViewModel: ObservableObject {
    // MARK: - Test Recording Properties
    private let testResultsKey = "storedTestResults"
    private let configurationKey = "storedConfiguration"
    private let appearanceKey = "storedAppearance"
    private let selectedHistoryFilterKey = "storedHistoryFilter"
    
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
    @Published var configuration: Configuration = Configuration() {
        didSet {
            if let encoded = try? JSONEncoder().encode(configuration) {
                UserDefaults.standard.set(encoded, forKey: configurationKey)
            }
        }
    }
    
    // MARK: - History Filter
    @Published var selectedHistoryFilter: TestHistoryView.FilterOption = .all {
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
        loadData()
    }
    
    func loadData() {
        // Load test results
        if let data = UserDefaults.standard.data(forKey: testResultsKey),
           let decoded = try? JSONDecoder().decode([TestResult].self, from: data) {
            testResults = decoded
        }
        
        // Load configuration
        if let data = UserDefaults.standard.data(forKey: configurationKey),
           let decoded = try? JSONDecoder().decode(Configuration.self, from: data) {
            configuration = decoded
        }
        
        // Load appearance
        if let storedAppearance = UserDefaults.standard.string(forKey: appearanceKey),
           let decodedAppearance = AppearanceOption(rawValue: storedAppearance) {
            appearance = decodedAppearance
        }
        
        // Load history filter
        if let storedFilter = UserDefaults.standard.string(forKey: selectedHistoryFilterKey),
           let decodedFilter = TestHistoryView.FilterOption(rawValue: storedFilter) {
            selectedHistoryFilter = decodedFilter
        }
    }
    
    // MARK: - Test Recording
    func recordTest(_ testData: TestData) {
        let reading = MeterReading(
            smallMeterStart: Double(smallMeterStart) ?? 0,
            smallMeterEnd: Double(smallMeterEnd) ?? 0,
            largeMeterStart: Double(largeMeterStart) ?? 0,
            largeMeterEnd: Double(largeMeterEnd) ?? 0,
            totalVolume: testData.totalVolume,
            flowRate: testData.flowRate
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
            jobNumber: testData.jobNumber
        )
        
        testResults.append(result)
        showingResults = true
    }
    
    func calculateResults(with image: Data?) {
        let reading = MeterReading(
            smallMeterStart: Double(smallMeterStart) ?? 0,
            smallMeterEnd: Double(smallMeterEnd) ?? 0,
            largeMeterStart: Double(largeMeterStart) ?? 0,
            largeMeterEnd: Double(largeMeterEnd) ?? 0,
            totalVolume: totalVolume,
            flowRate: flowRate
        )
        
        let result = TestResult(
            id: UUID(),
            testType: currentTest,
            reading: reading,
            notes: notes,
            date: Date(),
            meterImageData: image,
            meterSize: "", // Add default values for new fields
            meterType: "",
            jobNumber: ""
        )
        
        testResults.append(result)
        showingResults = true
    }
    
    // MARK: - Test Management
    func deleteTest(at indexSet: IndexSet) {
        testResults.remove(atOffsets: indexSet)
    }
}
