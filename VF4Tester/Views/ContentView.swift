import SwiftUI


struct ContentView: View {
    @EnvironmentObject var viewModel: TestViewModel
    @State private var selectedTab: AppNavigationItem = .test
    @State private var isMenuOpen = false
    
    var body: some View {
        ZStack {
            // Main content
            VStack {
                selectedTab.view
            }
            
            // Menu overlay
            if isMenuOpen {
                AppNavigationMenuView(isMenuOpen: $isMenuOpen, selectedTab: $selectedTab)
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