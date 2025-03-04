import SwiftUI

struct SplashScreenView: View {
    @State private var isLogoVisible = false
    @State private var circleScale = 0.3
    @State private var circleOpacity = 0.0
    @State private var glowOpacity = 0.0
    @Binding var isFinished: Bool
    
    @State private var drops: [Drop] = []
    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    struct Drop: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var scale: CGFloat
        var opacity: Double
        var speed: Double
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "004F89"),
                    Color(hex: "002A4A")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Background circles
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
            
            // Update drops layer
            ForEach(drops) { drop in
                Image("Drop")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .scaleEffect(drop.scale)
                    .opacity(drop.opacity)
                    .position(x: drop.x, y: drop.y)
                    .shadow(color: .white, radius: 4)
            }
            
            // Logo and outer circle
            ZStack {
                // Glow effect
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 250, height: 250)
                    .blur(radius: 20)
                    .opacity(glowOpacity)
                
                // Main circle
                Circle()
                    .stroke(.white.opacity(0.2), lineWidth: 2)
                    .frame(width: 220, height: 220)
                    .scaleEffect(circleScale)
                    .opacity(circleOpacity)
                
                // Logo
                Image("veroflowLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .foregroundColor(.white)
                    .shadow(color: .white.opacity(0.3), radius: 20)
                    .opacity(isLogoVisible ? 1 : 0)
                    .scaleEffect(isLogoVisible ? 1 : 0.5)
            }
        }
        .onAppear {
            startRain()
            startAnimationSequence()
        }
        .onReceive(timer) { _ in
            updateDrops()
        }
    }
    
    private func startAnimationSequence() {
        // Initial circle animation
        withAnimation(.easeOut(duration: 0.8)) {
            circleScale = 1
            circleOpacity = 1
        }
        
        // Logo fade in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.8)) {
                isLogoVisible = true
            }
            
            // Start glow animation
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                glowOpacity = 0.6
            }
            
            // Final dismiss
            DispatchQueue.main.asyncAfter(deadline: .now() + 7.0) {
                withAnimation(.easeOut(duration: 0.5)) {
                    glowOpacity = 0
                    circleOpacity = 0
                    isLogoVisible = false
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isFinished = false
                }
            }
        }
    }
    
    private func startRain() {
        guard let window = UIApplication.shared.windows.first else { return }
        let screenWidth = window.frame.width
        
        // Create initial drops
        for _ in 0...25 {
            drops.append(Drop(
                x: CGFloat.random(in: 0...screenWidth),
                y: -50, 
                scale: CGFloat.random(in: 0.6...1.2),
                opacity: Double.random(in: 0.6...0.9),
                speed: Double.random(in: 3...7)
            ))
        }
    }
    
    private func updateDrops() {
        guard let window = UIApplication.shared.windows.first else { return }
        let screenWidth = window.frame.width
        let screenHeight = window.frame.height
        
        // Add new drops
        if drops.count < 40 {
            drops.append(Drop(
                x: CGFloat.random(in: 0...screenWidth),
                y: -50, 
                scale: CGFloat.random(in: 0.6...1.2),
                opacity: Double.random(in: 0.6...0.9),
                speed: Double.random(in: 3...7)
            ))
        }
        
        // Update existing drops
        drops = drops.compactMap { drop in
            var updatedDrop = drop
            updatedDrop.y += drop.speed
            
            // Remove drops that are off screen
            if updatedDrop.y > screenHeight + 50 {
                return nil
            }
            return updatedDrop
        }
    }

    struct SplashScreenView_Previews: PreviewProvider {
        static var previews: some View {
            SplashScreenView(isFinished: .constant(false))
        }
    }
}
