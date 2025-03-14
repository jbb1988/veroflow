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
        let navigationItems: [NavigationItem] = [.test, .analytics, .history, .products, .shop, .settings, .help]
        let onItemSelected: (NavigationItem) -> Void = { item in
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
                    CustomHeader(isMenuOpen: $isMenuOpen)
                    Spacer()
                }
            }
            .background(Color(UIColor.systemBackground))
            
            // Menu View - Update width
            if isMenuOpen {
                HStack {
                    GeometryReader { geometry in
                        NavigationMenuView(
                            isMenuOpen: $isMenuOpen,
                            selectedTab: $navigationState.selectedTab
                        )
                        .frame(width: isIPad ? 300 : UIScreen.main.bounds.width * 0.55)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        .background(
                            GlassmorphicBackground()
                                .edgesIgnoringSafeArea(.all)
                        )
                        .transition(.move(edge: .leading))
                    }
                    .ignoresSafeArea()
                    
                    // Close button area
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
    @Published var selectedTab: NavigationItem = .test
}

enum NavigationItem: String, CaseIterable, Identifiable {
    case test = "Test"
    case analytics = "Analytics"
    case history = "History"
    case products = "VEROflow Line"
    case shop = "Diversified"
    case settings = "Settings"
    case help = "Help"
    
    var id: Self { self }
    
    var icon: String {
        switch self {
        case .test: return "pencil.and.outline"
        case .analytics: return "chart.bar.fill"
        case .history: return "clock.fill"
        case .products: return "scale.3d"
        case .shop: return "cart.fill"
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
        case .shop:
            ShopView()
        case .settings:
            SettingsView()
        case .help:
            HelpView()
        }
    }
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

struct NavigationMenuView: View {
    @Binding var isMenuOpen: Bool
    @Binding var selectedTab: NavigationItem
    @State private var selectedItemId: UUID? = nil
    @State private var hoveredItem: NavigationItem? = nil
    @Namespace private var menuNamespace
    
    @State private var drops: [Drop] = []
    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // Add drops layer first
            ForEach(drops) { drop in
                Image("Drop")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .scaleEffect(drop.scale)
                    .opacity(drop.opacity)
                    .position(x: drop.x, y: drop.y)
                    .shadow(color: .white.opacity(0.3), radius: 2)
            }
            
            // Original menu content
            VStack(alignment: .leading, spacing: 20) {
                // Enhanced BROWSE section
                VStack(alignment: .leading, spacing: 0) {
                    Text("BROWSE")
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(0.7)
                        .padding(.bottom, 8)
                        .blur(radius: 0.5)
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.white.opacity(0.3))
                        .blur(radius: 0.5)
                        .padding(.bottom, 12)
                }
                .padding(.top, 100)
                
                // Enhanced menu items
                ForEach(NavigationItem.allCases, id: \.self) { item in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = item
                            selectedItemId = UUID()
                            isMenuOpen = false
                        }
                    }) {
                        HStack(spacing: 15) {
                            Image(systemName: item.icon)
                                .font(.system(size: 20, weight: .medium))
                                .frame(width: 24)
                                .matchedGeometryEffect(id: "icon_\(item)", in: menuNamespace)
                            
                            Text(item.rawValue)
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(
                            ZStack {
                                if selectedTab == item {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.15))
                                        .matchedGeometryEffect(id: "background_\(item)", in: menuNamespace)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                        )
                                }
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .scaleEffect(selectedTab == item ? 1.02 : 1.0)
                    .overlay(
                        selectedTab == item ?
                        HStack {
                            Spacer()
                            Rectangle()
                                .fill(Color.white)
                                .frame(width: 3, height: 24)
                                .cornerRadius(1.5)
                        } : nil
                    )
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
                }
                
                Spacer()

                // Enhanced logo with circular border and glow
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 140, height: 140)
                        .blur(radius: 20)
                    
                    // Circle border
                    Circle()
                        .stroke(.white.opacity(0.2), lineWidth: 2)
                        .frame(width: 120, height: 120)
                    
                    Image("MARS Company")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.white.opacity(0.9))
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .shadow(color: .white.opacity(0.3), radius: 15)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 150)

            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            startRain()
        }
        .onReceive(timer) { _ in
            updateDrops()
        }
    }

    private func startRain() {
        // Get the menu width instead of full screen
        let menuWidth: CGFloat = UIScreen.main.bounds.width * 0.55
        
        for _ in 0...15 {
            drops.append(Drop(
                x: CGFloat.random(in: 0...menuWidth),
                y: -50,
                scale: CGFloat.random(in: 0.4...0.8),
                opacity: Double.random(in: 0.2...0.4),
                speed: Double.random(in: 2...5)
            ))
        }
    }
    
    private func updateDrops() {
        let menuWidth: CGFloat = UIScreen.main.bounds.width * 0.55
        let screenHeight = UIScreen.main.bounds.height
        
        if drops.count < 25 {
            drops.append(Drop(
                x: CGFloat.random(in: 0...menuWidth),
                y: -50,
                scale: CGFloat.random(in: 0.4...0.8),
                opacity: Double.random(in: 0.2...0.4),
                speed: Double.random(in: 2...5)
            ))
        }
        
        drops = drops.compactMap { drop in
            var updatedDrop = drop
            updatedDrop.y += drop.speed
            
            if updatedDrop.y > screenHeight + 50 {
                return nil
            }
            return updatedDrop
        }
    }
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
