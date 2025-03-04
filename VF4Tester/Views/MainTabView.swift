import SwiftUI

// MARK: - Main Tab View
struct MainTabView: View {
    var body: some View {
        NavigationView {
            TabView {
                TestView()
                    .tabItem { Label("Test", systemImage: "pencil.and.outline") }
                
                AnalyticsView()
                    .tabItem { Label("Analytics", systemImage: "chart.bar.xaxis") }
                
                TestHistoryView()
                    .tabItem { Label("History", systemImage: "clock") }
                
                SettingsView()
                    .tabItem { Label("Settings", systemImage: "gear") }
                
                HelpView()
                    .tabItem { Label("Help", systemImage: "questionmark.circle") }
            }
            .navigationViewStyle(.stack)
        }
    }
}

// End of file
