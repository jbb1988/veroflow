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
        
        // Check cache timeout and flush if needed
        if Date().timeIntervalSince(lastCacheFlush) > cacheTimeout {
            cachedPatterns.removeAll()
            lastCacheFlush = Date()
        }
        
        // Return cached pattern if available
        if let cached = cachedPatterns[roundedSize] {
            return cached
        }
        
        // Create new pattern
        let renderer = UIGraphicsImageRenderer(size: roundedSize, format: {
            let format = UIGraphicsImageRendererFormat()
            format.scale = scale
            return format
        }())
        
        let pattern = renderer.image { context in
            let ctx = context.cgContext
            
            UIColor.blue.withAlphaComponent(0.08).setFill()
            
            let spacing: CGFloat = 16
            let dotSize: CGFloat = 3
            let rowOffset: CGFloat = 8
            
            let columns = Int(roundedSize.width / spacing) + 2
            let rows = Int(roundedSize.height / spacing) + 2
            
            // Batch the drawing operations
            ctx.setShouldAntialias(false)
            ctx.setAllowsAntialiasing(false)
            
            for row in -1...rows {
                for col in -1...columns {
                    let x = CGFloat(col) * spacing + (CGFloat(row) * rowOffset)
                    let y = CGFloat(row) * spacing
                    let rect = CGRect(x: x, y: y, width: dotSize, height: dotSize)
                    ctx.fillEllipse(in: rect)
                }
            }
        }
        
        // Cache the pattern
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
