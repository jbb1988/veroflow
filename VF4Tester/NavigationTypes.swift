import SwiftUI


// This will be our single source of truth for navigation
enum AppNavigationItem: String, CaseIterable, Identifiable {
    case home = "Home"
    case test = "Test"
    case analytics = "Analytics"
    case history = "History"
    case products = "Product Family"
    case settings = "Settings"
    case help = "Help"

    var id: Self { self }
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .test: return "pencil.and.outline"
        case .analytics: return "chart.bar.fill"
        case .history: return "clock.fill"
        case .products: return "cube.box.fill"
        case .settings: return "gear"
        case .help: return "questionmark.circle.fill"
        }
    }
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .home: 
            HomeView()
        case .test: 
            TestView()
        case .analytics: 
            AnalyticsView()
        case .history: 
            TestHistoryView()
        case .products: 
            ProductShowcaseView()
        case .settings: 
            SettingsView()
        case .help: 
            HelpView()
        }
    }
}

// End of file
