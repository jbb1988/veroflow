import Charts
import Foundation
import SwiftUI

private let sharedViewModel = TestViewModel()

@main
struct VF4TesterApp: App {
    @AppStorage("showOnboarding") private var showOnboarding: Bool = true
    @AppStorage("hasOpened") private var hasOpened: Bool = false
    @State private var showSplash = true
    @State private var isContentReady = false
    
    var body: some Scene {
        WindowGroup {
            Group {
                if !isContentReady {
                    SplashScreenView(isFinished: $showSplash)
                } else {
                    ZStack {
                        MainContentView()
                            .environmentObject(sharedViewModel)
                            .preferredColorScheme(.dark)
                        
                        if showSplash {
                            SplashScreenView(isFinished: $showSplash)
                                .transition(.opacity)
                                .zIndex(1)
                        }
                    }
                    .animation(.easeOut(duration: 0.5), value: showSplash)
                }
            }
            .task {
                if showOnboarding {
                    hasOpened = false
                    UserDefaults.standard.removeObject(forKey: "hasOpened")
                }
                
                async let loadDataTask = sharedViewModel.loadData()
                
                _ = await loadDataTask
                isContentReady = true
                
                try? await Task.sleep(nanoseconds: 5 * 1_000_000_000)
                withAnimation(.easeOut(duration: 0.5)) {
                    showSplash = false
                }
            }
        }
    }
}
