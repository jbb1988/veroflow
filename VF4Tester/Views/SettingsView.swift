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
                // Force app to "restart" by posting a notification
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
    @State private var showCameraPermissionTest = false

    var body: some View {
        List {
            // Adjust spacing for the header
            Section {
                // Add proper safe area inset
                Color.clear
                    .frame(height: 60)
                    .listRowBackground(Color.clear)
            }
            // Volume Settings Section
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

            // Add new Default Meter Settings section
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

            // Test Input Options Section
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
            
            // Add Onboarding section
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

            // Add Meter Tolerances section
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

            // Add Camera Test section
            Section {
                Button(action: {
                    showCameraPermissionTest = true
                }) {
                    HStack {
                        Image(systemName: "camera")
                            .foregroundColor(.blue)
                        Text("Camera Test")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                    }
                }
            } header: {
                HStack {
                    Image(systemName: "camera.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 20))
                    Text("Camera Test")
                        .textCase(nil)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Image("veroflowLogo")
                    .resizable()
                    .renderingMode(.original)
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 40)
                    .padding(.vertical, 10)
            }
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
        .sheet(isPresented: $showCameraPermissionTest) {
            NavigationView {
                CameraPermissionTestView()
            }
        }
    }
}
