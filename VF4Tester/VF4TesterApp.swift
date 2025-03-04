import Charts
import Foundation
import SwiftUI

@main
struct VF4TesterApp: App {
    @StateObject private var viewModel = TestViewModel()
    @AppStorage("showOnboarding") private var showOnboarding: Bool = true
    @AppStorage("hasOpened") private var hasOpened: Bool = false
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                MainContentView()
                    .environmentObject(viewModel)
                    .preferredColorScheme(.dark)
                    .onAppear {
                        if showOnboarding {
                            hasOpened = false
                            UserDefaults.standard.removeObject(forKey: "hasOpened")
                        }
                        viewModel.loadData()
                        
                        // Auto-hide splash after 7 seconds as fallback
                        DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                            withAnimation(.easeOut(duration: 0.5)) {
                                showSplash = false
                            }
                        }
                    }
                
                if showSplash {
                    SplashScreenView(isFinished: $showSplash)
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .animation(.easeOut(duration: 0.5), value: showSplash)
        }
    }
}
