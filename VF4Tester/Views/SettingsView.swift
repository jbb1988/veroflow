import SwiftUI

struct SettingsView: View {
    typealias Appearance = TestViewModel.AppearanceOption

    @EnvironmentObject private var viewModel: TestViewModel
    @AppStorage("showMeterMfgInput") var showMeterMfgInput: Bool = true
    @AppStorage("showMeterModelInput") var showMeterModelInput: Bool = true
    @AppStorage("defaultMeterManufacturer") var defaultMeterManufacturer: String = "Neptune"
    @State private var selectedUnit = VolumeUnit.gallons
    @AppStorage("showOnboarding") var showOnboarding: Bool = true {
        didSet {
            if showOnboarding {
                NotificationCenter.default.post(name: NSNotification.Name("RestartApp"), object: nil)
            }
        }
    }

    let manufacturerOptions = [
        "Neptune",
        "Sensus",
        "Badger",
        "Master Meter",
        "Mueller",
        "Elster",
        "Zenner",
        "Hersey",
        "Kamstrup",
        "Other"
    ]

    @State private var showingMeterTolerances = false

    var body: some View {
        ZStack {
            // Background gradient + weave pattern
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "001830"),
                    Color(hex: "000C18")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay(WeavePattern())
            .ignoresSafeArea()

            // Main list content (no extra NavigationView)
            List {
                // Volume Settings
                Section {
                    Picker("Volume Unit", selection: $viewModel.configuration.preferredVolumeUnit) {
                        ForEach(VolumeUnit.allCases) { unit in
                            HStack {
                                Image(systemName: unit == .gallons ? "drop.fill" : "cylinder.fill")
                                    .foregroundColor(.blue)
                                    .symbolRenderingMode(.hierarchical)
                                Text(unit.rawValue)
                            }
                            .tag(unit)
                        }
                    }
                } header: {
                    HStack {
                        Image(systemName: "cylinder.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 20))
                        Text("Volume")
                            .textCase(nil)
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                }

                // Default Meter Settings
                Section {
                    Picker("Default Manufacturer", selection: $defaultMeterManufacturer) {
                        ForEach(manufacturerOptions, id: \.self) { manufacturer in
                            Text(manufacturer).tag(manufacturer)
                        }
                    }
                    .onChange(of: defaultMeterManufacturer) { newValue in
                        viewModel.configuration.defaultMeterManufacturer = newValue
                    }
                } header: {
                    HStack {
                        Image(systemName: "gauge")
                            .foregroundColor(.blue)
                            .font(.system(size: 20))
                        Text("Default Meter Settings")
                            .textCase(nil)
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                }

                // Test Input Options
                Section {
                    Toggle("Show Meter Manufacturer Input", isOn: $showMeterMfgInput)
                    Toggle("Show Meter Model Input", isOn: $showMeterModelInput)
                } header: {
                    HStack {
                        Image(systemName: "wrench.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 20))
                        Text("Test Input Options")
                            .textCase(nil)
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                }

                // Onboarding
                Section {
                    Toggle("Show Onboarding on Launch", isOn: $showOnboarding)
                } header: {
                    HStack {
                        Image(systemName: "person.fill.questionmark")
                            .foregroundColor(.blue)
                            .font(.system(size: 20))
                        Text("Onboarding")
                            .textCase(nil)
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                }

                // Meter Tolerances
                Section {
                    Button(action: {
                        showingMeterTolerances = true
                    }) {
                        HStack {
                            Image(systemName: "chart.bar.doc.horizontal")
                                .foregroundColor(.blue)
                            Text("Meter Tolerances")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.system(size: 14))
                        }
                    }
                } header: {
                    HStack {
                        Image(systemName: "ruler")
                            .foregroundColor(.blue)
                            .font(.system(size: 20))
                        Text("Reference")
                            .textCase(nil)
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                }
            }
            .padding(.top, 100)
            .scrollContentBackground(.hidden)  // Hide default list background
            .background(Color.clear)           // So we see the WeavePattern behind
        }
        .preferredColorScheme(.dark)
        .onAppear {
            viewModel.appearance = .dark
        }
        .sheet(isPresented: $showingMeterTolerances) {
            NavigationView {
                MeterToleranceView()
            }
        }
    }
}
