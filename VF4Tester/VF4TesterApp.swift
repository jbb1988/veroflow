import SwiftUI
import Charts
import Foundation

@main
struct VF4TesterApp: App {
    @StateObject private var viewModel = TestViewModel()
    @State private var showOnboarding: Bool = !UserDefaults.standard.bool(forKey: "hasOpened")

    var body: some Scene {
        WindowGroup {
            ZStack {
                MainTabView()
                    .environmentObject(viewModel)
                    .onAppear { viewModel.loadData() }

                if showOnboarding {
                    EnhancedOnboardingOverlayView(isShowing: $showOnboarding)
                        .transition(.opacity)
                }
            }
        }
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationView { TestView() }
                .tabItem { Label("Test", systemImage: "pencil.and.outline") }

            NavigationView { AnalyticsView() }
                .tabItem { Label("Analytics", systemImage: "chart.bar.xaxis") }

            NavigationView { TestHistoryView() }
                .tabItem { Label("History", systemImage: "clock") }

            NavigationView { SettingsView() }
                .tabItem { Label("Settings", systemImage: "gear") }

            NavigationView { HelpView() }
                .tabItem { Label("Help", systemImage: "questionmark.circle") }
        }
    }
}

struct EnhancedOnboardingOverlayView: View {
    @Binding var isShowing: Bool
    @State private var currentPage: Int = 0

    struct OnboardingPage: Identifiable {
        let id = UUID()
        let imageName: String
        let title: String
        let description: String
    }

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            imageName: "veroflowLogo",
            title: "Welcome to VEROflow",
            description: "Experience MARS Company precision testing with our advanced system."
        ),
        OnboardingPage(
            imageName: "pencil.and.outline",
            title: "Record Your Tests",
            description: "Quickly capture your test readings using our intuitive interface."
        ),
        OnboardingPage(
            imageName: "chart.bar.xaxis",
            title: "Analyze Performance",
            description: "Access detailed analytics and history to fine-tune your measurements."
        ),
        OnboardingPage(
            imageName: "gear",
            title: "Customize Settings",
            description: "Tailor your experience with customizable options in the Settings tab."
        ),
        OnboardingPage(
            imageName: "questionmark.circle",
            title: "Need Help?",
            description: "Find FAQs and support in the Help tab anytime."
        )
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.gray.opacity(0.85)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack {
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        let page = pages[index]
                        VStack(spacing: 20) {
                            if index == 0 {
                                Image(page.imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 150, height: 150)
                                    .shadow(radius: 10)

                                Text(page.title)
                                    .font(.system(size: 28, weight: .bold))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white)
                                    .shadow(color: Color.black.opacity(0.7), radius: 4, x: 0, y: 2)
                                    .padding(.horizontal)

                                Text(page.description)
                                    .font(.system(size: 16))
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 40)

                                Spacer()

                                Image("MARS Company")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 120, height: 120)
                                    .shadow(radius: 10)
                                    .padding(.bottom, 20)
                            } else {
                                Image(systemName: page.imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.white)
                                    .shadow(radius: 10)

                                Text(page.title)
                                    .font(.system(size: 28, weight: .bold))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white)
                                    .shadow(color: Color.black.opacity(0.7), radius: 4, x: 0, y: 2)
                                    .padding(.horizontal)

                                Text(page.description)
                                    .font(.system(size: 16))
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 40)
                            }
                        }
                        .tag(index)
                        .padding(.vertical, 40)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .frame(height: 400)

                Spacer()

                Button(action: {
                    if currentPage < pages.count - 1 {
                        withAnimation { currentPage += 1 }
                    } else {
                        withAnimation {
                            isShowing = false
                            UserDefaults.standard.set(true, forKey: "hasOpened")
                            UserDefaults.standard.synchronize()
                        }
                    }
                }) {
                    Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(12)
                        .padding(.horizontal, 40)
                        .shadow(radius: 5)
                }
                .padding(.bottom, 40)
            }
            .padding(.top, 20)
        }
        .animation(.easeInOut, value: currentPage)
    }
}

