import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: TestViewModel
    @State private var selectedTab: NavigationItem = .test
    @State private var isMenuOpen = false
    
    var body: some View {
        ZStack {
            // Main content
            VStack {
                switch selectedTab {
                case .home:
                    Text("Home View")
                        .font(.largeTitle)
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
                }
            }
            
            // Menu overlay
            if isMenuOpen {
                NavigationMenuView(isMenuOpen: $isMenuOpen, selectedTab: $selectedTab)
                    .frame(maxWidth: 300)
                    .transition(.move(edge: .leading))
            }
        }
        .navigationBarItems(leading: Button(action: {
            withAnimation {
                isMenuOpen.toggle()
            }
        }) {
            Image(systemName: "line.horizontal.3")
        })
        .environmentObject(viewModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(TestViewModel())
    }
}
