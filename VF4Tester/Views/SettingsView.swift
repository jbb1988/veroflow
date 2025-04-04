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

            // Main list content
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
                    .listRowBackground(glassmorphicBackground)
                } header: {
                    sectionHeader("Volume", systemImage: "cylinder.fill")
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
                    .listRowBackground(glassmorphicBackground)
                } header: {
                    sectionHeader("Default Meter Settings", systemImage: "gauge")
                }

                // Test Input Options
                Section {
                    Toggle("Show Meter Manufacturer Input", isOn: $showMeterMfgInput)
                        .listRowBackground(glassmorphicBackground)
                    Toggle("Show Meter Model Input", isOn: $showMeterModelInput)
                        .listRowBackground(glassmorphicBackground)
                } header: {
                    sectionHeader("Test Input Options", systemImage: "wrench.fill")
                }

                // Onboarding
                Section {
                    Toggle("Show Onboarding on Launch", isOn: $showOnboarding)
                        .listRowBackground(glassmorphicBackground)
                } header: {
                    sectionHeader("Onboarding", systemImage: "person.fill.questionmark")
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
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.system(size: 14))
                        }
                    }
                    .listRowBackground(glassmorphicBackground)
                } header: {
                    sectionHeader("Reference", systemImage: "ruler")
                }
            }
            .standardContentSpacing()
            .scrollContentBackground(.hidden)
            .listStyle(InsetGroupedListStyle())
        }
        .preferredColorScheme(.dark)
        .onAppear {
            viewModel.appearance = .dark
        }
        .sheet(isPresented: $showingMeterTolerances) {
            NavigationView {
                MeterToleranceChartView()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .principal) {
                Image("veroflowLogo")
                    .resizable()
                    .renderingMode(.original)
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 80)
            }
        }
    }
    
    // MARK: - Helper Views
    private var glassmorphicBackground: some View {
        ZStack {
            Color.black.opacity(0.5)
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.2),
                    Color.blue.opacity(0.05)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .overlay(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.4),
                    Color.blue.opacity(0.1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .mask(Rectangle().stroke(lineWidth: 1))
        )
    }
    
    private func sectionHeader(_ title: String, systemImage: String) -> some View {
        HStack {
            Image(systemName: systemImage)
                .foregroundColor(.blue)
                .font(.system(size: 20))
            Text(title)
                .textCase(nil)
                .font(.headline)
                .foregroundColor(.white)
        }
        .padding(.vertical, 8)
    }
}
