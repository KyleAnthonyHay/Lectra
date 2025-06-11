import SwiftUI

@available(iOS 18.0, *)
struct LectraMeshGradients {
    // Doubled duration again
    static let animationDuration: Double = 40.0 // Increased from 20.0
    
    struct AnimatedMeshGradient: View {
        @State private var phase: CGFloat = 0
        
        // Movement offsets
        private let offsets: [(dx: Float, dy: Float)] = (0..<20).map { _ in
            (dx: Float.random(in: -0.1...0.1),
             dy: Float.random(in: -0.1...0.1))
        }
        
        // Opacity oscillation parameters for each point
        private let opacityOffsets: [Double] = (0..<20).map { _ in
            Double.random(in: 0...2 * .pi) // Random starting phase
        }
        
        var body: some View {
            TimelineView(.animation) { timeline in
                let basePoints: [SIMD2<Float>] = [
                    // Row 0 (Extended beyond top)
                    SIMD2<Float>(-0.2, -0.2),
                    SIMD2<Float>(0.25, -0.2),
                    SIMD2<Float>(0.75, -0.2),
                    SIMD2<Float>(1.2, -0.2),
                    
                    // Row 1
                    SIMD2<Float>(-0.2, 0.25),
                    SIMD2<Float>(0.25, 0.25),
                    SIMD2<Float>(0.75, 0.25),
                    SIMD2<Float>(1.2, 0.25),
                    
                    // Row 2
                    SIMD2<Float>(-0.2, 0.5),
                    SIMD2<Float>(0.25, 0.5),
                    SIMD2<Float>(0.75, 0.5),
                    SIMD2<Float>(1.2, 0.5),
                    
                    // Row 3
                    SIMD2<Float>(-0.2, 0.75),
                    SIMD2<Float>(0.25, 0.75),
                    SIMD2<Float>(0.75, 0.75),
                    SIMD2<Float>(1.2, 0.75),
                    
                    // Row 4 (Extended beyond bottom)
                    SIMD2<Float>(-0.2, 1.2),
                    SIMD2<Float>(0.25, 1.2),
                    SIMD2<Float>(0.75, 1.2),
                    SIMD2<Float>(1.2, 1.2)
                ]
                
                let currentTime = timeline.date.timeIntervalSinceReferenceDate
                
                // Halved movement speed (reduced from 0.15 to 0.075)
                let movementSpeed = currentTime * 0.075
                
                // Halved opacity animation speed (reduced from 0.3 to 0.15)
                let opacitySpeed = currentTime * 0.15
                
                // Calculate animated points and their opacities
                let animatedPoints = basePoints.enumerated().map { index, point in
                    let offset = offsets[index]
                    let dx = offset.dx * Float(sin(movementSpeed))
                    let dy = offset.dy * Float(cos(movementSpeed))
                    return SIMD2<Float>(point.x + dx, point.y + dy)
                }
                
                // Calculate oscillating opacities
                let oscillatingColors = baseColors.enumerated().map { index, baseColor in
                    let opacityPhase = opacitySpeed + opacityOffsets[index]
                    let opacity = (sin(opacityPhase) + 1) / 2 * 0.2
                    
                    switch baseColor {
                    case .white:
                        return Color.white.opacity(opacity)
                    case .blue:
                        return Color(hex: "0066FF").opacity(opacity)
                    case .clear:
                        return Color.clear.opacity(opacity * 0.4) // Keep clear colors subtler
                    }
                }
                
                Rectangle()
                    .fill(
                        MeshGradient(
                            width: 4,
                            height: 5,
                            points: animatedPoints,
                            colors: oscillatingColors,
                            background: .clear,
                            smoothsColors: true,
                            colorSpace: .device
                        )
                    )
                    .opacity(0.15)
                    .scaleEffect(1.2)
            }
        }
        
        // Base colors before opacity animation
        private let baseColors: [ColorType] = [
            // Row 0
            .white, .clear, .clear, .white,
            // Row 1
            .clear, .blue, .blue, .clear,
            // Row 2
            .clear, .blue, .blue, .clear,
            // Row 3
            .clear, .blue, .blue, .clear,
            // Row 4
            .white, .clear, .clear, .white
        ]
        
        // Helper enum for base colors
        private enum ColorType {
            case white
            case blue
            case clear
        }
    }
    
    static let mainBackground: some View = {
        AnimatedMeshGradient()
    }()
}

// Helper extension to create Color from hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 
