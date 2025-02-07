import SwiftUI
import Charts
import UniformTypeIdentifiers

// MARK: - Export & Chart Types

enum ExportFormat: String, CaseIterable, Identifiable {
    case csv = "CSV"
    case json = "JSON"
    case pdf = "PDF"
    
    var id: Self { self }
}

enum ChartType: String, CaseIterable, Identifiable {
    case bar = "Bar"
    case line = "Line"
    
    var id: Self { self }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems,
                                 applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Analytics Export Document

struct AnalyticsExportDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.commaSeparatedText] }
    var data: Data

    init(data: Data) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.data = data
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}

// MARK: - AnalyticsView

struct AnalyticsView: View {
    @EnvironmentObject var viewModel: TestViewModel

    enum FilterOption: String, CaseIterable, Identifiable {
        case all = "All"
        case lowFlow = "Low Flow"
        case highFlow = "High Flow"

        var id: Self { self }
    }

    @State private var selectedFilter: FilterOption = .all
    @State private var selectedChartType: ChartType = .bar
    @State private var showTrendLine: Bool = false
    @State private var selectedExportFormat: ExportFormat = .csv
    @State private var showShareSheet: Bool = false

    var filteredResults: [TestResult] {
        switch selectedFilter {
        case .all:
            return viewModel.testResults
        case .lowFlow:
            return viewModel.testResults.filter { $0.testType == .lowFlow }
        case .highFlow:
            return viewModel.testResults.filter { $0.testType == .highFlow }
        }
    }

    var averageAccuracy: Double? {
        let results = filteredResults
        guard !results.isEmpty else { return nil }
        let total = results.reduce(0.0) { $0 + $1.reading.accuracy }
        return total / Double(results.count)
    }

    // Use the ChartContentBuilder to build chart marks
    @ChartContentBuilder
    var chartContent: some ChartContent {
        if selectedChartType == .bar {
            ForEach(filteredResults) { result in
                BarMark(
                    x: .value("Date", result.date, unit: .day),
                    y: .value("Accuracy", result.reading.accuracy)
                )
                .foregroundStyle(result.isPassing ? Color.green : Color.red)
                .annotation(position: .top) {
                    Text(String(format: "%.1f%%", result.reading.accuracy))
                        .font(.caption)
                        .foregroundColor(.primary)
                }
            }
        } else {
            ForEach(filteredResults) { result in
                LineMark(
                    x: .value("Date", result.date, unit: .day),
                    y: .value("Accuracy", result.reading.accuracy)
                )
                .foregroundStyle(result.isPassing ? Color.green : Color.red)
            }
        }
    }

    @ChartContentBuilder
    var trendLineContent: some ChartContent {
        if showTrendLine {
            ForEach(trendLineData, id: \.date) { dataPoint in
                LineMark(
                    x: .value("Date", dataPoint.date, unit: .day),
                    y: .value("Trend", dataPoint.average)
                )
                .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                .foregroundStyle(Color.blue)
            }
        }
    }

    var trendLineData: [(date: Date, average: Double)] {
        let sortedResults = filteredResults.sorted { $0.date < $1.date }
        guard !sortedResults.isEmpty else { return [] }
        let average = sortedResults.reduce(0.0) { $0 + $1.reading.accuracy } / Double(sortedResults.count)
        return sortedResults.map { ($0.date, average) }
    }

    func generateCSVData() -> Data? {
        var csvString = "Date,Test Type,Accuracy,Status\n"
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short

        for result in filteredResults {
            let dateStr = dateFormatter.string(from: result.date)
            let type = result.testType.rawValue
            let accuracy = String(format: "%.1f", result.reading.accuracy)
            let status = result.isPassing ? "PASS" : "FAIL"
            csvString += "\(dateStr),\(type),\(accuracy),\(status)\n"
        }
        return csvString.data(using: .utf8)
    }

    func generateJSONData() -> Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try? encoder.encode(filteredResults)
    }

    func generatePDFData() -> Data? {
        let pdfMetaData = [
            kCGPDFContextCreator: "VEROflow-4 Field Tester",
            kCGPDFContextAuthor: "MARS Company",
            kCGPDFContextTitle: "Test Analytics"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let data = renderer.pdfData { context in
            context.beginPage()
            let title = "Test Analytics Summary"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .bold)
            ]
            let titleSize = title.size(withAttributes: attributes)
            let titleRect = CGRect(x: (pageRect.width - titleSize.width) / 2,
                                   y: 50,
                                   width: titleSize.width,
                                   height: titleSize.height)
            title.draw(in: titleRect, withAttributes: attributes)
        }
        return data
    }

    func exportData() -> Data? {
        switch selectedExportFormat {
        case .csv:
            return generateCSVData()
        case .json:
            return generateJSONData()
        case .pdf:
            return generatePDFData()
        }
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Test Accuracy Over Time")
                    .font(.title)
                    .padding(.horizontal)
                Text("Visualize and analyze your test accuracy with interactive charts and trend lines. Customize your view and export data in multiple formats.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)

                HStack {
                    Text("Chart Type:")
                    Picker("Chart Type", selection: $selectedChartType) {
                        ForEach(ChartType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding(.horizontal)

                Toggle("Show Trend Line", isOn: $showTrendLine)
                    .padding(.horizontal)

                Picker("Filter", selection: $selectedFilter) {
                    ForEach(FilterOption.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                HStack {
                    Text("Tests: \(filteredResults.count)")
                    if let avg = averageAccuracy {
                        Text(String(format: "Avg Accuracy: %.1f%%", avg))
                    }
                }
                .font(.subheadline)
                .padding(.horizontal)
                .padding(.top, 4)

                if filteredResults.isEmpty {
                    Spacer()
                    Text("No test results available for the selected filter.")
                        .font(.title2)
                        .foregroundColor(.secondary)
                        .padding()
                    Spacer()
                } else {
                    Chart {
                        chartContent
                        trendLineContent
                    }
                    .frame(height: 300)
                    .padding()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                Spacer()
            }
            .navigationTitle("Analytics")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("Export Format", selection: $selectedExportFormat) {
                            ForEach(ExportFormat.allCases) { format in
                                Text(format.rawValue).tag(format)
                            }
                        }
                        Button(action: { showShareSheet = true }) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let dataToShare = exportData() {
                    ShareSheet(activityItems: [dataToShare])
                } else {
                    Text("Export data not available.")
                }
            }
        }
    }
}

struct AnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = TestViewModel()
        vm.testResults = [
            TestResult(
                id: UUID(), // Added id parameter
                testType: .lowFlow,
                reading: MeterReading(smallMeterStart: 10, smallMeterEnd: 20, largeMeterStart: 0, largeMeterEnd: 0, totalVolume: 10, flowRate: 5),
                notes: "",
                date: Date().addingTimeInterval(-86400),
                meterImageData: nil
            ),
            TestResult(
                id: UUID(), // Added id parameter
                testType: .highFlow,
                reading: MeterReading(smallMeterStart: 15, smallMeterEnd: 25, largeMeterStart: 0, largeMeterEnd: 0, totalVolume: 50, flowRate: 30),
                notes: "",
                date: Date(),
                meterImageData: nil
            )
        ]
        return AnalyticsView().environmentObject(vm)
    }
}
