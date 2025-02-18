import SwiftUI

struct SettingsView: View {
    typealias Appearance = TestViewModel.AppearanceOption

    @EnvironmentObject private var viewModel: TestViewModel
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
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Image("veroflowLogo")
                    .resizable()
                    .renderingMode(.original)
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 40)
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .frame(maxHeight: 44)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            viewModel.appearance = .dark
        }
    }
}
