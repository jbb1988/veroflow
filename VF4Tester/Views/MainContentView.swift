import SwiftUI
import Combine

struct MainContentView: View {
    @EnvironmentObject var viewModel: TestViewModel
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var onboardingManager: OnboardingManager

    @State private var selectedTab: AppNavigationItem = .test
    @State private var previousTab: AppNavigationItem?
    @State private var orientation = UIDevice.current.orientation
    @GestureState private var dragOffset: CGFloat = 0

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var isIPad: Bool { horizontalSizeClass == .regular }

    private let mainCoordinateSpace = "MainCoordinateSpace"

    private var isMenuOpen: Binding<Bool> {
        Binding(
            get: { onboardingManager.showMenu },
            set: { newValue in
                if !newValue && onboardingManager.isOnboardingActive {
                    let currentStepID = onboardingManager.currentStep?.targetElementID ?? ""
                    if !currentStepID.contains("MenuItem") {
                        onboardingManager.showMenu = newValue
                    }
                } else {
                    onboardingManager.showMenu = newValue
                }
            }
        )
    }

    var body: some View {
        GeometryReader { geometryProxy in
            NavigationView {
                ZStack {
                    backgroundColor
                    contentLayer
                    menuLayer
                    onboardingLayer(geometryProxy: geometryProxy)
                }
                .background(Color(UIColor.systemBackground))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            withAnimation(.easeOut(duration: 0.2)) {
                                onboardingManager.showMenu.toggle()
                            }
                        }) {
                            HamburgerIcon(isOpen: isMenuOpen.wrappedValue)
                                .animation(.easeOut(duration: 0.2), value: isMenuOpen.wrappedValue)
                        }
                        .contentShape(Rectangle())
                        .frame(width: 44, height: 44)
                        .anchorPreference(key: OnboardingFramePreferenceKey.self, value: .bounds) { anchor in
                            ["menuButton": anchor]
                        }
                    }

                    ToolbarItemGroup(placement: .principal) {
                        Image("veroflowLogo")
                            .resizable()
                            .renderingMode(.original)
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 80)
                    }
                }
                .toolbarBackground(.visible, for: .navigationBar)
                .onChange(of: selectedTab) { _ in
                    if !onboardingManager.isOnboardingActive ||
                       !(onboardingManager.currentStep?.targetElementID.contains("MenuItem") ?? false) {
                        withAnimation(.easeOut(duration: 0.2)) {
                            onboardingManager.showMenu = false
                        }
                    }
                }
                .preferredColorScheme(.dark)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .coordinateSpace(name: mainCoordinateSpace)
            .onPreferenceChange(OnboardingFramePreferenceKey.self) { frames in
                onboardingManager.elementFrames = frames
                print("[MainContentView] Preference Changed. Frames: \(onboardingManager.elementFrames.keys.joined(separator: ", "))")
            }
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                orientation = UIDevice.current.orientation
            }
            .dynamicTypeSize(.large...DynamicTypeSize.accessibility3)
            .gesture(dragGesture)
        }
    }

    private var backgroundColor: some View {
        Color.black.edgesIgnoringSafeArea(.all)
    }

    private var contentLayer: some View {
        Group {
            selectedTab.view
                .opacity(isMenuOpen.wrappedValue ? 0.6 : 1.0)
                .transaction { transaction in
                    if !isMenuOpen.wrappedValue {
                        transaction.animation = nil
                    }
                }
                .anchorPreference(key: OnboardingFramePreferenceKey.self, value: .bounds) { anchor in
                    ["testTabContent": anchor]
                }
        }
    }

    @ViewBuilder
    private var menuLayer: some View {
        ZStack {
            if isMenuOpen.wrappedValue {
                HStack(spacing: 0) {
                    NavigationMenuView(
                        isMenuOpen: isMenuOpen,
                        selectedTab: $selectedTab,
                        onTabSelect: { newTab in
                            selectedTab = newTab
                            if !onboardingManager.isOnboardingActive ||
                               !(onboardingManager.currentStep?.targetElementID.contains("MenuItem") ?? false) {
                                onboardingManager.showMenu = false
                            }
                        }
                    )
                    .frame(width: orientation.isLandscape ?
                           (isIPad ? 400 : UIScreen.main.bounds.height * 0.4) :
                           (isIPad ? 300 : UIScreen.main.bounds.width * 0.55))
                    .background(MenuBackgroundView())
                    .zIndex(2)
                    .anchorPreference(key: OnboardingFramePreferenceKey.self, value: .bounds) { anchor in
                        ["menu": anchor]
                    }

                    Color.black.opacity(0.5)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if !onboardingManager.isOnboardingActive ||
                               !(onboardingManager.currentStep?.targetElementID.contains("MenuItem") ?? false) {
                                onboardingManager.showMenu = false
                            }
                        }
                }
                .transition(.identity)
            }
        }
    }

    @ViewBuilder
    private func onboardingLayer(geometryProxy: GeometryProxy) -> some View {
         if onboardingManager.isOnboardingActive {
             InteractiveOnboardingOverlayView(geometryProxy: geometryProxy)
                 .environmentObject(onboardingManager)
                 .zIndex(3)
         }
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 20, coordinateSpace: .local)
            .updating($dragOffset) { value, state, _ in
                if !isMenuOpen.wrappedValue && value.translation.width > 0 {
                    state = value.translation.width
                }
            }
            .onEnded { gesture in
                if !isMenuOpen.wrappedValue && gesture.translation.width > 50 {
                    withAnimation(.easeOut(duration: 0.25)) {
                        onboardingManager.showMenu = true
                    }
                }
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
