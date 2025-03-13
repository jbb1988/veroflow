import SwiftUI

struct TestDetailView: View {
    let result: TestResult
    @State private var isAnimating = false
    @EnvironmentObject var viewModel: TestViewModel
    
    // New state to control presenting the map sheet
    @State private var showMapSheet = false

    private func debugPrintValues() {
        print("Raw smallMeterStart: \(result.reading.smallMeterStart)")
        print("Raw smallMeterEnd: \(result.reading.smallMeterEnd)")
        print("Raw totalVolume: \(result.reading.totalVolume)")
        print("Raw flowRate: \(result.reading.flowRate)")
        print("Raw accuracy: \(result.reading.accuracy)")

        print("String smallMeterStart: \(String(describing: result.reading.smallMeterStart))")
        print("Default format smallMeterStart: \(String(format: "%f", result.reading.smallMeterStart))")
    }

    @State private var cardOffsets: [CGFloat] = [50, 50, 50, 50, 50]
    @State private var cardOpacities: [Double] = [0, 0, 0, 0, 0]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                InfoCard(
                    title: "Test Information",
                    icon: "info.circle",
                    offset: cardOffsets[0],
                    opacity: cardOpacities[0]
                ) {
                    VStack(spacing: 12) {
                        LabeledContent("Test Type", value: result.testType.rawValue)
                        LabeledContent("Date", value: result.date.formatted())
                        LabeledContent("Serial Number", value: result.jobNumber)
                    }
                }

                InfoCard(
                    title: "Meter Details",
                    icon: "gauge",
                    offset: cardOffsets[1],
                    opacity: cardOpacities[1]
                ) {
                    VStack(spacing: 12) {
                        LabeledContent("Size", value: result.meterSize)
                        LabeledContent("Type", value: result.meterType)
                        LabeledContent("Model", value: result.meterModel)
                    }
                }

                InfoCard(
                    title: "Results",
                    icon: "chart.bar.fill",
                    offset: cardOffsets[2],
                    opacity: cardOpacities[2]
                ) {
                    VStack(spacing: 12) {
                        ResultRow(label: "Start Read", value: String(describing: result.reading.smallMeterStart), iconName: "arrow.forward.circle.fill", color: .blue)
                        ResultRow(label: "End Read", value: String(describing: result.reading.smallMeterEnd), iconName: "arrow.backward.circle.fill", color: .purple)
                        ResultRow(label: "Total Volume", value: viewModel.configuration.formatVolume(result.reading.totalVolume), iconName: "drop.fill", color: .cyan)
                        ResultRow(label: "Flow Rate", value: "\(String(describing: result.reading.flowRate)) GPM", iconName: "speedometer", color: .orange)

                        AccuracyIndicator(accuracy: result.reading.accuracy, isPassing: result.isPassing, isAnimating: isAnimating)

                        StatusIndicator(isPassing: result.isPassing, isAnimating: isAnimating)
                    }
                }

                InfoCard(
                    title: "Location",
                    icon: "location.fill",
                    offset: 0,
                    opacity: 1
                ) {
                    if let lat = result.latitude, let lon = result.longitude {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Test Location")
                                .font(.headline)
                            Text("Lat: \(lat), Lon: \(lon)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            if let locationDesc = result.locationDescription, !locationDesc.isEmpty {
                                Text(locationDesc)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Button(action: {
                                showMapSheet = true
                            }) {
                                Text("View Map")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(Color.blue.opacity(0.7))
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.black.opacity(0.2), lineWidth: 4)
                                                .blur(radius: 4)
                                                .offset(x: 2, y: 2)
                                                .mask(
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .fill(LinearGradient(
                                                            gradient: Gradient(colors: [Color.black, Color.clear]),
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing))
                                                )
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.white.opacity(0.7), lineWidth: 4)
                                                .blur(radius: 4)
                                                .offset(x: -2, y: -2)
                                                .mask(
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .fill(LinearGradient(
                                                            gradient: Gradient(colors: [Color.clear, Color.black]),
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing))
                                                )
                                        }
                                    )
                            }
                        }
                    } else {
                        Text("Location not available")
                    }
                }

                if !result.notes.isEmpty {
                    InfoCard(
                        title: "Notes",
                        icon: "note.text",
                        offset: cardOffsets[3],
                        opacity: cardOpacities[3]
                    ) {
                        // Make notes text selectable
                        Text(result.notes)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
                            .textSelection(.enabled) // <-- enables selection handles
                    }
                }

                if let imageDataArray = result.meterImageData, let firstData = imageDataArray.first, let uiImage = UIImage(data: firstData) {
                    InfoCard(
                        title: "Meter Image",
                        icon: "photo",
                        offset: cardOffsets[4],
                        opacity: cardOpacities[4]
                    ) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    }
                }
            }
            .padding()
        }
        .textSelection(.enabled) // enable text selection for the entire ScrollView
        .navigationTitle("Test Details")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(UIColor.systemGroupedBackground))
        .onAppear {
            debugPrintValues()
            animateCards()
            LocationManager.shared.fetchCurrentLocation()
        }
        // Sheet for showing Google Maps in Safari
        .sheet(isPresented: $showMapSheet) {
            if let lat = result.latitude, let lon = result.longitude {
                let urlString = "https://www.google.com/maps/search/?api=1&query=\(lat),\(lon)"
                if let url = URL(string: urlString) {
                    SafariView(url: url)
                } else {
                    Text("Invalid Map URL")
                }
            } else {
                Text("Location not available")
            }
        }
    }

    private func animateCards() {
        for index in 0..<cardOffsets.count {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1)) {
                cardOffsets[index] = 0
                cardOpacities[index] = 1
            }
        }
        withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
            isAnimating = true
        }
    }
}

struct InfoCard<Content: View>: View {
    let title: String
    let icon: String
    let offset: CGFloat
    let opacity: Double
    let content: Content

    init(title: String, icon: String, offset: CGFloat, opacity: Double, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.offset = offset
        self.opacity = opacity
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label(title, systemImage: icon)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            content
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
        .offset(y: offset)
        .opacity(opacity)
    }
}

struct ResultRow: View {
    let label: String
    let value: String
    let iconName: String
    let color: Color

    var body: some View {
        HStack {
            Label(label, systemImage: iconName)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .bold()
                .foregroundColor(color)
        }
    }
}

struct AccuracyIndicator: View {
    let accuracy: Double
    let isPassing: Bool
    let isAnimating: Bool

    var body: some View {
        HStack {
            Label("Accuracy", systemImage: "percent")
                .foregroundColor(.secondary)
            Spacer()
            Text(String(format: "%.2f%%", accuracy))
                .bold()
                .foregroundColor(isPassing ? .green : .red)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isPassing ? Color.green : Color.red, lineWidth: 2)
                .opacity(isAnimating ? 1 : 0)
                .scaleEffect(isAnimating ? 1 : 0.8)
        )
    }
}

struct StatusIndicator: View {
    let isPassing: Bool
    let isAnimating: Bool

    var body: some View {
        HStack {
            Label("Status", systemImage: isPassing ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(.secondary)
            Spacer()
            Text(isPassing ? "PASS" : "FAIL")
                .bold()
                .foregroundColor(isPassing ? .green : .red)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isPassing ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                .scaleEffect(isAnimating ? 1 : 0.8)
        )
        .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.3), value: isAnimating)
    }
}

struct LabeledContent: View {
    let label: String
    let value: String

    init(_ label: String, value: String) {
        self.label = label
        self.value = value
    }

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .bold()
        }
        .padding(.vertical, 4)
    }
}

// Example preview
struct TestDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TestDetailView(result: TestResult(
                id: UUID(),
                testType: .lowFlow,
                date: Date(),
                reading: MeterReading(
                    smallMeterStart: 10,
                    smallMeterEnd: 20,
                    largeMeterStart: 0,
                    largeMeterEnd: 0,
                    totalVolume: 10,
                    flowRate: 5,
                    readingType: .small
                ),
                notes: "Preview test note",
                meterImageData: nil,
                meterSize: "1\"",
                meterType: "Neptune",
                meterModel: "Positive Displacement",
                jobNumber: "JOB-001",
                latitude: nil,
                longitude: nil,
                locationDescription: nil
            ))
            .environmentObject(TestViewModel())
        }
    }
}
