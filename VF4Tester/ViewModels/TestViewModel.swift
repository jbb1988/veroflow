import SwiftUI
import Combine
import CoreLocation
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
    @Published var lastTestResult: TestResult? = nil
    @Published var latitude: Double? = nil
    @Published var longitude: Double? = nil
    @Published var locationDescription: String? = nil
    private var lastGeocodedLocation: CLLocation?

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
        captureGeoLocation()
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
        // Example usage of calculateResults to show we can pass lat/long
        // You might modify or remove if your actual usage differs
        calculateResults(
            with: [],
            meterSize: testData.meterSize.rawValue,
            meterType: testData.meterType.rawValue,
            meterModel: testData.meterModel.rawValue,
            jobNumber: testData.jobNumber,
            readingType: .small,
            latitude: self.latitude,
            longitude: self.longitude
        )
    }

    private func verifyAndLogImage(_ imageData: Data?) {
        if let imageData = imageData {
            print("Image data size: \(imageData.count) bytes")
        } else {
            print("No image data provided")
        }
    }
    
    func calculateResults(
        with images: [Data],
        meterSize: String,
        meterType: String,
        meterModel: String,
        jobNumber: String = "",
        readingType: MeterReadingType,
        latitude: Double?,
        longitude: Double?
    ) {
        // Log the first image if present
        verifyAndLogImage(images.first)
        
        let reading = MeterReading(
            smallMeterStart: Double(smallMeterStart) ?? 0,
            smallMeterEnd: Double(smallMeterEnd) ?? 0,
            largeMeterStart: Double(largeMeterStart) ?? 0,
            largeMeterEnd: Double(largeMeterEnd) ?? 0,
            totalVolume: totalVolume,
            flowRate: flowRate,
            readingType: readingType
        )

        print("Creating test result with images: \(images.count)")
        let result = TestResult(
            id: UUID(),
            testType: currentTest,
            date: Date(), reading: reading,
            notes: notes,
            meterImageData: images,  // store all images
            meterSize: meterSize,
            meterType: meterType,
            meterModel: meterModel,
            jobNumber: jobNumber,
            latitude: latitude,
            longitude: longitude,
            locationDescription: locationDescription
        )

        testResults.append(result)
        lastTestResult = result
        showingResults = true
        
        // If you have cloud sync, you can store the updated results
        // e.g. CloudSyncManager.shared.saveToCloud(testResults: testResults)
    }

    func deleteTest(at indexSet: IndexSet) {
        testResults.remove(atOffsets: indexSet)
    }

    func captureGeoLocation() {
        LocationManager.shared.locationUpdateHandler = { [weak self] location in
            guard let location = location else {
                print("Failed to capture location")
                return
            }
            DispatchQueue.main.async {
                self?.latitude = location.coordinate.latitude
                self?.longitude = location.coordinate.longitude
            }
            
            // Throttle reverse geocoding: only geocode if location changed > 100 meters
            if let lastLocation = self?.lastGeocodedLocation {
                let distance = location.distance(from: lastLocation)
                if distance < 100 {
                    return
                }
            }
            self?.lastGeocodedLocation = location
            
            // Reverse geocoding to get address
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                guard error == nil, let placemark = placemarks?.first else {
                    print("Reverse geocoding failed: \(error?.localizedDescription ?? "")")
                    return
                }
                
                // Build a full address string
                let street = placemark.thoroughfare ?? ""
                let subThoroughfare = placemark.subThoroughfare ?? ""
                let city = placemark.locality ?? ""
                let state = placemark.administrativeArea ?? ""
                let postalCode = placemark.postalCode ?? ""
                let country = placemark.country ?? ""
                
                var addressComponents: [String] = []
                let streetAddress = [subThoroughfare, street].filter { !$0.isEmpty }.joined(separator: " ")
                if !streetAddress.isEmpty {
                    addressComponents.append(streetAddress)
                }
                if !city.isEmpty {
                    addressComponents.append(city)
                }
                if !state.isEmpty || !postalCode.isEmpty {
                    let stateZip = [state, postalCode].filter { !$0.isEmpty }.joined(separator: " ")
                    if !stateZip.isEmpty {
                        addressComponents.append(stateZip)
                    }
                }
                if !country.isEmpty {
                    addressComponents.append(country)
                }
                let addressString = addressComponents.joined(separator: ", ")
                
                DispatchQueue.main.async {
                    self?.locationDescription = addressString
                }
            }
        }
        LocationManager.shared.fetchCurrentLocation()
    }
}