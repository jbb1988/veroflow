import Charts
import Foundation
import SwiftUI
import FirebaseCore
import FirebaseAuth

private let sharedViewModel = TestViewModel()

@main
struct VF4TesterApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authManager = AuthManager()
    @State private var showSplash = true
    @State private var isFirstLaunch = true

    @StateObject private var onboardingManager = OnboardingManager()

    var body: some Scene {
        WindowGroup {
            ZStack {
                Group {
                    if authManager.isAuthenticated {
                        MainContentView()
                            .environmentObject(sharedViewModel)
                            .environmentObject(onboardingManager)
                            .preferredColorScheme(.dark)
                            .onChange(of: authManager.isAuthenticated) { isAuthenticated in
                                if isAuthenticated {
                                    showSplash = true
                                    startSplashTimer()
                                    onboardingManager.startOnboardingIfNeeded()
                                }
                            }
                    } else {
                        AuthView()
                            .preferredColorScheme(.dark)
                    }
                }

                if showSplash {
                    SplashScreenView(isFinished: $showSplash)
                        .transition(.opacity)
                        .zIndex(1)
                        .ignoresSafeArea()
                }
            }
            .environmentObject(authManager)
            .animation(.easeOut(duration: 0.5), value: showSplash)
            .task {
                if isFirstLaunch {
                    showSplash = true
                    startSplashTimer()
                    isFirstLaunch = false
                }

                sharedViewModel.loadData()

                if authManager.isAuthenticated {
                    onboardingManager.startOnboardingIfNeeded()
                }
            }
        }
    }

    private func startSplashTimer() {
        Task {
            try? await Task.sleep(nanoseconds: 5 * 1_000_000_000)
            withAnimation(.easeOut(duration: 0.5)) {
                showSplash = false
            }
        }
    }
}
