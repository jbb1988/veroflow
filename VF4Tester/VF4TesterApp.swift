import Charts
import Foundation
import SwiftUI

private let sharedViewModel = TestViewModel()

@main
struct VF4TesterApp: App {
    @AppStorage("showOnboarding") private var showOnboarding: Bool = true
    @AppStorage("hasOpened") private var hasOpened: Bool = false
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                MainContentView()
                    .environmentObject(sharedViewModel)
                    .preferredColorScheme(.dark)
                
                if showSplash {
                    SplashScreenView(isFinished: $showSplash)
                        .transition(.opacity)
                        .zIndex(1)
                        .ignoresSafeArea()
                }
            }
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
