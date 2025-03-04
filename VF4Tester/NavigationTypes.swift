import SwiftUI

// This will be our single source of truth for navigation
enum NavigationItem: String, CaseIterable {
    case home = "Home"
    case test = "Test"
    case analytics = "Analytics"
    case history = "History"
    case settings = "Settings"
    case help = "Help"

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .test: return "speedometer"
        case .analytics: return "chart.bar.xaxis"
        case .history: return "clock.arrow.circlepath"
        case .settings: return "gearshape.fill"
        case .help: return "questionmark.circle.fill"
        }
    }
    
    var view: some View {
        switch self {
        case .home:
            return AnyView(MainContentView()) // Changed to MainContentView since ContentView might not be the intended home view
        case .test:
            return AnyView(TestView())
        case .analytics:
            return AnyView(AnalyticsView())
        case .history:
            return AnyView(TestHistoryView())
        case .settings:
            return AnyView(SettingsView())
        case .help:
            return AnyView(HelpView())
        }
    }
}

// End of file
