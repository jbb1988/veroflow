import SwiftUI

enum AppNavigationItem: String, CaseIterable, Identifiable {
    case test = "Test"
    case analytics = "Analytics"
    case history = "History"
    case model = "3D Model"
    case products = "VEROflow Line"
    case diversified = "Diversified"
    case settings = "Settings"
    case help = "Help"

    var id: Self { self }
    
    var icon: String {
        switch self {
        case .test: return "pencil.and.outline"
        case .analytics: return "chart.bar.fill"
        case .history: return "clock.fill"
        case .model: return "cube.transparent"
        case .products: return "gauge.medium"
        case .diversified: return "cube.box.fill"
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
        case .model:
            ModelView()
        case .products:
            ProductShowcaseView()
        case .diversified:
            ShopView()
        case .settings:
            SettingsView()
        case .help:
            HelpView()
        }
    }
}

struct LazyView<Content: View>: View {
    let build: () -> Content

    init(_ build: @escaping () -> Content) {
        self.build = build
    }
    
    var body: Content {
        build()
    }
}
