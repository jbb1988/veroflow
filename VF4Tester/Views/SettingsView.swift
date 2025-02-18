import SwiftUI

struct SettingsView: View {
    typealias Appearance = TestViewModel.AppearanceOption

    @EnvironmentObject private var viewModel: TestViewModel
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("showMeterMfgInput") var showMeterMfgInput: Bool = true
    @AppStorage("showMeterModelInput") var showMeterModelInput: Bool = true
    @State private var selectedUnit = VolumeUnit.gallons

    var body: some View {
        List {
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

            // Appearance Section
            Section {
                Toggle(isOn: $isDarkMode) {
                    HStack {
                        Image(systemName: isDarkMode ? "moon.stars.fill" : "sun.max.fill")
                            .foregroundColor(isDarkMode ? .purple : .orange)
                            .font(.system(size: 20))
                        VStack(alignment: .leading) {
                            Text("Dark Mode")
                                .font(.headline)
                            Text(isDarkMode ? "Easier on the eyes" : "Classic light theme")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onChange(of: isDarkMode) { newValue in
                    withAnimation {
                        viewModel.appearance = newValue ? .dark : .light
                    }
                }
            } header: {
                HStack {
                    Image(systemName: "paintbrush.pointed.fill")
                        .foregroundColor(.purple)
                        .font(.system(size: 20))
                    Text("Appearance")
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
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Settings")
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .onAppear {
            isDarkMode = viewModel.appearance == .dark
        }
    }
}

