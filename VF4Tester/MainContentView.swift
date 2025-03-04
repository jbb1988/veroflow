import SwiftUI

struct MainContentView: View {
    @EnvironmentObject var viewModel: TestViewModel
    @AppStorage("showOnboarding") private var showOnboarding: Bool = true
    @AppStorage("hasOpened") private var hasOpened: Bool = false
    @StateObject private var navigationState = NavigationStateManager()
    @State private var isMenuOpen = false
    @GestureState private var dragOffset: CGFloat = 0

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var isIPad: Bool { horizontalSizeClass == .regular }

    var body: some View {
        let navigationItems: [NavigationItem] = [.home, .test, .analytics, .history, .settings, .help]
        let onItemSelected: (NavigationItem) -> Void = { item in
            navigationState.selectedTab = item
            isMenuOpen = false
        }

        return ZStack {
            // Main content
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                mainContentStack

                VStack(spacing: 0) {
                    CustomHeader(isMenuOpen: $isMenuOpen)
                    Spacer()
                }
            }
            .background(Color(UIColor.systemBackground))
            .offset(x: isMenuOpen ? (isIPad ? 400 : UIScreen.main.bounds.width * 0.8) : 0)
            
            // Menu View
            if isMenuOpen {
                NavigationMenuView(
                    isMenuOpen: $isMenuOpen,
                    selectedTab: $navigationState.selectedTab
                )
                .frame(width: isIPad ? 400 : UIScreen.main.bounds.width * 0.8)
                .transition(.move(edge: .leading))
            }

            // Onboarding overlay
            if showOnboarding && !hasOpened {
                EnhancedOnboardingOverlayView(isShowing: $showOnboarding)
                    .environmentObject(viewModel)
                    .zIndex(2)
                    .onDisappear {
                        hasOpened = true
                        UserDefaults.standard.set(true, forKey: "hasOpened")
                    }
            }
        }
        .dynamicTypeSize(.large...(.accessibility5))
        .gesture(
            DragGesture(minimumDistance: 20, coordinateSpace: .local)
                .updating($dragOffset) { value, state, _ in
                    if !isMenuOpen && value.translation.width > 0 {
                        state = min(value.translation.width * 0.7, UIScreen.main.bounds.width * 0.8)
                    }
                }
                .onEnded { gesture in
                    if !isMenuOpen && gesture.translation.width > 30 {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                            isMenuOpen = true
                        }
                    } else if isMenuOpen && gesture.translation.width < -30 {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                            isMenuOpen = false
                        }
                    }
                }
        )
    }

    private var mainContentStack: some View {
        ZStack {
            navigationState.selectedTab.view
            
            if isMenuOpen {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            isMenuOpen = false
                        }
                    }
                
            }
        }
        .navigationBarItems(
            leading: HamburgerIcon(isOpen: isMenuOpen)
        )
        .environmentObject(viewModel)
    }
}

class NavigationStateManager: ObservableObject {
    @Published var selectedTab: NavigationItem = .test
}

struct CustomHeader: View {
    @Binding var isMenuOpen: Bool
    
    var body: some View {
        HStack {
            Button(action: {
                withAnimation {
                    isMenuOpen.toggle()
                }
            }) {
                HamburgerIcon(isOpen: isMenuOpen)
            }
            Spacer()
            Image("veroflowLogo")
                .resizable()
                .scaledToFit()
                .frame(height: 40)
            Spacer()
        }
        .padding()
        .background(Color.black)
    }
}

struct HamburgerIcon: View {
    let isOpen: Bool
    
    var body: some View {
        VStack(spacing: 5) {
            Rectangle()
                .frame(width: 30, height: 3)
                .rotationEffect(.degrees(isOpen ? 45 : 0), anchor: .leading)
                .offset(y: isOpen ? 5 : 0)
            
            if !isOpen {
                Rectangle()
                    .frame(width: 30, height: 3)
            }
            
            Rectangle()
                .frame(width: 30, height: 3)
                .rotationEffect(.degrees(isOpen ? -45 : 0), anchor: .leading)
                .offset(y: isOpen ? -5 : 0)
        }
        .foregroundColor(.white)
    }
}

struct NavigationMenuView: View {
    @Binding var isMenuOpen: Bool
    @Binding var selectedTab: NavigationItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("BROWSE")
                .font(.subheadline)
                .foregroundColor(.white)
                .opacity(0.7)
                .padding(.top, 100)
                .padding(.bottom, 8)
            
            ForEach(NavigationItem.allCases, id: \.self) { item in
                Button(action: {
                    withAnimation {
                        selectedTab = item
                        isMenuOpen = false
                    }
                }) {
                    HStack(spacing: 15) {
                        Image(systemName: item.icon)
                            .frame(width: 24)
                        Text(item.rawValue)
                            .font(.system(size: 18))
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                }
            }
            
            Spacer()
            
            Image("MARS Company")
                .resizable()
                .renderingMode(.original)
                .scaledToFit()
                .frame(height: 40)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 60)
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0/255, green: 79/255, blue: 137/255))
        .edgesIgnoringSafeArea(.all)
    }
}
