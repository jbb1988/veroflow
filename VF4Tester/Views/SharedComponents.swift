import SwiftUI
import Charts
import Foundation
#if os(iOS)
import UIKit
#endif
import SafariServices
import WebKit

// Add this near the top, before other definitions
struct ContentSpacing {
    static let headerToContent: CGFloat = 20 // Reduced by 65% from previous implicit spacing
}

// MARK: - Field Enum
enum Field: Hashable, RawRepresentable {
    case smallStart, smallEnd, largeStart, largeEnd, totalVolume, flowRate, jobNumber, additionalRemarks
    
    // Add raw value implementation
    var rawValue: String {
        switch self {
        case .smallStart: return "smallStart"
        case .smallEnd: return "smallEnd"
        case .largeStart: return "largeStart"
        case .largeEnd: return "largeEnd"
        case .totalVolume: return "totalVolume"
        case .flowRate: return "flowRate"
        case .jobNumber: return "jobNumber"
        case .additionalRemarks: return "additionalRemarks"
        }
    }
    
    // Required initializer for RawRepresentable
    init?(rawValue: String) {
        switch rawValue {
        case "smallStart": self = .smallStart
        case "smallEnd": self = .smallEnd
        case "largeStart": self = .largeStart
        case "largeEnd": self = .largeEnd
        case "totalVolume": self = .totalVolume
        case "flowRate": self = .flowRate
        case "jobNumber": self = .jobNumber
        case "additionalRemarks": self = .additionalRemarks
        default: return nil
        }
    }
}

// Add extension for custom logging
extension Field {
    static func logAccess(_ field: Field, value: String) {
        print("[Field Access] - \(field.rawValue): \(value)")
    }
}

// MARK: - MarsReadingField
struct MarsReadingField: View {
    let title: String
    @Binding var text: String
    let field: Field

    init(title: String, text: Binding<String>, field: Field) {
        self.title = title
        self._text = text
        self.field = field
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            #if os(iOS)
            TextField("", text: $text)
                .keyboardType(.decimalPad)
                .frame(height: 15)
                .padding(8)
                .background(Color.black)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue.opacity(0.9), lineWidth: 2)
                )
                .shadow(color: Color.blue.opacity(0.5), radius: 4, x: 0, y: 0)
            #else
            TextField("", text: $text)
                .textFieldStyle(.roundedBorder)
            #endif
        }
    }
}

// MARK: - DetailCard
struct DetailCard<Content: View>: View {
    let title: String
    let content: () -> Content

    init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            content()
        }
        .padding()
        .background(
            ZStack {
                Color.black.opacity(0.5)
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.2),
                        Color.blue.opacity(0.05)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.blue.opacity(0.8),
                            Color.blue.opacity(0.2)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.blue.opacity(0.2), radius: 10, x: 0, y: 0)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Toast Modifier and Extension
struct ToastModifier: ViewModifier {
    @Binding var isPresented: Bool
    let message: String

    func body(content: Content) -> some View {
        ZStack {
            content
            if isPresented {
                VStack {
                    Text(message)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                }
                .transition(.move(edge: .top))
                .animation(.spring(), value: isPresented)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation { isPresented = false }
                    }
                }
            }
        }
    }
}
extension View {
    func toast(isPresented: Binding<Bool>, message: String) -> some View {
        self.modifier(ToastModifier(isPresented: isPresented, message: message))
    }
}

// MARK: - StatCard
struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            Text(value)
                .font(.title2)
                .bold()
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            ZStack {
                Color.black.opacity(0.5)
                LinearGradient(
                    gradient: Gradient(colors: [
                        color.opacity(0.2),
                        color.opacity(0.05)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            color.opacity(0.8),
                            color.opacity(0.2)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: color.opacity(0.2), radius: 8, x: 0, y: 0)
    }
}

// MARK: - Placeholder Extension
extension View {
    func placeholder(when shouldShow: Bool, placeholder: String) -> some View {
        ZStack(alignment: .leading) {
            if shouldShow {
                Text(placeholder)
                    .foregroundColor(.secondary)
            }
            self
        }
    }
}

// MARK: - ShareSheet (iOS Only)
#if os(iOS)
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]?

    init(activityItems: [Any], applicationActivities: [UIActivity]? = nil) {
        self.activityItems = activityItems
        self.applicationActivities = applicationActivities
    }

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) { }
}
#endif

// MARK: - WaveCircleGauge and Supporting Shapes
struct WaveCircleGauge: View {
    let totalVolume: Double
    let targetVolume: Double
    @State private var phase: CGFloat = 0

    // For demo purposes, force fillPercentage to 50%
    private var fillPercentage: Double {
        0.5
    }

    init(totalVolume: Double, targetVolume: Double) {
        self.totalVolume = totalVolume
        self.targetVolume = targetVolume
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.blue, lineWidth: 3)
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.6)]),
                startPoint: .bottom,
                endPoint: .top
            )
            .mask(
                WaveCircleShape(phase: phase, amplitude: 8, fillPercentage: fillPercentage)
            )
            .clipShape(Circle())
            .animation(.easeInOut(duration: 1), value: fillPercentage)
        }
        .aspectRatio(1, contentMode: .fit)
        .onAppear {
            withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
                phase = .pi * 2
            }
        }
    }
}

struct WaveCircleShape: Shape {
    var phase: CGFloat
    var amplitude: CGFloat
    var fillPercentage: Double

    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let waterLevel = height * CGFloat(1 - fillPercentage)
        let waveLength = width / 1.2
        path.move(to: CGPoint(x: 0, y: waterLevel))
        for x in stride(from: 0, through: width, by: 1) {
            let relativeX = x / width
            let sine = sin((relativeX * 2 * .pi * (width / waveLength)) + phase)
            let y = waterLevel + amplitude * sine
            path.addLine(to: CGPoint(x: x, y: y))
        }
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()
        return path
    }
}

// MARK: - CardModifier and SectionHeader
struct CardModifier: ViewModifier {
    var color: Color = .blue
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                ZStack {
                    Color.black.opacity(0.5)
                    LinearGradient(
                        gradient: Gradient(colors: [
                            color.opacity(0.2),
                            color.opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                color.opacity(0.8),
                                color.opacity(0.2)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: color.opacity(0.2), radius: 8, x: 0, y: 0)
    }
}

extension View {
    func cardStyle(color: Color = .blue) -> some View {
        self.modifier(CardModifier(color: color))
    }
}

struct SectionHeader: View {
    let title: String
    let systemImage: String
    let headerColor: Color

    var body: some View {
        HStack {
            Label(title, systemImage: systemImage)
                .foregroundColor(headerColor)
                .font(.headline)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - FilterPill
struct FilterPill: View {
    @Binding var isExpanded: Bool
    @Binding var selectedFilter: TestHistoryView.FilterOption
    @Binding var selectedSort: TestHistoryView.SortOrder
    @Binding var startDate: Date
    @Binding var endDate: Date
    @Binding var selectedChartType: String
    
    // Add state to track animation
    @State private var isAnimating: Bool = false
    
    var body: some View {
        VStack(spacing: 8) {
            // Filter Header
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack {
                    Label("Filter & Sort", systemImage: "line.3.horizontal.decrease.circle")
                        .font(.headline)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                }
                .foregroundColor(.primary)
                .padding(12)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
            }

            if isExpanded {
                VStack(spacing: 12) {
                    // Filter Options
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(TestHistoryView.FilterOption.allCases) { option in
                                Button(action: { selectedFilter = option }) {
                                    Text(option.rawValue)
                                        .font(.subheadline)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(selectedFilter == option ? option.borderColor.opacity(0.2) : Color(UIColor.tertiarySystemBackground))
                                        .foregroundColor(selectedFilter == option ? option.borderColor : .primary)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(option.borderColor, lineWidth: selectedFilter == option ? 2 : 1)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                    }

                    // Sort Order
                    Picker("Sort Order", selection: $selectedSort) {
                        ForEach(TestHistoryView.SortOrder.allCases, id: \.self) { order in
                            Text(order.rawValue).tag(order)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    // Chart Type
                    Picker("Chart Type", selection: $selectedChartType) {
                        Text("line").tag("line")
                        Text("bar").tag("bar")
                        Text("pie").tag("pie")
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    // Date Range
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Date Range")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        HStack {
                            DatePicker("Start", selection: $startDate, displayedComponents: .date)
                                .labelsHidden()
                            Text("to")
                                .foregroundColor(.secondary)
                            DatePicker("End", selection: $endDate, displayedComponents: .date)
                                .labelsHidden()
                        }
                    }
                }
                .padding(12)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
            }
        }
    }
}

extension View {
    func standardContentSpacing() -> some View {
        self.padding(.top, ContentSpacing.headerToContent)
    }
}

// ADD: SafariView struct
struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // No updates needed for SFSafariViewController
    }
}

// ADD: AnimatedSafariButton struct
struct AnimatedSafariButton: View {
    @State private var isAnimating = false
    @State private var animateShine = false
    let gradient = Gradient(colors: [.red, .blue])
    let action: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: gradient,
                startPoint: isAnimating ? .topTrailing : .bottomLeading,
                endPoint: isAnimating ? .bottomTrailing : .center
            )
            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isAnimating)
            .frame(width: 108, height: 108)
            .clipShape(Circle())
            .blur(radius: 8)

            Button(action: {
                withAnimation(.easeIn(duration: 0.3)) {
                    animateShine = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        animateShine = false
                    }
                }
                action()
            }) {
                Image("mars3d")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 95, height: 95)
                    .clipShape(Circle())
            }
            .overlay(
                GeometryReader { geometry in
                    if animateShine {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.white.opacity(0.0), Color.white.opacity(0.8), Color.white.opacity(0.0)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .rotationEffect(.degrees(30))
                            .offset(x: -geometry.size.width)
                            .offset(x: animateShine ? geometry.size.width * 2 : -geometry.size.width)
                            .animation(.linear(duration: 0.6), value: animateShine)
                    }
                }
                .clipShape(Circle())
            )
        }
        .onAppear { isAnimating = true }
    }
}
