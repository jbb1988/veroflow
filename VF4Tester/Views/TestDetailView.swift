import SwiftUI

struct TestDetailView: View {
    let result: TestResult
    @State private var isAnimating = false
    @EnvironmentObject var viewModel: TestViewModel
    
    private func debugPrintValues() {
        print("Raw smallMeterStart: \(result.reading.smallMeterStart)")
        print("Raw smallMeterEnd: \(result.reading.smallMeterEnd)")
        print("Raw totalVolume: \(result.reading.totalVolume)")
        print("Raw flowRate: \(result.reading.flowRate)")
        print("Raw accuracy: \(result.reading.accuracy)")
        
        print("String smallMeterStart: \(String(describing: result.reading.smallMeterStart))")
        print("Default format smallMeterStart: \(String(format: "%f", result.reading.smallMeterStart))")
    }

    var body: some View {
        List {
            Section(header: Text("Test Information")) {
                LabeledContent("Test Type", value: result.testType.rawValue)
                LabeledContent("Date", value: result.date.formatted())
                LabeledContent("Serial Number", value: result.jobNumber)
            }
            Section(header: Text("Meter Details")) {
                LabeledContent("Size", value: result.meterSize)
                LabeledContent("Type", value: result.meterType)
                LabeledContent("Model", value: result.meterModel)
            }
            Section(header: Text("Results")) {
                LabeledContent("Start Read", value: String(describing: result.reading.smallMeterStart))
                LabeledContent("End Read", value: String(describing: result.reading.smallMeterEnd))
                LabeledContent("Total Volume", value: viewModel.configuration.formatVolume(result.reading.totalVolume))
                LabeledContent("Flow Rate", value: "\(String(describing: result.reading.flowRate)) GPM")
                LabeledContent("Accuracy", value: "\(String(format: "%.2f", result.reading.accuracy))%")
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(result.isPassing ? Color.green : Color.red, lineWidth: 2)
                            .opacity(isAnimating ? 1 : 0)
                            .scaleEffect(isAnimating ? 1 : 0.8)
                    )
                LabeledContent("Status", value: result.isPassing ? "PASS" : "FAIL")
                    .foregroundColor(result.isPassing ? .green : .red)
                    .scaleEffect(isAnimating ? 1 : 0.8)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.3), value: isAnimating)
            }
            if !result.notes.isEmpty {
                Section(header: Text("Notes")) {
                    Text(result.notes)
                }
            }
            if let imageData = result.meterImageData, let uiImage = UIImage(data: imageData) {
                Section(header: Text("Meter Image")) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.blue, lineWidth: 2)
                                .opacity(isAnimating ? 1 : 0)
                        )
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Test Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            debugPrintValues()
            withAnimation(.easeOut(duration: 0.5)) {
                isAnimating = true
            }
        }
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

struct TestDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TestDetailView(result: TestResult(
                id: UUID(),
                testType: .lowFlow,
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
                date: Date(),
                meterImageData: nil,
                meterSize: "1\"",
                meterType: "Neptune",
                meterModel: "Positive Displacement",
                jobNumber: "JOB-001"
            ))
        }
    }
}
