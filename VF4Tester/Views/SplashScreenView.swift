//
//  ExampleView.swift
//  SomeProject
//
//  Created by You on 3/20/25.
//

import SwiftUI
import SceneKit

private let preloadedGradient = LinearGradient(
    gradient: Gradient(colors: [
        Color(hex: "004F89"),
        Color(hex: "002A4A")
    ]),
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)

struct SplashScreenView: View {
    @State private var isLogoVisible = false
    @State private var circleScale = 0.3
    @State private var circleOpacity = 0.0
    @State private var glowOpacity = 0.0
    @Binding var isFinished: Bool
    
    // Rain animation properties
    @State private var drops: [Drop] = []
    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 0.8
    @State private var rotationY: Double = 0
    
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
            preloadedGradient
                .ignoresSafeArea()
                .drawingGroup()
            
            // Rain drops layer
            ForEach(drops) { drop in
                Image("Drop")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30) 
                    .scaleEffect(drop.scale)
                    .opacity(drop.opacity)
                    .position(x: drop.x, y: drop.y)
                    .shadow(color: .white.opacity(0.5), radius: 4) 
            }
            
            // Logo and outer circle
            ZStack {
                // Glow effect
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 250, height: 250)
                    .blur(radius: 20)
                    .opacity(glowOpacity)
                
                Circle()
                    .stroke(.white.opacity(0.2), lineWidth: 2)
                    .frame(width: 220, height: 220)
                    .scaleEffect(circleScale)
                    .opacity(circleOpacity)
                
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
        }
        .onReceive(timer) { _ in
            updateDrops()
        }
        .task(priority: .userInitiated) {
            await startAnimationSequence()
        }
    }
    
    private func startRain() {
        let screenWidth = UIScreen.main.bounds.width
        for _ in 0...25 { 
            drops.append(Drop(
                x: CGFloat.random(in: 0...screenWidth),
                y: -50,
                scale: CGFloat.random(in: 0.6...1.0), 
                opacity: Double.random(in: 0.4...0.8), 
                speed: Double.random(in: 3...7) 
            ))
        }
    }
    
    private func updateDrops() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        if drops.count < 35 { 
            drops.append(Drop(
                x: CGFloat.random(in: 0...screenWidth),
                y: -50,
                scale: CGFloat.random(in: 0.6...1.0),
                opacity: Double.random(in: 0.4...0.8),
                speed: Double.random(in: 3...7)
            ))
        }
        
        drops = drops.compactMap { drop in
            var updatedDrop = drop
            updatedDrop.y += drop.speed
            
            if updatedDrop.y > screenHeight + 50 {
                return nil
            }
            return updatedDrop
        }
    }

    private func startAnimationSequence() async {
        // Initial circle animation
        withAnimation(.easeOut(duration: 0.8)) {
            circleScale = 1
            circleOpacity = 1
        }
        
        try? await Task.sleep(nanoseconds: UInt64(0.3 * Double(NSEC_PER_SEC)))
        
        withAnimation(.easeOut(duration: 0.8)) {
            isLogoVisible = true
        }
        
        // Start glow animation
        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
            glowOpacity = 0.6
        }
        
        // Wait for animation time and then set isFinished
        try? await Task.sleep(nanoseconds: 3 * 1_000_000_000)
        isFinished = true
        
        // No fade out animations - keep everything visible
    }

    struct SplashScreenView_Previews: PreviewProvider {
        static var previews: some View {
            SplashScreenView(isFinished: .constant(false))
        }
    }
}
