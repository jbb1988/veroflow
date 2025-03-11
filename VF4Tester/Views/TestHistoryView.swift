import SwiftUI
import UniformTypeIdentifiers
import PDFKit
import UIKit

struct TestHistoryView: View {
    @EnvironmentObject var viewModel: TestViewModel
    
    // Local State
    @State private var searchText = ""
    @State private var selectedResult: TestResult? = nil
    @State private var showingExportSheet = false
    
    @State private var selectedHistoryFilter: FilterOption
    @State private var selectedSortOrder: SortOrder
    @State private var selectedMeterSize: MeterSizeFilter
    @State private var selectedManufacturer: MeterManufacturerFilter
    @State private var startDate: Date
    @State private var endDate: Date
    
    @State private var isFilterExpanded = false
    @State private var exportedData: URL? = nil
    @State private var showShareSheet = false
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showingExportAllSheet = false
    @State private var exportAllData: URL? = nil
    @State private var showExportAllShareSheet = false
    @State private var documentController: UIDocumentInteractionController?
    @State private var exportURL: URL?
    
    // MARK: - Filter and Sort Enums
    enum FilterOption: String, CaseIterable, Identifiable {
        case all = "All Tests"
        case lowFlow = "Low Flow"
        case midFlow = "Mid Flow"
        case highFlow = "High Flow"
        case compound = "Compound"
        case passed = "Passed"
        case failed = "Failed"
        
        var id: Self { self }
        
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
    
    enum MeterSizeFilter: String, CaseIterable, Identifiable {
        case all = "All Sizes"
        case size5_8 = "5/8"
        case size3_4 = "3/4"
        case size1 = "1"
        case size1_5 = "1-1/2"
        case size2 = "2"
        case size3 = "3"
        case size4 = "4"
        case size6 = "6"
        case size8 = "8"
        case custom = "Custom"
        
        var id: Self { self }
    }
    
    enum MeterManufacturerFilter: String, CaseIterable, Identifiable {
        case all = "All Manufacturers"
        case sensus = "Sensus"
        case neptune = "Neptune"
        case badger = "Badger"
        case mueller = "Mueller"
        case master = "Master Meter"
        case elster = "Elster"
        case kamstrup = "Kamstrup"
        case custom = "Other"
        
        var id: Self { self }
    }
    
    // MARK: - Computed Properties
    var effectiveEndDate: Date {
        max(endDate, Date())
    }
    
    var filteredResults: [TestResult] {
        let filtered = viewModel.testResults.filter { result in
            let inDateRange = (result.date >= startDate) && (result.date <= effectiveEndDate)
            
            let filterMatch: Bool = {
                switch selectedHistoryFilter {
                case .all: return true
                case .lowFlow: return result.testType == .lowFlow
                case .midFlow: return result.testType == .midFlow
                case .highFlow: return result.testType == .highFlow
                case .compound: return result.reading.readingType == .compound
                case .passed: return result.isPassing
                case .failed: return !result.isPassing
                }
            }()
            
            let meterSizeMatch: Bool = {
                switch selectedMeterSize {
                case .all: return true
                case .size5_8: return result.meterSize.contains("5/8") || result.meterSize.contains("0.625")
                case .size3_4: return result.meterSize.contains("3/4") || result.meterSize.contains("0.75")
                case .size1: return result.meterSize.contains("1\"") && !result.meterSize.contains("1-")
                case .size1_5: return result.meterSize.contains("1-1/2") || result.meterSize.contains("1.5")
                case .size2: return result.meterSize.contains("2")
                case .size3: return result.meterSize.contains("3")
                case .size4: return result.meterSize.contains("4")
                case .size6: return result.meterSize.contains("6")
                case .size8: return result.meterSize.contains("8")
                case .custom: return true
                }
            }()
            
            let manufacturerMatch: Bool = {
                switch selectedManufacturer {
                case .all: return true
                case .sensus: return result.meterType.lowercased().contains("sensus")
                case .neptune: return result.meterType.lowercased().contains("neptune")
                case .badger: return result.meterType.lowercased().contains("badger")
                case .mueller: return result.meterType.lowercased().contains("mueller")
                case .master: return result.meterType.lowercased().contains("master")
                case .elster: return result.meterType.lowercased().contains("elster")
                case .kamstrup: return result.meterType.lowercased().contains("kamstrup")
                case .custom: return true
                }
            }()
            
            let matchesSearch = searchText.isEmpty
                || result.jobNumber.localizedCaseInsensitiveContains(searchText)
                || result.meterType.localizedCaseInsensitiveContains(searchText)
                || result.meterSize.localizedCaseInsensitiveContains(searchText)
                || result.meterModel.localizedCaseInsensitiveContains(searchText)
                || (result.notes.isEmpty ? false : result.notes.localizedCaseInsensitiveContains(searchText))
                || String(format: "%.1f", result.reading.accuracy).localizedCaseInsensitiveContains(searchText)
                || String(format: "%.1f", result.reading.totalVolume).localizedCaseInsensitiveContains(searchText)
                || result.testType.rawValue.localizedCaseInsensitiveContains(searchText)
                || (result.isPassing ? "pass" : "fail").localizedCaseInsensitiveContains(searchText)
            
            return inDateRange && filterMatch && meterSizeMatch && manufacturerMatch && matchesSearch
        }
        
        return filtered.sorted { first, second in
            switch selectedSortOrder {
            case .ascending: return first.date < second.date
            case .descending: return first.date > second.date
            }
        }
    }
    
    var sortedResults: [TestResult] {
        filteredResults
    }
    
    // MARK: - Init
    init(initialFilter: FilterOption = .all) {
        _selectedHistoryFilter = State(initialValue: initialFilter)
        _selectedSortOrder = State(initialValue: .descending)
        _selectedMeterSize = State(initialValue: .all)
        _selectedManufacturer = State(initialValue: .all)
        _startDate = State(initialValue: Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date())
        _endDate = State(initialValue: Date())
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    Color.clear
                        .frame(height: 100)
                    
                    SearchBar(text: $searchText)
                        .padding(Edge.Set.horizontal)
                        .padding(Edge.Set.vertical, 8)
                        .background(Color.black)
                    
                    CompactFilterPill(
                        isExpanded: $isFilterExpanded,
                        selectedFilter: $selectedHistoryFilter,
                        selectedSort: $selectedSortOrder,
                        startDate: $startDate,
                        endDate: $endDate,
                        selectedMeterSize: $selectedMeterSize,
                        selectedManufacturer: $selectedManufacturer
                    )
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.black)
                    
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            if filteredResults.isEmpty {
                                Text("No test results found")
                                    .foregroundColor(.secondary)
                                    .padding(.top, 40)
                            } else {
                                ForEach(filteredResults) { result in
                                    Button {
                                        selectedResult = result
                                    } label: {
                                        TestResultRow(result: result)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                .onDelete { indexSet in
                                    let toDelete = indexSet.map { filteredResults[$0] }
                                    for result in toDelete {
                                        if let index = viewModel.testResults.firstIndex(where: { $0.id == result.id }) {
                                            viewModel.testResults.remove(at: index)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical)
                    }
                }
                
                Button(action: {
                    showingExportAllSheet = true
                }) {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 60, height: 60)
                        .overlay {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.white)
                                .font(.system(size: 24))
                        }
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
            
            .sheet(item: $selectedResult) { result in
                TestDetailView(result: result)
            }
            .actionSheet(isPresented: $showingExportSheet) {
                ActionSheet(
                    title: Text("Export Test History"),
                    buttons: [
                        .default(Text("Export as PDF")) {
                            if let url = generatePDF() {
                                exportedData = url
                                showShareSheet = true
                            }
                        },
                        .default(Text("Export as CSV")) {
                            if let url = generateCSV() {
                                exportedData = url
                                showShareSheet = true
                            }
                        },
                        .cancel()
                    ]
                )
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = exportedData {
                    ShareSheet(activityItems: [url])
                }
            }
            .actionSheet(isPresented: $showingExportAllSheet) {
                ActionSheet(
                    title: Text("Export All Test History"),
                    buttons: [
                        .default(Text("Export as PDF")) {
                            if let url = generatePDF() {
                                exportAllData = url
                                showExportAllShareSheet = true
                            }
                        },
                        .default(Text("Export as CSV")) {
                            if let url = generateCSV() {
                                exportAllData = url
                                showExportAllShareSheet = true
                            }
                        },
                        .cancel()
                    ]
                )
            }
            .sheet(isPresented: $showExportAllShareSheet) {
                if let url = exportAllData {
                    ShareSheet(activityItems: [url])
                }
            }
        }
    }
    
    // MARK: - Export PDF & CSV
    func generatePDF() -> URL? {
        guard let pdfData = generatePDFData() else { return nil }
        let fileName = "test_history_\(Date().timeIntervalSince1970).pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try? pdfData.write(to: url)
        return url
    }

    func generateCSV() -> URL? {
        guard let csvData = generateCSVData() else { return nil }
        let fileName = "test_history_\(Date().timeIntervalSince1970).csv"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try? csvData.write(to: url)
        return url
    }

    func generatePDFData() -> Data? {
        let pdfMetaData = [
            kCGPDFContextCreator: "MARS Company",
            kCGPDFContextAuthor: "VEROflow-4 Test System",
            kCGPDFContextTitle: "Test History Report",
            kCGPDFContextKeywords: "VEROflow, Test Results, Water Meter Testing"
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        // Landscape 11 x 8.5 inches, 72 points/inch
        let pageRect = CGRect(x: 0, y: 0, width: 11 * 72.0, height: 8.5 * 72.0)
        let margin: CGFloat = 36.0
        
        let df = DateFormatter()
        df.dateFormat = "MM/dd/yy"
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        // New headers without Time column and updated column widths:
        let headers = ["Date", "Serial Number", "Test Type", "Meter Size", "Meter MFG", "Accuracy", "Status", "Notes"]
        let columnWidths: [CGFloat] = [70, 100, 80, 60, 60, 60, 60, 210]
        let tableWidth = columnWidths.reduce(0, +)
        
        var currentY: CGFloat = margin
        var currentPage = 1
        
        func drawPageHeader(context: UIGraphicsPDFRendererContext) {
            let headerGradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    UIColor(red: 0.0, green: 0.2, blue: 0.4, alpha: 1.0).cgColor,
                    UIColor(red: 0.0, green: 0.1, blue: 0.2, alpha: 1.0).cgColor
                ] as CFArray,
                locations: [0, 1]
            )!
            
            let headerRect = CGRect(x: 0, y: 0, width: pageRect.width, height: 80)
            context.cgContext.drawLinearGradient(
                headerGradient,
                start: CGPoint(x: 0, y: 0),
                end: CGPoint(x: 0, y: 80),
                options: []
            )
            
            let title = "VEROflow-4 Test Results"
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.white
            ]
            title.draw(
                at: CGPoint(x: margin, y: margin),
                withAttributes: titleAttributes
            )
            
            let pageText = "Page \(currentPage)"
            let pageAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.white
            ]
            pageText.draw(
                at: CGPoint(x: pageRect.width - margin - 50, y: margin),
                withAttributes: pageAttributes
            )
            
            // Reset currentY to start below the header
            currentY = 100
        }
        
        func drawTableHeader(context: UIGraphicsPDFRendererContext) {
            // Draw the table header background
            let headerBackgroundRect = CGRect(x: margin, y: currentY - 5, width: tableWidth, height: 25)
            context.cgContext.setFillColor(
                UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0).cgColor
            )
            context.cgContext.fill(headerBackgroundRect)
            
            var xPos = margin
            for (index, header) in headers.enumerated() {
                let headerAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 12),
                    .foregroundColor: UIColor.black
                ]
                
                let cellRect = CGRect(x: xPos, y: currentY - 5, width: columnWidths[index], height: 25)
                context.cgContext.stroke(cellRect)
                
                let textRect = CGRect(x: xPos + 5, y: currentY, width: columnWidths[index] - 10, height: 20)
                let headerAttributedString = NSAttributedString(string: header, attributes: headerAttributes)
                headerAttributedString.draw(in: textRect)
                
                xPos += columnWidths[index]
            }
            // Stroke the full header rectangle to ensure complete borders
            let fullHeaderRect = CGRect(x: margin, y: currentY - 5, width: tableWidth, height: 25)
            context.cgContext.stroke(fullHeaderRect)
            
            currentY += 25
        }
        
        return renderer.pdfData { context in
            context.beginPage()
            drawPageHeader(context: context)
            
            // Print summary info
            let summaryAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.black
            ]
            
            let summaryTexts = [
                "Date Range: \(df.string(from: startDate)) - \(df.string(from: effectiveEndDate))",
                "Total Tests: \(filteredResults.count)",
                "Passed Tests: \(filteredResults.filter { $0.isPassing }.count)",
                "Failed Tests: \(filteredResults.filter { !$0.isPassing }.count)"
            ]
            
            for text in summaryTexts {
                text.draw(
                    at: CGPoint(x: margin, y: currentY),
                    withAttributes: summaryAttributes
                )
                currentY += 20
            }
            
            currentY += 20
            drawTableHeader(context: context)
            
            // Attributes for row text
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            paragraphStyle.lineBreakMode = .byWordWrapping
            
            let baseAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor.black,
                .paragraphStyle: paragraphStyle
            ]
            
            // Iterate through filtered results
            for result in filteredResults {
                // Build row data without time column
                let rowData = [
                    df.string(from: result.date),
                    result.jobNumber,
                    result.testType.rawValue,
                    result.meterSize,
                    result.meterType,
                    String(format: "%.1f%%", result.reading.accuracy),
                    result.isPassing ? "PASS" : "FAIL",
                    result.notes.isEmpty ? "-" : result.notes
                ]
                
                // Compute dynamic row height by measuring each cell's text.
                // For the Notes column (last column), add extra padding to avoid truncation.
                var dynamicRowHeight: CGFloat = 0
                for (i, text) in rowData.enumerated() {
                    let extraPadding: CGFloat = (i == headers.count - 1) ? 10 : 0
                    let boundingRect = (text as NSString).boundingRect(
                        with: CGSize(width: columnWidths[i] - 10, height: .greatestFiniteMagnitude),
                        options: .usesLineFragmentOrigin,
                        attributes: baseAttributes,
                        context: nil
                    )
                    dynamicRowHeight = max(dynamicRowHeight, boundingRect.height + 10 + extraPadding)
                }
                dynamicRowHeight = max(dynamicRowHeight, 40)
                
                // Check if this row fits on the current page; if not, start a new page.
                if currentY + dynamicRowHeight > pageRect.height - margin {
                    self.drawFooter(context: context, pageRect: pageRect)
                    currentPage += 1
                    context.beginPage()
                    drawPageHeader(context: context)
                    drawTableHeader(context: context)
                }
                
                // Background color for row (light green for pass, light red for fail)
                let rowBackground = result.isPassing
                    ? UIColor(red: 0.9, green: 1.0, blue: 0.9, alpha: 0.2)
                    : UIColor(red: 1.0, green: 0.9, blue: 0.9, alpha: 0.2)
                
                let rowRect = CGRect(x: margin, y: currentY - 5, width: tableWidth, height: dynamicRowHeight)
                context.cgContext.setFillColor(rowBackground.cgColor)
                context.cgContext.fill(rowRect)
                
                // Draw cell borders and text
                var xPos = margin
                for (index, data) in rowData.enumerated() {
                    let cellRect = CGRect(x: xPos, y: currentY - 5, width: columnWidths[index], height: dynamicRowHeight)
                    context.cgContext.stroke(cellRect)
                    
                    let textRect = CGRect(x: xPos + 5, y: currentY, width: columnWidths[index] - 10, height: dynamicRowHeight - 10)
                    let attributedString = NSAttributedString(string: data, attributes: baseAttributes)
                    attributedString.draw(in: textRect)
                    
                    xPos += columnWidths[index]
                }
                
                currentY += dynamicRowHeight + 10
            }
            
            self.drawFooter(context: context, pageRect: pageRect)
        }
    }
    
    func generateCSVData() -> Data? {
        let df = DateFormatter()
        df.dateFormat = "MM/dd/yy h:mm a"
        
        var csvString = "Date,Test Type,Accuracy,Status,Total Volume,Meter Size,Meter MFG,Meter Model,Serial Number\n"
        for result in filteredResults {
            let row = [
                df.string(from: result.date),
                result.testType.rawValue,
                String(format: "%.1f%%", result.reading.accuracy),
                result.isPassing ? "PASS" : "FAIL",
                String(format: "%.1f Gal", result.reading.totalVolume),
                result.meterSize,
                result.meterType,
                result.meterModel,
                result.jobNumber
            ].map { "\"\($0)\"" }.joined(separator: ",")
            csvString += row + "\n"
        }
        
        return csvString.data(using: .utf8)
    }
    
    // MARK: - Footer Drawing Helper
    func drawFooter(context: UIGraphicsPDFRendererContext, pageRect: CGRect) {
        let footerText = "VEROflow-4 Test Report"
        let footerAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.gray
        ]
        let textSize = footerText.size(withAttributes: footerAttributes)
        let textRect = CGRect(
            x: pageRect.width - textSize.width - 20,
            y: pageRect.height - textSize.height - 20,
            width: textSize.width,
            height: textSize.height
        )
        footerText.draw(in: textRect, withAttributes: footerAttributes)
    }
    
    // MARK: - TestResultRow
    struct TestResultRow: View {
        let result: TestResult
        @State private var isMenuExpanded = false
        @EnvironmentObject var viewModel: TestViewModel
        @State private var showShareSheet = false
        @State private var exportURL: URL?
        
        let menuActions = [
            ("trash", Color.red),
            ("square.and.arrow.up", Color.blue),
            ("printer", Color.purple),
            ("doc", Color.green),
            ("doc.text.fill", Color.orange)
        ]
        
        var body: some View {
            HStack(spacing: 16) {
                Circle()
                    .fill(result.isPassing ? Color.green : Color.red)
                    .frame(width: 8, height: 8)
                    .padding(4)
                    .background(
                        Circle()
                            .fill(result.isPassing ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                    )
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(result.testType.rawValue)
                            .font(.headline)
                        Spacer()
                        Text(String(format: "%.1f%%", result.reading.accuracy))
                            .font(.title3)
                            .bold()
                            .foregroundColor(result.isPassing ? .green : .red)
                    }
                    
                    Text(result.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 12) {
                        Label(
                            String(format: "%.1f", result.reading.smallMeterStart),
                            systemImage: "arrow.forward.circle.fill"
                        )
                        .foregroundColor(.blue)
                        
                        Label(
                            String(format: "%.1f", result.reading.smallMeterEnd),
                            systemImage: "arrow.backward.circle.fill"
                        )
                        .foregroundColor(.purple)
                        
                        Label(
                            String(format: "%.1f Gal", result.reading.totalVolume),
                            systemImage: "drop.fill"
                        )
                        .foregroundColor(.cyan)
                    }
                    .font(.footnote)
                }
                
                ZStack {
                    ForEach(0..<menuActions.count, id: \.self) { index in
                        Circle()
                            .fill(menuActions[index].1.gradient)
                            .frame(width: 32, height: 32)
                            .overlay {
                                if index == 3 {
                                    Text("PDF")
                                        .font(.system(size: 12))
                                        .foregroundColor(.white)
                                } else if index == 4 {
                                    Text("CSV")
                                        .font(.system(size: 12))
                                        .foregroundColor(.white)
                                } else {
                                    Image(systemName: menuActions[index].0)
                                        .foregroundColor(.white)
                                        .font(.system(size: 14))
                                }
                            }
                            .offset(x: isMenuExpanded ? -CGFloat(index + 1) * 40 : 0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isMenuExpanded)
                            .onTapGesture {
                                handleMenuAction(index)
                            }
                    }
                    
                    Button {
                        withAnimation {
                            isMenuExpanded.toggle()
                        }
                    } label: {
                        Image("Drop")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .rotationEffect(.degrees(isMenuExpanded ? 180 : 0))
                    }
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.secondarySystemBackground))
            )
            .contentShape(Rectangle())
            .sheet(isPresented: $showShareSheet, onDismiss: {
                exportURL = nil
            }) {
                if let url = exportURL {
                    ShareSheet(activityItems: [url])
                }
            }
        }
        
        private func handleMenuAction(_ index: Int) {
            switch index {
            case 0: // Delete
                if let idx = viewModel.testResults.firstIndex(where: { $0.id == result.id }) {
                    viewModel.testResults.remove(at: idx)
                }
            case 1: // Share
                if let pdfData = generatePDFForSingleTest() {
                    let url = FileManager.default.temporaryDirectory.appendingPathComponent("test_result_\(result.date.timeIntervalSince1970).pdf")
                    try? pdfData.write(to: url)
                    exportURL = url
                    showShareSheet = true
                }
            case 2: // Print
                if let pdfData = generatePDFForSingleTest(),
                   let _ = PDFDocument(data: pdfData) {
                    let printInteractionController = UIPrintInteractionController.shared
                    let printInfo = UIPrintInfo(dictionary: nil)
                    printInfo.jobName = "Test Result - \(result.date.formatted())"
                    printInfo.outputType = .general
                    
                    printInteractionController.printInfo = printInfo
                    printInteractionController.printingItem = pdfData
                    
                    printInteractionController.present(animated: true)
                }
            case 3: // Export as PDF
                if let pdfData = generatePDFForSingleTest() {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
                    let dateString = dateFormatter.string(from: result.date)
                    
                    let fileName = "MARS_VF4_TestReport_\(dateString).pdf"
                    let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
                    try? pdfData.write(to: url)
                    exportURL = url
                    showShareSheet = true
                }
            case 4: // Export as CSV
                if let csvData = generateCSVForSingleTest() {
                    let url = FileManager.default.temporaryDirectory.appendingPathComponent("test_result_\(result.date.timeIntervalSince1970).csv")
                    try? csvData.write(to: url)
                    exportURL = url
                    showShareSheet = true
                }
            default:
                break
            }
            
            withAnimation {
                isMenuExpanded = false
            }
        }
        
        private func generateCSVForSingleTest() -> Data? {
            let df = DateFormatter()
            df.dateFormat = "MM/dd/yy h:mm a"
            
            let csvString = "Date,Test Type,Accuracy,Status,Total Volume,Meter Size,Meter Type,Meter Model,Serial Number\n" +
            [
                df.string(from: result.date),
                result.testType.rawValue,
                String(format: "%.1f%%", result.reading.accuracy),
                result.isPassing ? "PASS" : "FAIL",
                String(format: "%.1f Gal", result.reading.totalVolume),
                result.meterSize,
                result.meterType,
                result.meterModel,
                result.jobNumber
            ].joined(separator: ",")
            
            return csvString.data(using: .utf8)
        }
        
        func generatePDFForSingleTest() -> Data? {
            let pdfMetaData = [
                kCGPDFContextCreator: "MARS Company",
                kCGPDFContextAuthor: "VEROflow-4 Test System",
                kCGPDFContextTitle: "Single Test Report",
                kCGPDFContextKeywords: "VEROflow, Test Results, Water Meter Testing"
            ]
            
            let format = UIGraphicsPDFRendererFormat()
            format.documentInfo = pdfMetaData as [String: Any]
            
            let pageRect = CGRect(x: 0, y: 0, width: 11 * 72.0, height: 8.5 * 72.0)
            let margin: CGFloat = 36.0
            
            let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
            
            return renderer.pdfData { context in
                context.beginPage()
                
                let headerGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                                colors: [
                                                    UIColor(red: 0.0, green: 0.2, blue: 0.4, alpha: 1.0).cgColor,
                                                    UIColor(red: 0.0, green: 0.1, blue: 0.2, alpha: 1.0).cgColor
                                                ] as CFArray,
                                                locations: [0, 1])!
                
                let headerRect = CGRect(x: 0, y: 0, width: pageRect.width, height: 80)
                context.cgContext.drawLinearGradient(
                    headerGradient,
                    start: CGPoint(x: 0, y: 0),
                    end: CGPoint(x: 0, y: 80),
                    options: []
                )
                
                let titleAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 24),
                    .foregroundColor: UIColor.white
                ]
                let title = "VEROflow-4 Test Report"
                title.draw(
                    at: CGPoint(x: margin, y: margin),
                    withAttributes: titleAttributes
                )
                
                let df = DateFormatter()
                df.dateFormat = "MM/dd/yy h:mm a"
                
                let detailTitleAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 16),
                    .foregroundColor: UIColor.black
                ]
                
                let detailAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 14),
                    .foregroundColor: UIColor.black
                ]
                
                var currentY: CGFloat = 120
                
                "Test Details".draw(
                    at: CGPoint(x: margin, y: currentY),
                    withAttributes: detailTitleAttributes
                )
                currentY += 30
                
                let details = [
                    "Date: \(df.string(from: result.date))",
                    "Test Type: \(result.testType.rawValue)",
                    "Meter Size: \(result.meterSize)",
                    "Meter Type: \(result.meterType)",
                    "Meter Model: \(result.meterModel)",
                    "Serial Number: \(result.jobNumber)",
                    "Accuracy: \(String(format: "%.1f%%", result.reading.accuracy))",
                    "Status: \(result.isPassing ? "PASS" : "FAIL")",
                    "Total Volume: \(String(format: "%.1f Gal", result.reading.totalVolume))",
                    "Small Meter Start: \(String(format: "%.1f", result.reading.smallMeterStart))",
                    "Small Meter End: \(String(format: "%.1f", result.reading.smallMeterEnd))"
                ]
                
                for detail in details {
                    detail.draw(
                        at: CGPoint(x: margin + 20, y: currentY),
                        withAttributes: detailAttributes
                    )
                    currentY += 25
                }
                
                self.drawFooter(context: context, pageRect: pageRect)
            }
        }
        
        func drawFooter(context: UIGraphicsPDFRendererContext, pageRect: CGRect) {
            let footerText = "VEROflow-4 Test Report"
            let footerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.gray
            ]
            let textSize = footerText.size(withAttributes: footerAttributes)
            let textRect = CGRect(
                x: pageRect.width - textSize.width - 20,
                y: pageRect.height - textSize.height - 20,
                width: textSize.width,
                height: textSize.height
            )
            footerText.draw(in: textRect, withAttributes: footerAttributes)
        }
    }
}