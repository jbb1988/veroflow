import SwiftUI
import UniformTypeIdentifiers
import PDFKit

struct TestHistoryView: View {
    @EnvironmentObject var viewModel: TestViewModel
    @State private var searchText = ""
    @State private var selectedResult: TestResult? = nil
    @State private var showingExportSheet = false
    
    // Internal filter state that the user can modify.
    @State private var selectedHistoryFilter: FilterOption
    
    // Filter options.
    enum FilterOption: String, CaseIterable, Identifiable {
        case all = "All Tests"
        case lowFlow = "Low Flow"
        case midFlow = "Mid Flow"
        case highFlow = "High Flow"
        case compound = "Compound"
        case passed = "Passed"
        case failed = "Failed"
        var id: Self { self }
        
        // Colored border similar to Analytics stat cards.
        var borderColor: Color {
            switch self {
            case .all: return .purple
            case .lowFlow: return .blue
            case .midFlow: return .orange
            case .highFlow: return .pink
            case .passed: return .green
            case .failed: return .red
            case .compound: return .gray
            }
        }
    }
    
    enum SortOrder: String, CaseIterable {
        case ascending = "Oldest First"
        case descending = "Newest First"
    }
    
    @State private var selectedSortOrder: SortOrder
    @State private var startDate: Date
    @State private var endDate: Date
    
    // Effective end date.
    var effectiveEndDate: Date {
        max(endDate, Date())
    }
    
    // Export variables.
    @State private var exportedData: Data? = nil
    @State private var showShareSheet = false
    
    // Filtered results.
    var filteredResults: [TestResult] {
        // First filter the results as before
        let filtered = viewModel.testResults.filter { result in
            let inDateRange = (result.date >= startDate) && (result.date <= effectiveEndDate)
            let filterMatch: Bool = {
                switch selectedHistoryFilter {
                case .all:
                    return true
                case .lowFlow:
                    return result.testType == .lowFlow
                case .midFlow:
                    return result.testType == .midFlow
                case .highFlow:
                    return result.testType == .highFlow
                case .compound:
                    return result.reading.readingType == .compound
                case .passed:
                    return result.isPassing
                case .failed:
                    return !result.isPassing
                }
            }()
            let matchesSearch = searchText.isEmpty ||
                result.jobNumber.localizedCaseInsensitiveContains(searchText) ||
                result.meterType.localizedCaseInsensitiveContains(searchText) ||
                result.meterSize.localizedCaseInsensitiveContains(searchText)
            return inDateRange && filterMatch && matchesSearch
        }
        
        // Then sort the filtered results
        return filtered.sorted { first, second in
            switch selectedSortOrder {
            case .ascending:
                return first.date < second.date
            case .descending:
                return first.date > second.date
            }
        }
    }
    
    @State private var isFilterExpanded = false
    
    init(initialFilter: FilterOption = .all) {
        _selectedHistoryFilter = State(initialValue: initialFilter)
        _selectedSortOrder = State(initialValue: .descending)
        _startDate = State(initialValue: Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date())
        _endDate = State(initialValue: Date())
    }
    
    var body: some View {
        VStack {
            // Filters and Date Range.
            DisclosureGroup(
                isExpanded: $isFilterExpanded,
                content: {
                    VStack(spacing: 16) {
                        DetailCard(title: "Filter Options") {
                            let gridFilterOptions: [[FilterOption]] = [
                                [.all],
                                [.lowFlow, .midFlow, .highFlow],
                                [.passed, .failed]
                            ]
                            VStack(spacing: 8) {
                                ForEach(0..<gridFilterOptions.count, id: \.self) { rowIndex in
                                    HStack(spacing: 8) {
                                        ForEach(gridFilterOptions[rowIndex], id: \.self) { option in
                                            Button(action: {
                                                selectedHistoryFilter = option
                                            }) {
                                                Text(option.rawValue)
                                                    .font(.caption)
                                                    .padding(6)
                                                    .frame(maxWidth: .infinity)
                                                    .background(selectedHistoryFilter == option ? option.borderColor.opacity(0.2) : Color(UIColor.secondarySystemBackground))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 8)
                                                            .stroke(option.borderColor, lineWidth: 2)
                                                    )
                                                    .cornerRadius(8)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        DetailCard(title: "Sort Order") {
                            HStack {
                                ForEach(SortOrder.allCases, id: \.self) { order in
                                    Button(action: {
                                        selectedSortOrder = order
                                    }) {
                                        Text(order.rawValue)
                                            .font(.caption)
                                            .padding(6)
                                            .frame(maxWidth: .infinity)
                                            .background(selectedSortOrder == order ? Color.blue.opacity(0.2) : Color(UIColor.secondarySystemBackground))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.blue, lineWidth: 2)
                                            )
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        
                        DetailCard(title: "Date Range") {
                            DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                            DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                        }
                    }
                },
                label: {
                    HStack {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.title3)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Filters & Sort")
                                .font(.headline)
                            Text("\(selectedHistoryFilter.rawValue) • \(selectedSortOrder.rawValue)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: isFilterExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                            .foregroundColor(.blue)
                            .animation(.easeInOut, value: isFilterExpanded)
                    }
                    .padding(12)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
                }
            )
            .padding(.horizontal)
            .animation(.easeInOut, value: isFilterExpanded)
            
            // List of Test Results.
            List {
                ForEach(filteredResults) { result in
                    TestResultRow(result: result)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedResult = result
                        }
                }
                .onDelete { indexSet in
                    let resultsToDelete = indexSet.map { filteredResults[$0] }
                    for result in resultsToDelete {
                        if let index = viewModel.testResults.firstIndex(where: { $0.id == result.id }) {
                            viewModel.testResults.remove(at: index)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search by job number, meter type, or size")
        }
        .navigationTitle("Test History")
        .sheet(item: $selectedResult) { result in
            TestDetailView(result: result)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingExportSheet = true }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .actionSheet(isPresented: $showingExportSheet) {
            ActionSheet(
                title: Text("Export Test History"),
                buttons: [
                    .default(Text("Export as PDF")) {
                        if let pdfData = generatePDF() {
                            exportedData = pdfData
                            showShareSheet = true
                        }
                    },
                    .default(Text("Export as CSV")) {
                        if let csvData = generateCSV() {
                            exportedData = csvData
                            showShareSheet = true
                        }
                    },
                    .cancel()
                ]
            )
        }
        .sheet(isPresented: $showShareSheet, onDismiss: {
            exportedData = nil
        }) {
            if let data = exportedData {
                #if os(iOS)
                ShareSheet(activityItems: [data])
                #endif
            }
        }
    }
    
    // MARK: - Export Functions
    func generatePDF() -> Data? {
        let pdfMetaData = [
            kCGPDFContextCreator: "VF4Tester",
            kCGPDFContextAuthor: "VF4Tester App"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        let data = renderer.pdfData { context in
            context.beginPage()
            let text = generateExportSummary()
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12)
            ]
            text.draw(in: CGRect(x: 20, y: 20, width: pageRect.width - 40, height: pageRect.height - 40), withAttributes: attributes)
        }
        return data
    }
    
    func generateCSV() -> Data? {
        var csvString = "Date,Test Type,Accuracy,Status,Meter Size,Meter Type,Meter Model,Job Number\n"
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        for result in filteredResults {
            let row = [
                df.string(from: result.date),
                result.testType.rawValue,
                String(format: "%.1f", result.reading.accuracy),
                result.isPassing ? "PASS" : "FAIL",
                result.meterSize,
                result.meterType,
                result.meterModel,
                result.jobNumber
            ].joined(separator: ",")
            csvString += row + "\n"
        }
        return csvString.data(using: .utf8)
    }
    
    func generateExportSummary() -> String {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        var summary = "Test History Export\n\n"
        summary += "Date Range: \(df.string(from: startDate)) - \(df.string(from: effectiveEndDate))\n"
        summary += "Total Tests: \(filteredResults.count)\n\n"
        summary += "Tests:\n"
        for result in filteredResults.sorted(by: { $0.date < $1.date }) {
            summary += "\(df.string(from: result.date)): \(result.testType.rawValue), Accuracy: \(String(format: "%.1f%%", result.reading.accuracy)), \(result.isPassing ? "PASS" : "FAIL")\n"
        }
        return summary
    }
}

struct TestResultRow: View {
    let result: TestResult
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(result.testType.rawValue)
                        .font(.headline)
                    Text(result.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(String(format: "%.1f%%", result.reading.accuracy))
                    .font(.title3)
                    .bold()
                    .foregroundColor(result.isPassing ? .green : .red)
            }
            HStack {
                Text("Start: \(result.reading.smallMeterStart, specifier: "%.1f")")
                    .font(.caption)
                Spacer()
                Text("End: \(result.reading.smallMeterEnd, specifier: "%.1f")")
                    .font(.caption)
                Spacer()
                Text("Volume: \(result.reading.totalVolume, specifier: "%.1f") Gal")
                    .font(.caption)
            }
        }
        .padding(.vertical, 4)
    }
}

struct TestHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = TestViewModel()
        vm.testResults = [
            TestResult(
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
                notes: "Test LowFlow",
                date: Date().addingTimeInterval(-86400),
                meterImageData: nil,
                meterSize: "2\"",
                meterType: "Neptune",
                meterModel: "Positive Displacement",
                jobNumber: "JOB-001"
            ),
            TestResult(
                id: UUID(),
                testType: .highFlow,
                reading: MeterReading(
                    smallMeterStart: 15,
                    smallMeterEnd: 25,
                    largeMeterStart: 0,
                    largeMeterEnd: 0,
                    totalVolume: 50,
                    flowRate: 30,
                    readingType: .small
                ),
                notes: "Test HighFlow",
                date: Date(),
                meterImageData: nil,
                meterSize: "3\"",
                meterType: "Sensus",
                meterModel: "Multi-Jet",
                jobNumber: "JOB-002"
            )
        ]
        return NavigationView {
            TestHistoryView()
                .environmentObject(vm)
        }
    }
}
