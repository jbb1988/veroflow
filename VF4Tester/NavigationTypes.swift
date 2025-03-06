import SwiftUI

 
// This will be our single source of truth for navigation
enum NavigationItem: String, CaseIterable {
    case home = "Home"
    case test = "Test"
    case analytics = "Analytics"
    case history = "History"
    case settings = "Settings"
    case help = "Help"
    case cameraTest = "Camera Test"

    var icon: String {
        switch self {
        case .home: return "house"
        case .test: return "testtube.2"
        case .analytics: return "chart.bar"
        case .history: return "clock"
        case .settings: return "gear"
        case .help: return "questionmark.circle"
        case .cameraTest: return "camera"
        }
    }
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .home: 
            Text("Home View")
        case .test: 
            TestView()
        case .analytics: 
            AnalyticsView()
        case .history: 
            TestHistoryView()
        case .settings: 
            SettingsView()
        case .help: 
            HelpView()
        case .cameraTest: 
            CameraPermissionTestView()
        }
    }
}

// End of file
