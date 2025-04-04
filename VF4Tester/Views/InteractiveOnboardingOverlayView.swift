import SwiftUI

// Triangle struct remains the same
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct InteractiveOnboardingOverlayView: View {
    @EnvironmentObject var onboardingManager: OnboardingManager
    let geometryProxy: GeometryProxy // Proxy from the underlying view to resolve frames

    // Define estimated constants for tooltip size (can be refined)
    let estimatedTooltipWidth: CGFloat = 300
    let estimatedTooltipHeight: CGFloat = 180 // Adjust based on typical content
    let tooltipPadding: CGFloat = 15 // Space between target and tooltip

    var body: some View {
        let currentStep = onboardingManager.currentStep
        let targetAnchor = currentStep.flatMap { onboardingManager.elementFrames[$0.targetElementID] }

        if let step = currentStep {
            ZStack {
                if let anchor = targetAnchor {
                    let targetFrame = geometryProxy[anchor]
                    // Use the coordinate space of the MAIN GeometryProxy for screen bounds
                    let screenBounds = geometryProxy.frame(in: .global)

                    Canvas { context, size in
                        context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.black.opacity(0.7)))
                        context.blendMode = .destinationOut
                        let cutoutPath = Path(roundedRect: targetFrame.insetBy(dx: -4, dy: -4), cornerRadius: 8)
                        context.fill(cutoutPath, with: .color(.white))
                    }
                    .ignoresSafeArea()
                    .overlay(alignment: .topLeading) { 
                        TooltipView(step: step, targetFrame: targetFrame, screenBounds: screenBounds)
                            .offset(calculateTooltipOffset(targetFrame: targetFrame, step: step, screenBounds: screenBounds))
                            .transition(.opacity.combined(with: .scale(scale: 0.9)).animation(.spring()))
                    }
                } else {
                    // Show tooltip in center if target not found
                    Color.black.opacity(0.7)
                        .ignoresSafeArea()
                        .overlay {
                            TooltipView(
                                step: step,
                                targetFrame: .zero,
                                screenBounds: geometryProxy.frame(in: .global)
                            )
                            .frame(maxWidth: 300)
                            .position(
                                x: geometryProxy.size.width / 2,
                                y: geometryProxy.size.height / 2
                            )
                        }
                }
            }
            .onAppear {
                print("[InteractiveOnboarding] Showing step \(onboardingManager.currentStepIndex): \(step.title)")
            }
            .allowsHitTesting(true)
        } else {
            EmptyView()
        }
    }

    // Refined offset calculation
    func calculateTooltipOffset(targetFrame: CGRect, step: OnboardingStep, screenBounds: CGRect) -> CGSize {
        var desiredX: CGFloat
        var desiredY: CGFloat

        desiredX = targetFrame.midX - (estimatedTooltipWidth / 2)
        desiredY = targetFrame.maxY + tooltipPadding

        let minX = screenBounds.minX + 10 
        let maxX = screenBounds.maxX - estimatedTooltipWidth - 10 
        let clampedX = max(minX, min(desiredX, maxX))

        if desiredY + estimatedTooltipHeight > screenBounds.maxY - 10 {
            desiredY = targetFrame.minY - estimatedTooltipHeight - tooltipPadding
        }
        let minY = screenBounds.minY + 10
        let maxY = screenBounds.maxY - estimatedTooltipHeight - 10
        let clampedY = max(minY, min(desiredY, maxY))

        let finalOffsetX = clampedX - screenBounds.minX 
        let finalOffsetY = clampedY - screenBounds.minY

        print("[OverlayView] Offset Calc - Target: \(targetFrame.origin), Desired: (\(desiredX), \(desiredY)), Clamped: (\(clampedX), \(clampedY)), Final Offset: (\(finalOffsetX), \(finalOffsetY))")

        return CGSize(width: clampedX, height: clampedY)
    }
}

struct TooltipView: View {
    @EnvironmentObject var onboardingManager: OnboardingManager
    let step: OnboardingStep
    let targetFrame: CGRect
    let screenBounds: CGRect 

    @State private var tooltipSize: CGSize = .zero 

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Triangle()
                .fill(Color(hex: "002A4A").opacity(0.9))
                .frame(width: 20, height: 10)
                .rotationEffect(Angle(degrees: 0)) 
                .offset(x: calculateArrowOffset(), y: 0) 
                .zIndex(1)

            VStack(alignment: .leading, spacing: 10) {
                Text(step.title)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(step.text)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)

                HStack {
                    Button("Skip") {
                        withAnimation {
                            onboardingManager.skipOnboarding()
                        }
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.gray)
                    .padding(.vertical, 4)

                    Spacer()

                    Button("Next") {
                        print("[TooltipView] Next button tapped.")
                        withAnimation {
                            onboardingManager.nextStep()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .padding(.vertical, 4)
                }
                .padding(.top, 8)
            }
            .padding()
             .background(
                 RoundedRectangle(cornerRadius: 12)
                     .fill(Color(hex: "002A4A").opacity(0.9))
                     .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.blue.opacity(0.5)))
             )
             .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
             .frame(maxWidth: 300) 
             .background(GeometryReader { proxy in
                 Color.clear.preference(key: TooltipSizePreferenceKey.self, value: proxy.size)
             })
             .onPreferenceChange(TooltipSizePreferenceKey.self) { size in
                 self.tooltipSize = size
             }
        }
    }

    func calculateArrowOffset() -> CGFloat {
        let tooltipMidX = tooltipSize.width / 2
        let arrowHalfWidth = 20.0 / 2.0
        return (tooltipMidX > 0 ? tooltipMidX : 150) - arrowHalfWidth
    }
}

struct TooltipSizePreferenceKey: PreferenceKey {
    typealias Value = CGSize
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue() 
    }
}

// Existing Extension Color+Hex assumed to exist
// extension Color { ... }
