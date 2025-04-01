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
    @AppStorage("showOnboarding") private var showOnboarding: Bool = true
    @AppStorage("hasOpened") private var hasOpened: Bool = false
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                Group {
                    if authManager.isAuthenticated {
                        MainContentView()
                            .environmentObject(sharedViewModel)
                            .preferredColorScheme(.dark)
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
                if showOnboarding {
                    hasOpened = false
                    UserDefaults.standard.removeObject(forKey: "hasOpened")
                }
                
                await sharedViewModel.loadData()
                
                try? await Task.sleep(nanoseconds: 5 * 1_000_000_000)
                withAnimation(.easeOut(duration: 0.5)) {
                    showSplash = false
                }
            }
        }
    }
}
