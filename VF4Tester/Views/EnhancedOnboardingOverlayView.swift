import SwiftUI

struct EnhancedOnboardingOverlayView: View {
    @Binding var isShowing: Bool
    @EnvironmentObject var viewModel: TestViewModel
    @State private var currentPage = 0
    
    private let pages: [(title: String, message: String, image: String)] = [
        ("Welcome to VEROflow", "Experience MARS Company precision testing with our advanced system.", "veroflowLogo"),
        ("Record Your Tests", "Quickly capture your test readings using our intuitive interface.", "pencil.and.outline"),
        ("Analyze Performance", "Access detailed analytics and history to fine-tune your measurements.", "chart.bar.xaxis"),
        ("Customize Settings", "Tailor your experience with customizable options in the Settings tab.", "gear"),
        ("Need Help?", "Find FAQs and support in the Help tab anytime.", "questionmark.circle")
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "004F89"),
                    Color(hex: "002A4A")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            GeometryReader { geometry in
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.05))
                        .frame(width: geometry.size.width * 0.8)
                        .offset(x: -geometry.size.width * 0.3, y: -geometry.size.height * 0.2)
                        .blur(radius: 30)
                    
                    Circle()
                        .fill(.white.opacity(0.05))
                        .frame(width: geometry.size.width * 0.7)
                        .offset(x: geometry.size.width * 0.3, y: geometry.size.height * 0.2)
                        .blur(radius: 30)
                }
            }

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPage(
                            title: pages[index].title,
                            message: pages[index].message,
                            imageName: pages[index].image,
                            isLast: index == pages.count - 1,
                            currentPage: $currentPage,
                            totalPages: pages.count,
                            onComplete: { isShowing = false }
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding()
        }
    }
}

struct OnboardingPage: View {
    let title: String
    let message: String
    let imageName: String
    let isLast: Bool
    @Binding var currentPage: Int
    let totalPages: Int
    let onComplete: () -> Void
    
    @State private var displayedText: String = ""
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            if imageName.contains("Logo") {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 400)
                    .foregroundColor(.white)
                    .shadow(color: .white.opacity(0.3), radius: 20)
                    .overlay(
                        Circle()
                            .stroke(.white.opacity(0.2), lineWidth: 2)
                            .frame(width: 420, height: 420)
                    )
            } else {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .background(
                            Circle()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [.white.opacity(0.2), .white.opacity(0.05)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                        )
                        .frame(width: 150, height: 150)
                        .shadow(color: .white.opacity(0.2), radius: 15)
                    
                    if isSymbolAvailable(imageName) {
                        Image(systemName: imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.white)
                            .symbolRenderingMode(.hierarchical)
                            .symbolVariant(.fill)
                            .shadow(color: .white.opacity(0.3), radius: 15)
                    } else {
                        Text(getFallbackIcon(imageName))
                            .font(.system(size: 90))
                            .shadow(color: .white.opacity(0.3), radius: 15)
                    }
                }
                .rotation3DEffect(.degrees(3), axis: (x: 1, y: 0, z: 0))
            }
            
            Text(title)
                .font(.title.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .shadow(color: .black.opacity(0.2), radius: 5)
            
            Text(displayedText)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal)
                .lineLimit(nil)
            
            Spacer()
            
            HStack(spacing: 12) {
                ForEach(0..<totalPages, id: \.self) { index in
                    Circle()
                        .frame(width: currentPage == index ? 10 : 8, height: currentPage == index ? 10 : 8)
                        .foregroundColor(currentPage == index ? .white : .white.opacity(0.4))
                        .animation(.easeInOut, value: currentPage)
                        .overlay(
                            Circle()
                                .stroke(.white.opacity(0.2), lineWidth: currentPage == index ? 2 : 0)
                                .padding(-2)
                        )
                }
            }
            .padding(.top, 20)
            
            Button(action: {
                if isLast {
                    onComplete()
                } else {
                    withAnimation {
                        currentPage += 1
                    }
                }
            }) {
                Text(isLast ? "Get Started" : "Next")
                    .font(.headline.bold())
                    .foregroundColor(Color(hex: "004F89"))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.white, .white.opacity(0.9)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            }
            .padding(.top, 20)
        }
        .padding()
        .onAppear {
            startTypingEffect()
        }
        .onChange(of: currentPage) { _ in
            startTypingEffect()
        }
    }
    
    private func startTypingEffect() {
        displayedText = ""
        let fullText = message
        
        let wordCount = fullText.components(separatedBy: .whitespaces).count
        let baseInterval = 0.05
        let wordMultiplier = max(1.0, Double(wordCount) / 10.0)
        let interval = baseInterval * wordMultiplier
        
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            if displayedText.count < fullText.count {
                displayedText.append(String(fullText[fullText.index(fullText.startIndex, offsetBy: displayedText.count)]))
            } else {
                timer.invalidate()
            }
        }
    }
    
    private func isSymbolAvailable(_ symbolName: String) -> Bool {
        if #available(iOS 13.0, *) {
            return UIImage(systemName: symbolName) != nil
        }
        return false
    }
    
    private func getFallbackIcon(_ symbolName: String) -> String {
        switch symbolName {
        case "pencil.and.outline":
            return "📝"
        case "chart.bar.xaxis":
            return "📊"
        case "gear":
            return "⚙️"
        case "questionmark.circle":
            return "❓"
        default:
            return "🔍"
        }
    }
}

struct EnhancedOnboardingOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        EnhancedOnboardingOverlayView(isShowing: .constant(true))
            .environmentObject(TestViewModel())
    }
}
