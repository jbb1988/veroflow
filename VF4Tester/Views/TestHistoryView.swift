import SwiftUI
import UniformTypeIdentifiers
import PDFKit

struct TestHistoryView: View {
    @EnvironmentObject var viewModel: TestViewModel
    @State private var searchText = ""
    @State private var showingDeleteAlert = false
    @State private var selectedResult: TestResult? = nil
    @State private var showingExportSheet = false
    @State private var showingShareSheet = false
    @State private var exportData: Data?
    @State private var exportFileType: UTType = .pdf
    
    enum FilterOption: String, CaseIterable {
        case all = "All Tests"
        case lowFlow = "Low Flow Tests"
        case highFlow = "High Flow Tests"
        case passing = "Passing Tests"
        case failing = "Failed Tests"
    }
    
    var filteredResults: [TestResult] {
        let results = viewModel.testResults
        
        let searchFiltered = results.filter { result in
            if searchText.isEmpty { return true }
            return result.jobNumber.localizedCaseInsensitiveContains(searchText) ||
                   result.meterType.localizedCaseInsensitiveContains(searchText) ||
                   result.meterSize.localizedCaseInsensitiveContains(searchText)
        }
        
        switch viewModel.selectedHistoryFilter {
        case .all:
            return searchFiltered
        case .lowFlow:
            return searchFiltered.filter { $0.testType == .lowFlow }
        case .highFlow:
            return searchFiltered.filter { $0.testType == .highFlow }
        case .passing:
            return searchFiltered.filter { $0.isPassing }
        case .failing:
            return searchFiltered.filter { !$0.isPassing }
        }
    }
    
    var body: some View {
        List {
            // Compact Filter Section
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(FilterOption.allCases, id: \.self) { option in
                                FilterChip(
                                    title: option.rawValue.replacingOccurrences(of: " Tests", with: ""),
                                    icon: iconFor(option),
                                    isSelected: viewModel.selectedHistoryFilter == option
                                ) {
                                    viewModel.selectedHistoryFilter = option
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
                .padding(.vertical, 8)
            }
            
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
                        exportFileType = .pdf
                        exportData = generatePDF()
                        showingShareSheet = true
                    },
                    .default(Text("Export as CSV")) {
                        exportFileType = .commaSeparatedText
                        exportData = generateCSV().data(using: .utf8)
                        showingShareSheet = true
                    },
                    .default(Text("Save to iCloud")) {
                        saveToiCloud()
                    },
                    .cancel()
                ]
            )
        }
        .sheet(isPresented: $showingShareSheet) {
            if let data = exportData {
                ShareSheet(
                    activityItems: [
                        data,
                        UTType.pdf.identifier
                    ]
                )
            }
        }
    }
    
    private func iconFor(_ option: FilterOption) -> String {
        switch option {
        case .all:
            return "list.bullet"
        case .lowFlow:
            return "arrow.down"
        case .highFlow:
            return "arrow.up"
        case .passing:
            return "checkmark"
        case .failing:
            return "xmark"
        }
    }
    
    // MARK: - Export Functions
    
    private func generatePDF() -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "VEROflow-4",
            kCGPDFContextAuthor: "VEROflow-4 Test History"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            let titleFont = UIFont.boldSystemFont(ofSize: 24.0)
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: titleFont
            ]
            
            let title = "VEROflow-4 Test History"
            title.draw(at: CGPoint(x: 50, y: 50), withAttributes: titleAttributes)
            
            let contentFont = UIFont.systemFont(ofSize: 12.0)
            let contentAttributes: [NSAttributedString.Key: Any] = [
                .font: contentFont
            ]
            
            var yPosition: CGFloat = 100
            
            for result in filteredResults {
                let resultText = """
                Date: \(result.date.formatted())
                Test Type: \(result.testType.rawValue)
                Job Number: \(result.jobNumber)
                Meter Size: \(result.meterSize)
                Meter Type: \(result.meterType)
                Accuracy: \(String(format: "%.1f%%", result.reading.accuracy))
                Status: \(result.isPassing ? "PASS" : "FAIL")
                Flow Rate: \(String(format: "%.1f GPM", result.reading.flowRate))
                Total Volume: \(String(format: "%.1f Gallons", result.reading.totalVolume))
                Notes: \(result.notes)
                
                """
                
                resultText.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: contentAttributes)
                yPosition += 150
                
                if yPosition > pageHeight - 100 {
                    context.beginPage()
                    yPosition = 50
                }
            }
        }
        
        return data
    }
    
    private func generateCSV() -> String {
        var csv = "Date,Test Type,Job Number,Meter Size,Meter Type,Accuracy,Status,Flow Rate,Total Volume,Notes\n"
        
        for result in filteredResults {
            let row = [
                result.date.formatted(),
                result.testType.rawValue,
                result.jobNumber,
                result.meterSize,
                result.meterType,
                String(format: "%.1f", result.reading.accuracy),
                result.isPassing ? "PASS" : "FAIL",
                String(format: "%.1f", result.reading.flowRate),
                String(format: "%.1f", result.reading.totalVolume),
                result.notes.replacingOccurrences(of: ",", with: ";")
            ].joined(separator: ",")
            
            csv += row + "\n"
        }
        
        return csv
    }
    
    private func saveToiCloud() {
        guard let containerURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") else {
            print("iCloud not available")
            return
        }
        
        do {
            try FileManager.default.createDirectory(at: containerURL, withIntermediateDirectories: true)
            
            // Save PDF
            let pdfData = generatePDF()
            let pdfURL = containerURL.appendingPathComponent("VEROflow_Test_History_\(Date().formatted()).pdf")
            try pdfData.write(to: pdfURL)
            
            // Save CSV
            let csvString = generateCSV()
            let csvURL = containerURL.appendingPathComponent("VEROflow_Test_History_\(Date().formatted()).csv")
            try csvString.write(to: csvURL, atomically: true, encoding: .utf8)
            
        } catch {
            print("Error saving to iCloud: \(error)")
        }
    }
}

// MARK: - FilterChip Component
struct FilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(title)
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.blue : Color(UIColor.secondarySystemBackground))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(16)
        }
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
                
                StatusBadge(isPassing: result.isPassing)
            }
            
            HStack {
                Label("Job: \(result.jobNumber)", systemImage: "number")
                Spacer()
                Label("\(result.meterSize)", systemImage: "ruler")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            HStack {
                Label(result.meterType, systemImage: "gauge")
                Spacer()
                Text(String(format: "%.1f%%", result.reading.accuracy))
                    .bold()
                    .foregroundColor(result.isPassing ? .green : .red)
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct StatusBadge: View {
    let isPassing: Bool
    
    var body: some View {
        Text(isPassing ? "PASS" : "FAIL")
            .font(.caption)
            .bold()
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isPassing ? Color.green : Color.red)
            .foregroundColor(.white)
            .clipShape(Capsule())
    }
}

struct TestDetailView: View {
    let result: TestResult
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("Test Information") {
                    LabeledContent("Test Type", value: result.testType.rawValue)
                    LabeledContent("Date", value: result.date.formatted())
                    LabeledContent("Job Number", value: result.jobNumber)
                }
                
                Section("Meter Details") {
                    LabeledContent("Size", value: result.meterSize)
                    LabeledContent("Type", value: result.meterType)
                }
                
                Section("Results") {
                    LabeledContent("Accuracy", value: String(format: "%.1f%%", result.reading.accuracy))
                    LabeledContent("Status", value: result.isPassing ? "PASS" : "FAIL")
                }
                
                Section("Readings") {
                    LabeledContent("Flow Rate", value: String(format: "%.1f GPM", result.reading.flowRate))
                    LabeledContent("Total Volume", value: String(format: "%.1f Gallons", result.reading.totalVolume))
                }
                
                if !result.notes.isEmpty {
                    Section("Notes") {
                        Text(result.notes)
                    }
                }
                
                if let imageData = result.meterImageData,
                   let uiImage = UIImage(data: imageData) {
                    Section("Meter Image") {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                    }
                }
            }
            .navigationTitle("Test Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview Provider
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
                    flowRate: 5
                ),
                notes: "Test LowFlow",
                date: Date().addingTimeInterval(-86400),
                meterImageData: nil,
                meterSize: "2\"",
                meterType: "Neptune",
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
                    flowRate: 30
                ),
                notes: "Test HighFlow",
                date: Date(),
                meterImageData: nil,
                meterSize: "3\"",
                meterType: "Sensus",
                jobNumber: "JOB-002"
            )
        ]
        
        return NavigationView {
            TestHistoryView()
                .environmentObject(vm)
        }
    }
}
