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
            // Immediate view update
            DispatchQueue.main.async {
                isMenuOpen = false
            }
        }
        .dynamicTypeSize(.large...(.accessibility5))
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
            
            ForEach(0..<20) { _ in
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 4, height: 4)
                    .modifier(ParticleMotionModifier())
            }
            
            // Removed VisualEffectView
            // VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
            //     .opacity(0.4)
            
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

struct ParticleMotionModifier: ViewModifier {
    @State private var isAnimating = false
    private let randomX = Double.random(in: -100...100)
    private let randomY = Double.random(in: -200...200)
    private let duration = Double.random(in: 7...13)
    
    func body(content: Content) -> some View {
        content
            .offset(x: isAnimating ? randomX : -randomX,
                    y: isAnimating ? randomY : -randomY)
            .opacity(isAnimating ? 0.1 : 0.5)
            .onAppear {
                withAnimation(
                    Animation
                        .easeInOut(duration: duration)
                        .repeatForever(autoreverses: true)
                ) {
                    isAnimating.toggle()
                }
            }
    }
}

struct Drop: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var scale: CGFloat
    var opacity: Double
    var speed: Double
}

struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .clear,
                            .white.opacity(0.7),
                            .clear
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 3)
                    .offset(x: -geometry.size.width + (phase * geometry.size.width * 4))
                }
            )
            .mask(content)
            .onAppear {
                withAnimation(
                    Animation
                        .linear(duration: 2.0)
                        .repeatForever(autoreverses: false)
                ) {
                    phase = 1.0
                }
            }
    }
}

struct Modern3DEffect: ViewModifier {
    @State private var isAnimating = false
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(isAnimating ? 10 : -10),
                axis: (x: 0.3, y: 1.0, z: 0.2)
            )
            .shadow(color: .blue.opacity(0.5), radius: 15, x: -8, y: 8)
            .shadow(color: .white.opacity(0.5), radius: 15, x: 8, y: -8)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true)
                ) {
                    isAnimating.toggle()
                }
            }
    }
}
