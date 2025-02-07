import SwiftUI
import UIKit
import CoreGraphics

// Note: We don't need an explicit import for TestViewModel, MeterReading, or TestResult
// since they're in the same module, but we're importing UIKit for UIActivityViewController
// and CoreGraphics for PDF generation

// MARK: - Export Options

enum ExportOption: String, CaseIterable {
    case csv = "Export as CSV"
    case pdf = "Export as PDF"
    case icloud = "Export to iCloud"
}

// MARK: - Components

struct DetailCard<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        GroupBox(label: 
            Text(title)
                .font(.headline)
                .textCase(.uppercase)
                .foregroundColor(.secondary)
        ) {
            content
                .padding(.top, 8)
        }
        .groupBoxStyle(CardGroupBoxStyle())
    }
}

struct CardGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: GroupBoxStyleConfiguration) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            configuration.label
            configuration.content
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct MeterReadingRow: View {
    let label: String
    let value: Double
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(String(format: "%.1f", value))
                .font(.system(.body, design: .monospaced))
                .fontWeight(.medium)
        }
    }
}

struct TestHistoryView: View {
    @EnvironmentObject var viewModel: TestViewModel
    @State private var searchText: String = ""
    @State private var showExportActionSheet: Bool = false
    @State private var showShareSheet: Bool = false
    @State private var exportData: Data? = nil

    private let dateFormatter: DateFormatter = {
         let formatter = DateFormatter()
         formatter.dateStyle = .short
         formatter.timeStyle = .short
         return formatter
    }()

    var filteredResults: [TestResult] {
        if searchText.isEmpty {
            return viewModel.testResults
        } else {
            return viewModel.testResults.filter { result in
                result.testType.rawValue.localizedCaseInsensitiveContains(searchText) ||
                result.notes.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        List {
            if filteredResults.isEmpty {
                Text("No test results available.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(filteredResults) { result in
                    NavigationLink(destination: TestDetailView(testResult: result)) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(result.testType.rawValue)
                                .font(.headline)
                            Text("Accuracy: \(String(format: "%.1f%%", result.reading.accuracy))")
                                .font(.subheadline)
                                .foregroundColor(result.isPassing ? .green : .red)
                            HStack {
                                Text("Volume: \(result.reading.totalVolume, specifier: "%.1f")")
                                Spacer()
                                Text("Flow Rate: \(result.reading.flowRate, specifier: "%.1f") GPM")
                            }
                            .font(.caption)
                            Text("Date: \(result.date, formatter: dateFormatter)")
                                .font(.caption)
                        }
                        .padding(.vertical, 5)
                    }
                }
                .onDelete { indexSet in
                    let sourceIndices = indexSet.map { filteredResults[$0] }
                        .compactMap { result in
                            viewModel.testResults.firstIndex(where: { $0.id == result.id })
                        }
                    viewModel.deleteTest(at: IndexSet(sourceIndices))
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .searchable(text: $searchText, prompt: "Search tests")
        .navigationTitle("Test History")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showExportActionSheet = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .alert("Export Options", isPresented: $showExportActionSheet) {
            Button("CSV") { exportAndShare(.csv) }
            Button("PDF") { exportAndShare(.pdf) }
            Button("iCloud") { exportAndShare(.icloud) }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Choose an export format")
        }
        .sheet(isPresented: $showShareSheet) {
            if let data = exportData {
                CustomShareSheet(activityItems: [data])
            } else {
                VStack {
                    Text("Export data not available.")
                    Button("Dismiss") { showShareSheet = false }
                }
            }
        }
    }
    
    private func exportAndShare(_ format: ExportOption) {
        switch format {
        case .csv:
            exportData = generateCSVForResults(filteredResults)
        case .pdf:
            exportData = generatePDFForResults(filteredResults)
        case .icloud:
            exportData = generateCSVForResults(filteredResults)
        }
        if exportData != nil {
            showShareSheet = true
        }
    }
    
    func generateCSVForResults(_ results: [TestResult]) -> Data? {
        var csvString = "Test Type,Small Start,Small End,Large Start,Large End,Total Volume,Flow Rate,Accuracy,Notes,Date\n"
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        for result in results {
            let dateStr = df.string(from: result.date)
            let line = "\(result.testType.rawValue),\(result.reading.smallMeterStart),\(result.reading.smallMeterEnd),\(result.reading.largeMeterStart),\(result.reading.largeMeterEnd),\(result.reading.totalVolume),\(result.reading.flowRate),\(String(format: "%.1f", result.reading.accuracy)),\(result.notes),\(dateStr)\n"
            csvString += line
        }
        return csvString.data(using: .utf8)
    }
    
    func generatePDFForResults(_ results: [TestResult]) -> Data? {
        let pdfMetaData = [
            kCGPDFContextCreator: "VEROflow-4 Field Tester",
            kCGPDFContextAuthor: "MARS Company",
            kCGPDFContextTitle: "Test History"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            let title = "Test History"
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .bold)
            ]
            let titleSize = title.size(withAttributes: titleAttributes)
            let titleRect = CGRect(x: (pageRect.width - titleSize.width) / 2,
                                   y: 50,
                                   width: titleSize.width,
                                   height: titleSize.height)
            title.draw(in: titleRect, withAttributes: titleAttributes)
            
            var yPosition = titleRect.maxY + 20
            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12)
            ]
            
            for result in results {
                let line = "\(result.testType.rawValue) | \(String(format: "%.1f", result.reading.accuracy))% | \(result.date)"
                let lineSize = line.size(withAttributes: textAttributes)
                if yPosition + lineSize.height > pageRect.height - 40 {
                    context.beginPage()
                    yPosition = 40
                }
                let lineRect = CGRect(x: 40, y: yPosition, width: pageRect.width - 80, height: lineSize.height)
                line.draw(in: lineRect, withAttributes: textAttributes)
                yPosition += lineSize.height + 10
            }
        }
        return data
    }
}

struct TestDetailView: View {
    var testResult: TestResult
    @State private var showShareSheet: Bool = false
    @State private var exportData: Data? = nil

    private let df: DateFormatter = {
         let formatter = DateFormatter()
         formatter.dateStyle = .long
         formatter.timeStyle = .short
         return formatter
    }()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header Card
                DetailCard(title: "Test Information") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(testResult.testType.rawValue)
                                .font(.title2)
                                .fontWeight(.bold)
                            Spacer()
                            Text(testResult.isPassing ? "PASS" : "FAIL")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(testResult.isPassing ? Color.green : Color.red)
                                .clipShape(Capsule())
                        }
                        
                        Text(df.string(from: testResult.date))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Accuracy Card
                DetailCard(title: "Results") {
                    VStack(spacing: 8) {
                        Text("\(String(format: "%.1f%%", testResult.reading.accuracy))")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(testResult.isPassing ? .green : .red)
                        Text("Accuracy")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                
                // Meter Readings Card
                DetailCard(title: "Meter Readings") {
                    VStack(spacing: 12) {
                        Group {
                            MeterReadingRow(label: "Small Meter Start:", value: testResult.reading.smallMeterStart)
                            MeterReadingRow(label: "Small Meter End:", value: testResult.reading.smallMeterEnd)
                            Divider()
                            MeterReadingRow(label: "Large Meter Start:", value: testResult.reading.largeMeterStart)
                            MeterReadingRow(label: "Large Meter End:", value: testResult.reading.largeMeterEnd)
                            Divider()
                            MeterReadingRow(label: "Total Volume:", value: testResult.reading.totalVolume)
                            MeterReadingRow(label: "Flow Rate (GPM):", value: testResult.reading.flowRate)
                        }
                    }
                }
                
                // Notes Card
                if !testResult.notes.isEmpty {
                    DetailCard(title: "Notes") {
                        Text(testResult.notes)
                            .font(.body)
                    }
                }
            }
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Test Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    exportData = generateCSVForResult(testResult)
                    showShareSheet = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let data = exportData {
                CustomShareSheet(activityItems: [data])
            } else {
                VStack {
                    Text("Export data not available.")
                    Button("Dismiss") { showShareSheet = false }
                }
            }
        }
    }
    
    func generateCSVForResult(_ result: TestResult) -> Data? {
        var csvString = "Test Type,Small Start,Small End,Large Start,Large End,Total Volume,Flow Rate,Accuracy,Notes,Date\n"
        let dateStr = df.string(from: result.date)
        let line = "\(result.testType.rawValue),\(result.reading.smallMeterStart),\(result.reading.smallMeterEnd),\(result.reading.largeMeterStart),\(result.reading.largeMeterEnd),\(result.reading.totalVolume),\(result.reading.flowRate),\(String(format: "%.1f", result.reading.accuracy)),\(result.notes),\(dateStr)\n"
        csvString += line
        return csvString.data(using: .utf8)
    }
}

struct CustomShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems,
                                 applicationActivities: applicationActivities)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct TestHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = TestViewModel()
        vm.testResults = [
            TestResult(
                id: UUID(),
                testType: .lowFlow,
                reading: MeterReading(smallMeterStart: 10, smallMeterEnd: 20, largeMeterStart: 0, largeMeterEnd: 0, totalVolume: 10, flowRate: 5),
                notes: "Test LowFlow",
                date: Date().addingTimeInterval(-86400),
                meterImageData: nil
            ),
            TestResult(
                id: UUID(),
                testType: .highFlow,
                reading: MeterReading(smallMeterStart: 15, smallMeterEnd: 25, largeMeterStart: 0, largeMeterEnd: 0, totalVolume: 50, flowRate: 30),
                notes: "Test HighFlow",
                date: Date(),
                meterImageData: nil
            )
        ]
        return TestHistoryView().environmentObject(vm)
    }
}
