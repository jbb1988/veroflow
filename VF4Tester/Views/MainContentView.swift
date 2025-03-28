import SwiftUI
import Combine

struct MainContentView: View {
    @EnvironmentObject var viewModel: TestViewModel
    @AppStorage("showOnboarding") private var showOnboarding: Bool = true
    @AppStorage("hasOpened") private var hasOpened: Bool = false
    @State private var selectedTab: AppNavigationItem = .test
    @State private var isMenuOpen = false
    @GestureState private var dragOffset: CGFloat = 0
    @State private var showSafari = false
    @State private var previousTab: AppNavigationItem?

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var isIPad: Bool { horizontalSizeClass == .regular }

    var body: some View {
        ZStack {
            // Background
            Color.black.edgesIgnoringSafeArea(.all)
            
            // Content Layer
            Group {
                selectedTab.view
                    .opacity(isMenuOpen ? 0.6 : 1.0)
                    .transaction { transaction in
                        if !isMenuOpen {
                            transaction.animation = nil
                        }
                    }
            }
            
            // Header Layer
            headerView
                .zIndex(1)
            
            // Menu Layer
            Group {
                if isMenuOpen {
                    HStack(spacing: 0) {
                        NavigationMenuView(
                            isMenuOpen: $isMenuOpen,
                            selectedTab: $selectedTab,
                            onTabSelect: { newTab in
                                selectedTab = newTab
                                isMenuOpen = false
                            }
                        )
                        .frame(width: isIPad ? 300 : UIScreen.main.bounds.width * 0.55)
                        .background(MenuBackgroundView())
                        .zIndex(2)
                        
                        Color.black.opacity(0.5)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                isMenuOpen = false
                            }
                    }
                    .transition(.identity)
                }
            }
            
            // Onboarding Layer
            if showOnboarding && !hasOpened {
                EnhancedOnboardingOverlayView(isShowing: $showOnboarding)
                    .environmentObject(viewModel)
                    .zIndex(3)
                    .onDisappear {
                        hasOpened = true
                        UserDefaults.standard.set(true, forKey: "hasOpened")
                    }
            }
        }
        .background(Color(UIColor.systemBackground))
        .onChange(of: selectedTab) { _ in
            withAnimation(.easeOut(duration: 0.2)) {
                isMenuOpen = false
            }
        }
        .dynamicTypeSize(.large...(.accessibility3))
        .gesture(
            DragGesture(minimumDistance: 20, coordinateSpace: .local)
                .updating($dragOffset) { value, state, _ in
                    if !isMenuOpen && value.translation.width > 0 {
                        state = value.translation.width
                    }
                }
                .onEnded { gesture in
                    if !isMenuOpen && gesture.translation.width > 50 {
                        withAnimation(.easeOut(duration: 0.25)) {
                            isMenuOpen = true
                        }
                    }
                }
        )
    }

    private var headerView: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    withAnimation(.easeOut(duration: 0.2)) {
                        isMenuOpen.toggle()
                    }
                }) {
                    HamburgerIcon(isOpen: isMenuOpen)
                        .animation(.easeOut(duration: 0.2), value: isMenuOpen)
                }
                
                Spacer()
                
                Image("veroflowLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 47)
                    .frame(maxWidth: .infinity)
                
                Spacer()
            }
            .padding()
            .background(WeavePattern())
            Spacer()
        }
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

struct GlassmorphicBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0/255, green: 79/255, blue: 137/255),
                    Color(red: 0/255, green: 100/255, blue: 160/255).opacity(0.8)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(0.1),
                    Color.clear
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}
