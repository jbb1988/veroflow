import SwiftUI

// MARK: - Singleton Pattern Manager
final class WeavePatternManager {
    static let shared = WeavePatternManager()
    private var cachedPatterns: [CGSize: UIImage] = [:]
    private var lastCacheFlush = Date()
    private let cacheTimeout: TimeInterval = 300 // 5 minutes
    
    private init() {}
    
    func getPattern(for size: CGSize, scale: CGFloat = UIScreen.main.scale) -> UIImage {
        let roundedSize = CGSize(width: round(size.width), height: round(size.height))
        
        if Date().timeIntervalSince(lastCacheFlush) > cacheTimeout {
            cachedPatterns.removeAll()
            lastCacheFlush = Date()
        }
        
        if let cached = cachedPatterns[roundedSize] {
            return cached
        }
        
        let renderer = UIGraphicsImageRenderer(size: roundedSize, format: {
            let format = UIGraphicsImageRendererFormat()
            format.scale = scale
            return format
        }())
        
        let pattern = renderer.image { context in
            let ctx = context.cgContext
            
            ctx.clear(CGRect(origin: .zero, size: roundedSize))
            
            // Configure dot pattern
            let baseSpacing: CGFloat = 25
            let flowStrength: CGFloat = 8
            let curveFrequency: CGFloat = 0.05
            let dotSize: CGFloat = 1.5
            let glowRadius: CGFloat = 3.0
            
            let columns = Int(roundedSize.width / baseSpacing) + 4
            let rows = Int(roundedSize.height / baseSpacing) + 4
            
            ctx.setShouldAntialias(true)
            ctx.setAllowsAntialiasing(true)
            
            for row in -2...rows {
                for col in -2...columns {
                    let time = CGFloat(row + col) * curveFrequency
                    let yOffset = sin(CGFloat(col) * 0.3) * 15
                    let flowX = sin(time) * flowStrength
                    let flowY = cos(time) * flowStrength + yOffset
                    
                    let x = CGFloat(col) * baseSpacing + flowX
                    let y = CGFloat(row) * baseSpacing + flowY
                    
                    let distanceFromCenter = sqrt(pow(x - roundedSize.width/2, 2) + 
                                                pow(y - roundedSize.height/2, 2))
                    let maxDistance = sqrt(pow(roundedSize.width/2, 2) + 
                                        pow(roundedSize.height/2, 2))
                    let normalizedDistance = min(distanceFromCenter / maxDistance, 1.0)
                    let opacity = 0.8 - (normalizedDistance * 0.3)
                    
                    let glowColor = UIColor(red: 0.3, green: 0.6, blue: 1.0, alpha: opacity * 0.08)
                    glowColor.setFill()
                    let glowRect = CGRect(
                        x: x - glowRadius,
                        y: y - glowRadius,
                        width: glowRadius * 2,
                        height: glowRadius * 2
                    )
                    ctx.setShadow(offset: .zero, blur: 2, color: glowColor.cgColor)
                    ctx.fillEllipse(in: glowRect)
                    
                    let dotColor = UIColor(red: 0.4, green: 0.7, blue: 1.0, alpha: opacity * 0.2)
                    dotColor.setFill()
                    let dotRect = CGRect(
                        x: x - dotSize/2,
                        y: y - dotSize/2,
                        width: dotSize,
                        height: dotSize
                    )
                    ctx.setShadow(offset: .zero, blur: 0, color: nil)
                    ctx.fillEllipse(in: dotRect)
                }
            }
        }
        
        cachedPatterns[roundedSize] = pattern
        return pattern
    }
}

// MARK: - Reusable WeavePattern View
public struct WeavePattern: View {
    public init() {} // Make initializer public
    
    public var body: some View {
        GeometryReader { geometry in
            Image(uiImage: WeavePatternManager.shared.getPattern(for: geometry.size))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .allowsHitTesting(false) // Improve performance by disabling hit testing
        }
    }
}

// MARK: - For views that need custom configuration
public struct ConfigurableWeavePattern: View {
    private let opacity: Double
    private let scale: CGFloat
    
    public init(opacity: Double = 0.08, scale: CGFloat = 1.0) {
        self.opacity = opacity
        self.scale = scale
    }
    
    public var body: some View {
        WeavePattern()
            .opacity(opacity)
            .scaleEffect(scale)
    }
}
