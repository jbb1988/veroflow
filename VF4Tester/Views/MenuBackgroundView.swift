import SwiftUI

struct MenuBackgroundView: View {
    // ADD: View state management for caching
    @State private var gradientLayer = LinearGradient(
        gradient: Gradient(colors: [
            Color.blue.opacity(0.2),
            Color.blue.opacity(0.05)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        // CHANGE: Optimize layer compositing
        ZStack {
            // Main background color - cached as single layer
            Color(hex: "003D6A")
                .ignoresSafeArea()
                .drawingGroup() // Enable Metal rendering
            
            // Glassmorphic overlay - optimized gradient
            gradientLayer
                .ignoresSafeArea()
                .drawingGroup() // Enable Metal rendering
            
            // Subtle pattern overlay - cached
            WeavePattern()
                .ignoresSafeArea()
                .drawingGroup() // Enable Metal rendering
        }
        // ADD: Reduce unnecessary redraws
        .compositingGroup()
    }
}

// CHANGE: Optimize visual effect view
struct VisualEffectView: UIViewRepresentable {
    let effect: UIVisualEffect
    
    // ADD: View reuse optimization
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: effect)
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        // Only update effect if changed
        if uiView.effect !== effect {
            uiView.effect = effect
        }
    }
}
