import SwiftUI

struct MenuBackgroundView: View {
    private let backgroundColor = Color(hex: "003D6A")
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea(.all)
            
            WeavePattern()
                .ignoresSafeArea(.all)
        }
        // ADD: Force composite rendering for better performance in transitions
        .compositingGroup()
        // ADD: Ensure the view fills the available space
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
