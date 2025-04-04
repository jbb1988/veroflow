import SwiftUI
import Combine

struct MainContentView: View {
    @EnvironmentObject var viewModel: TestViewModel
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var onboardingManager: OnboardingManager

    @State private var selectedTab: AppNavigationItem = .test
    @State private var isMenuOpen = false
    @GestureState private var dragOffset: CGFloat = 0
    @State private var showSafari = false
    @State private var previousTab: AppNavigationItem?
    @State private var orientation = UIDevice.current.orientation

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var isIPad: Bool { horizontalSizeClass == .regular }

    private let mainCoordinateSpace = "MainCoordinateSpace"

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
                .toolbar { navigationToolbar }
                .toolbarBackground(.visible, for: .navigationBar)
                .onChange(of: selectedTab) { _ in
                    withAnimation(.easeOut(duration: 0.2)) {
                        isMenuOpen = false
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
                .opacity(isMenuOpen ? 0.6 : 1.0)
                .transaction { transaction in
                    if !isMenuOpen {
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
                        isMenuOpen = false
                    }
            }
            .transition(.identity)
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

    private var navigationToolbar: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarLeading) {
                 Button(action: {
                     withAnimation(.easeOut(duration: 0.2)) {
                         isMenuOpen.toggle()
                     }
                 }) {
                     HamburgerIcon(isOpen: isMenuOpen)
                         .animation(.easeOut(duration: 0.2), value: isMenuOpen)
                 }
                 .contentShape(Rectangle())
                 .frame(width: 44, height: 44)
                  // Keep anchor preference for the button
                 .anchorPreference(key: OnboardingFramePreferenceKey.self, value: .bounds) { anchor in
                      ["menuButton": anchor]
                 }
            }

            ToolbarItem(placement: .principal) {
                 // CHANGE: Wrap the Image in GeometryReader
                 GeometryReader { geometry in
                     Image("veroflowLogo")
                         .resizable()
                         .renderingMode(.original)
                         .aspectRatio(contentMode: .fit)
                         // Use the height logic but apply frame to GeometryReader if needed
                         .frame(height: orientation.isLandscape ? 40 : 60)
                         .fixedSize(horizontal: false, vertical: true)
                          // Apply anchor preference to a background within GeometryReader
                         .background(
                              Color.clear // Use a clear background
                                  .anchorPreference(key: OnboardingFramePreferenceKey.self, value: .bounds) { anchor in
                                      // This anchor is relative to the background's bounds
                                      // Use transformAnchor to convert it to the named coordinate space
                                      let frameInNamedSpace = geometry.frame(in: .named(mainCoordinateSpace))
                                      print("[ToolbarItem Geometry] Logo frame in named space: \(frameInNamedSpace)") // Debug print
                                      // Return the anchor transformed to the coordinate space
                                      return ["mainLogo": anchor] // Still use bounds anchor, resolved by overlay
                                  }
                          )
                 }
                 // Apply frame constraints to GeometryReader if the Image needs specific sizing within toolbar
                 .frame(height: orientation.isLandscape ? 40 : 60)
            }
        }
    }

    private var dragGesture: some Gesture {
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
