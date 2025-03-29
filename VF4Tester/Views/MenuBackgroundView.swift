import SwiftUI

struct MenuBackgroundView: View {
    private let backgroundColor = Color(hex: "003D6A")
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            WeavePattern()
                .ignoresSafeArea()
        }
        .compositingGroup()
    }
}

struct VisualEffectView: UIViewRepresentable {
    let effect: UIVisualEffect
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: effect)
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        if uiView.effect !== effect {
            uiView.effect = effect
        }
    }
}
