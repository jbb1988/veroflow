import SwiftUI

struct MenuBackgroundView: View {
    var body: some View {
        ZStack {
            // Main background color
            Color(hex: "003D6A")
                .ignoresSafeArea()
            
            // Glassmorphic overlay
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.2),
                    Color.blue.opacity(0.05)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Subtle pattern overlay
            WeavePattern()
                .ignoresSafeArea()
        }
    }
}

// Keep VisualEffectView implementation
struct VisualEffectView: UIViewRepresentable {
    let effect: UIVisualEffect
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: effect)
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = effect
    }
}
