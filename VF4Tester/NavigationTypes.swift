import SwiftUI


// This will be our single source of truth for navigation
enum AppNavigationItem: String, CaseIterable, Identifiable {
    case test = "Test"
    case analytics = "Analytics"
    case history = "History"
    case products = "Product Family"
    case settings = "Settings"
    case help = "Help"

    var id: Self { self }
    
    var icon: String {
        switch self {
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

// This file can be deleted as its functionality is handled by NavigationItem enum in MainContentView.swift
// Delete this entire file
