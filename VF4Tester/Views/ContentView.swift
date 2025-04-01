import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: TestViewModel
    @EnvironmentObject var authManager: AuthManager
    @State private var selectedTab: AppNavigationItem = .test
    @State private var isMenuOpen = false
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                ZStack {
                    // Main content
                    VStack {
                        selectedTab.view
                    }
                    
                    // Menu overlay
                    if isMenuOpen {
                        NavigationMenuView(
                            isMenuOpen: $isMenuOpen,
                            selectedTab: $selectedTab,
                            onTabSelect: { newTab in
                                selectedTab = newTab
                            }
                        )
                            .frame(maxWidth: 300)
                            .transition(.move(edge: .leading))
                    }
                }
                .navigationBarItems(leading: Button(action: {
                    withAnimation(.easeOut(duration: 0.25)) {
                        isMenuOpen.toggle()
                    }
                }) {
                    Image(systemName: "line.horizontal.3")
                })
                .transition(.opacity)
            } else {
                AuthView()
                    .transition(.opacity)
            }
        }
        .animation(.default, value: authManager.isAuthenticated)
        .environmentObject(viewModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(TestViewModel())
            .environmentObject(AuthManager())
    }
}
