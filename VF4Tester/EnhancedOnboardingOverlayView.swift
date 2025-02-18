//
//  VF4TesterApp.swift
//  VEROflow
//
//  Created by Jeff Butt on 2/7/25.
//


import SwiftUI
import Charts

// MARK: - Enhanced Onboarding Overlay View

struct EnhancedOnboardingOverlayView: View {
    @Binding var isShowing: Bool
    @EnvironmentObject var viewModel: TestViewModel
    
    // Onboarding page model.
    struct OnboardingPage: Identifiable {
        let id = UUID()
        let imageName: String   // Use a system image name or asset name.
        let title: String
        let description: String
    }
    
    // Define your onboarding pages.
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            imageName: "veroflowLogo", // Your asset name for the VEROflow logo.
            title: "Welcome to VEROflow‑4 Field Tester",
            description: "Experience precision testing with our advanced system. Swipe or tap Next to continue."
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
    
    @State private var currentPage: Int = 0
    
    private func dismissOnboarding() {
        viewModel.completeOnboarding()
        withAnimation { isShowing = false }
    }
    
    var body: some View {
        ZStack {
            // Dark gradient background.
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.gray.opacity(0.85)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                // Skip button
                HStack {
                    Spacer()
                    Button("Skip", action: dismissOnboarding)
                        .foregroundColor(.white)
                        .padding()
                }
                
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        let page = pages[index]
                        VStack(spacing: 20) {
                            if index == 0 {
                                // First page: Use the VEROflow logo (asset) and show the MARS Company logo at the bottom.
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
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Text(page.description)
                                    .font(.system(size: 16))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 40)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Spacer()
                                
                                Image("MARS Company") // Your asset name for MARS Company logo.
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 120, height: 120)
                                    .shadow(radius: 10)
                                    .padding(.bottom, 20)
                            } else {
                                // Other pages: use system images.
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
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Text(page.description)
                                    .font(.system(size: 16))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 40)
                                    .fixedSize(horizontal: false, vertical: true)
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
                        dismissOnboarding()
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

struct EnhancedOnboardingOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        EnhancedOnboardingOverlayView(isShowing: .constant(true))
            .environmentObject(TestViewModel())
            .preferredColorScheme(.dark)
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

// MARK: - Main App

@main
struct VF4TesterApp: App {
    @StateObject private var viewModel = TestViewModel()
    @State private var showOnboarding: Bool = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                MainTabView()
                    .environmentObject(viewModel)
                    .onAppear { 
                        viewModel.loadData()
                        showOnboarding = !viewModel.hasCompletedOnboarding
                    }
                
                if showOnboarding {
                    EnhancedOnboardingOverlayView(isShowing: $showOnboarding)
                        .environmentObject(viewModel)
                        .transition(.opacity)
                }
            }
        }
    }
}

struct VF4TesterApp_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(TestViewModel())
    }
}
