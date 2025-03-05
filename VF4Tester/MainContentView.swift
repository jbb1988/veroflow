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

struct NavigationMenuView: View {
    @Binding var isMenuOpen: Bool
    @Binding var selectedTab: NavigationItem
    @State private var selectedItemId: UUID? = nil
    @State private var hoveredItem: NavigationItem? = nil
    @Namespace private var menuNamespace
    
    var body: some View {
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
            
            // Enhanced logo
            Image("MARS Company")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(.white.opacity(0.9))
                .scaledToFit()
                .frame(height: 40)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.05))
                        .blur(radius: 3)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                )
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
                .shadow(color: .white.opacity(0.1), radius: 10, x: 0, y: 0)
            
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ZStack {
                // Base gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0/255, green: 79/255, blue: 137/255),
                        Color(red: 0/255, green: 100/255, blue: 160/255).opacity(0.8)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Animated particles
                ForEach(0..<15) { index in
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: CGFloat.random(in: 2...4), height: CGFloat.random(in: 2...4))
                        .modifier(ParticleMotionModifier())
                        .zIndex(1)
                }
                
                // Enhanced blur
                VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
                    .opacity(0.3)
                
                // Gradient overlay
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.1),
                        Color.clear
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        )
        .edgesIgnoringSafeArea(.all)
        .transition(
            AnyTransition.asymmetric(
                insertion: .opacity.combined(with: .move(edge: .leading)),
                removal: .opacity.combined(with: .move(edge: .leading))
            )
            .combined(with: .scale(scale: 0.95, anchor: .leading))
        )
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
