import SwiftUI

struct SettingsView: View {
    typealias Appearance = TestViewModel.AppearanceOption
    
    @EnvironmentObject private var viewModel: TestViewModel
    @State private var selectedUnit = VolumeUnit.gallons
    
    var body: some View {
        let _ = Self._printChanges()
        NavigationStack {
            List {
                // Volume Settings Section
                Section(header: Text("Volume Settings")) {
                    Picker("Volume Unit", selection: $viewModel.configuration.preferredVolumeUnit) {
                        ForEach(VolumeUnit.allCases) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }
                    .pickerStyle(.inline)
                }
                
                // Appearance Section
                Section(header: Text("Theme")) {
                    Picker("Theme", selection: $viewModel.appearance) {
                        ForEach([
                            Appearance.system,
                            .light,
                            .dark
                        ], id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.inline)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(TestViewModel())
    }
}
