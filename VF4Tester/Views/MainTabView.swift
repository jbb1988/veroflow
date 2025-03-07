import SwiftUI

// MARK: - Main Tab View
struct MainTabView: View {
    @StateObject private var navigationState = NavigationStateManager()

    var body: some View {
        TabView(selection: $navigationState.selectedTab) {
            NavigationView {
                TestView()
                    .environmentObject(TestViewModel())
            }
            .tabItem {
                Image(systemName: "pencil.and.outline")
                Text("Test")
            }
            .tag(NavigationItem.test)

            NavigationView {
                AnalyticsView()
            }
            .tabItem {
                Image(systemName: "chart.bar.xaxis")
                Text("Analytics")
            }
            .tag(NavigationItem.analytics)

            NavigationView {
                TestHistoryView()
            }
            .tabItem {
                Image(systemName: "clock")
                Text("History")
            }
            .tag(NavigationItem.history)

            NavigationView {
                SettingsView()
            }
            .tabItem {
                Image(systemName: "gear")
                Text("Settings")
            }
            .tag(NavigationItem.settings)

            NavigationView {
                HelpView()
            }
            .tabItem {
                Image(systemName: "questionmark.circle")
                Text("Help")
            }
            .tag(NavigationItem.help)
        }
        .navigationViewStyle(.stack)
        .edgesIgnoringSafeArea(.all) // completely removes edge gaps
    }
}

// End of file
