//
//  ExampleView.swift
//  SomeProject
//
//  Created by You on 3/20/25.
//

import SwiftUI
import SceneKit

// Update the gradient colors to use 0A1B3A
private let preloadedGradient = LinearGradient(
    gradient: Gradient(colors: [
        Color(hex: "0A1B3A"),  // Dark blue as specified
        Color(hex: "0A1B3A")   // Same color for consistent background
    ]),
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)

struct SplashScreenView: View {
    @State private var isLogoVisible = false
    @State private var circleScale = 0.3
    @State private var circleOpacity = 0.0
    @State private var glowScale = 1.0
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
            
            // Add WeavePattern as background
            WeavePattern()
                .opacity(0.4)
                .ignoresSafeArea()
            
            // Rain drops layer
            ForEach(drops) { drop in
                Image("mars3d")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .scaleEffect(drop.scale)
                    .opacity(drop.opacity)
                    .position(x: drop.x, y: drop.y)
                    .shadow(color: .white.opacity(0.5), radius: 4)
            }
            
            // Enhanced logo section with glow
            ZStack {
                // Add glowing background
                Image("vero3d")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 560, height: 560)
                    .foregroundColor(.white)
                    .blur(radius: 20)
                    .opacity(glowOpacity)
                    .scaleEffect(glowScale)
                
                // Main logo
                Image("vero3d")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 560, height: 560)
                    .colorMultiply(.white)
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
        
        // Enhanced glow animation with more dramatic effects
        withAnimation(
            .easeInOut(duration: 1.5)
            .repeatForever(autoreverses: true)
        ) {
            glowOpacity = 0.8
            glowScale = 1.25
        }
        
        // Wait for animation time and then set isFinished
        try? await Task.sleep(nanoseconds: 3 * 1_000_000_000)
        isFinished = true
    }

    struct SplashScreenView_Previews: PreviewProvider {
        static var previews: some View {
            SplashScreenView(isFinished: .constant(false))
        }
    }
}
