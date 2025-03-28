import SwiftUI
import Combine

struct MainContentView: View {
    @EnvironmentObject var viewModel: TestViewModel
    @AppStorage("showOnboarding") private var showOnboarding: Bool = true
    @AppStorage("hasOpened") private var hasOpened: Bool = false
    @StateObject private var navigationState = NavigationStateManager()
    @State private var isMenuOpen = false
    @GestureState private var dragOffset: CGFloat = 0
    @State private var showSafari = false

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var isIPad: Bool { horizontalSizeClass == .regular }

    var body: some View {
        let navigationItems: [AppNavigationItem] = [.test, .analytics, .history, .products, .settings, .help]
        let onItemSelected: (AppNavigationItem) -> Void = { item in
            navigationState.selectedTab = item
            isMenuOpen = false
        }

        return ZStack {
            // Main content
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                mainContentStack
                    .offset(x: isMenuOpen ? (isIPad ? 300 : UIScreen.main.bounds.width * 0.55) : 0)

                VStack(spacing: 0) {
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
                            .frame(height: 47)
                            .frame(maxWidth: .infinity)
                        
                        Spacer()
                    }
                    .padding()
                    .background(WeavePattern())
                    Spacer()
                }
            }
            .background(Color(UIColor.systemBackground))
            
            // Menu View
            if isMenuOpen {
                HStack {
                    GeometryReader { geometry in
                        VStack {
                            NavigationMenuView(
                                isMenuOpen: $isMenuOpen,
                                selectedTab: $navigationState.selectedTab
                            )
                        }
                        .frame(width: isIPad ? 300 : UIScreen.main.bounds.width * 0.55)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        .background(
                            GlassmorphicBackground()
                                .edgesIgnoringSafeArea(.all)
                        )
                        .transition(.move(edge: .leading))
                    }
                    .ignoresSafeArea()
                    
                    Button(action: {
                        withAnimation {
                            isMenuOpen = false
                        }
                    }) {
                        HStack {
                            Image(systemName: "chevron.backward")
                                .font(.system(size: 22, weight: .bold))
                            Text("Close Menu")
                            .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                    }
                    .padding(.leading, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                }
                .sheet(isPresented: $showSafari) {
                    SafariView(url: URL(string: "https://elevenlabs.io/app/talk-to?agent_id=Md5eKB1FeOQI9ykuKDxB")!)
                }
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
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

class NavigationStateManager: ObservableObject {
    @Published var selectedTab: AppNavigationItem = .test
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

struct VisualEffectView: UIViewRepresentable {
    let effect: UIVisualEffect
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: effect)
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = effect
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
            
            // Add subtle animated particles
            ForEach(0..<20) { _ in
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 4, height: 4)
                    .modifier(ParticleMotionModifier())
            }
            
            // Enhanced blur with noise texture
            VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
                .opacity(0.4)
            
            // Add subtle gradient overlay
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
