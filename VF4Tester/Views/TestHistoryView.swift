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
    @State private var isExportMenuExpanded = false
    @State private var dragAmount = CGSize.zero
    
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
    
    /// Filtered test results for the main list, used by PDF/CSV exports
    var filteredResults: [TestResult] {
        let filtered = viewModel.testResults.filter { result in
            let startOfDay = Calendar.current.startOfDay(for: startDate)
            let endOfDay = Calendar.current.startOfDay(for: endDate).addingTimeInterval(86399)
            let inDateRange = (result.date >= startOfDay) && (result.date <= endOfDay)
            
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
    
    /// For bounding the date range
    var effectiveEndDate: Date {
        max(endDate, Date())
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
        ZStack(alignment: .bottomTrailing) {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "001830"),
                    Color(hex: "000C18")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay(WeavePattern())
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .padding(.leading, 4)
                    
                    TextField("Search by job, meter type, or size...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(.white)
                        .accentColor(.white)
                        .padding(8)
                        .background(Color.black)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.blue.opacity(0.8), lineWidth: 1)
                                .shadow(color: Color.blue.opacity(0.5), radius: 2, x: 0, y: 0)
                        )
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .padding(.trailing, 4)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(WeavePattern())
                .standardContentSpacing()
                
                CompactFilterPill(
                    isExpanded: $isFilterExpanded,
                    selectedFilter: $selectedHistoryFilter,
                    selectedSort: $selectedSortOrder,
                    startDate: $startDate,
                    endDate: $endDate,
                    selectedMeterSize: $selectedMeterSize,
                    selectedManufacturer: $selectedManufacturer
                )
                .padding(.vertical, 8)
                .padding(.leading, 40)
                .padding(.trailing, 16)
                .background(Color.clear)

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
                .padding(.bottom, 80)
            }
            
            ExportMenuButton(
                isExpanded: $isExportMenuExpanded,
                onPDFWithNotes: {
                    if let url = generatePDF(withNotes: true) {
                        exportAllData = url
                        showExportAllShareSheet = true
                    }
                },
                onPDFWithoutNotes: {
                    if let url = generatePDF(withNotes: false) {
                        exportAllData = url
                        showExportAllShareSheet = true
                    }
                },
                onCSVWithNotes: {
                    if let url = generateCSV(withNotes: true) {
                        exportAllData = url
                        showExportAllShareSheet = true
                    }
                },
                onCSVWithoutNotes: {
                    if let url = generateCSV(withNotes: false) {
                        exportAllData = url
                        showExportAllShareSheet = true
                    }
                }
            )
            .padding(.trailing, 24)
            .padding(.bottom, 24)
        }
        .sheet(item: $selectedResult) { result in
            TestDetailView(result: result)
        }
        .actionSheet(isPresented: $showingExportAllSheet) {
            ActionSheet(
                title: Text("Export All Test History"),
                buttons: [
                    .default(Text("Export as PDF")) {
                        if let url = generatePDF(withNotes: true) {
                            exportAllData = url
                            showExportAllShareSheet = true
                        }
                    },
                    .default(Text("Export as PDF w/o Notes")) {
                        if let url = generatePDF(withNotes: false) {
                            exportAllData = url
                            showExportAllShareSheet = true
                        }
                    },
                    .default(Text("Export as CSV")) {
                        if let url = generateCSV(withNotes: true) {
                            exportAllData = url
                            showExportAllShareSheet = true
                        }
                    },
                    .default(Text("Export as CSV w/o Notes")) {
                        if let url = generateCSV(withNotes: false) {
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
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .principal) {
                Image("veroflowLogo")
                    .resizable()
                    .renderingMode(.original)
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 80)
            }
        }
        .toolbarBackground(.visible, for: .navigationBar)
    }
    
    // MARK: - Export PDF & CSV
    
    func generatePDF(withNotes: Bool) -> URL? {
        guard let pdfData = generatePDFData(withNotes: withNotes) else { return nil }
        let fileName = withNotes ? "test_history_\(Date().timeIntervalSince1970).pdf" : "test_history_no_notes_\(Date().timeIntervalSince1970).pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try? pdfData.write(to: url)
        return url
    }
    
    func generateCSV(withNotes: Bool) -> URL? {
        guard let csvData = generateCSVData(withNotes: withNotes) else { return nil }
        let fileName = withNotes ? "test_history_\(Date().timeIntervalSince1970).csv" : "test_history_no_notes_\(Date().timeIntervalSince1970).csv"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try? csvData.write(to: url)
        return url
    }
    
    // Modified escapeCSV function to properly handle multiline text for Excel compatibility
    func escapeCSV(_ text: String) -> String {
        // First escape quotes by doubling them
        var escaped = text.replacingOccurrences(of: "\"", with: "\"\"")
        
        // For CSV to properly handle multilines in Excel and other tools,
        // we need to preserve newlines but make sure they're preserved when opened in Excel
        // We'll replace newlines with a special character sequence that Excel recognizes
        escaped = escaped.replacingOccurrences(of: "\n", with: "\r")
        
        return escaped
    }
    
    func generateCSVData(withNotes: Bool) -> Data? {
        let df = DateFormatter()
        df.dateFormat = "MM/dd/yy"
        if withNotes {
            var csvString = "Date,Serial Number,Test Type,Meter Size,Meter MFG,Accuracy,Status,Notes\n"
            for result in filteredResults {
                let rowData = [
                    df.string(from: result.date),
                    result.jobNumber,
                    result.testType.rawValue,
                    result.meterSize,
                    result.meterType,
                    String(format: "%.1f%%", result.reading.accuracy),
                    result.isPassing ? "PASS" : "FAIL",
                    // If notes empty, use "-" otherwise use the full notes
                    result.notes.isEmpty ? "-" : result.notes
                ]
                let row = rowData.map { "\"\(escapeCSV($0))\"" }.joined(separator: ",")
                csvString += row + "\n"
            }
            return csvString.data(using: .utf8)
        } else {
            var csvString = "Date,Serial Number,Test Type,Meter Size,Meter MFG,Accuracy,Status\n"
            for result in filteredResults {
                let rowData = [
                    df.string(from: result.date),
                    result.jobNumber,
                    result.testType.rawValue,
                    result.meterSize,
                    result.meterType,
                    String(format: "%.1f%%", result.reading.accuracy),
                    result.isPassing ? "PASS" : "FAIL"
                ]
                let row = rowData.map { "\"\(escapeCSV($0))\"" }.joined(separator: ",")
                csvString += row + "\n"
            }
            return csvString.data(using: .utf8)
        }
    }
    
    func generatePDFData(withNotes: Bool) -> Data? {
        let pdfMetaData = [
            kCGPDFContextCreator: "MARS Company",
            kCGPDFContextAuthor: "VEROflow-4 Test System",
            kCGPDFContextTitle: "Test History Report",
            kCGPDFContextKeywords: "VEROflow, Test Results, Water Meter Testing"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        let pageRect = CGRect(x: 0, y: 0, width: 11 * 72.0, height: 8.5 * 72.0)
        let margin: CGFloat = 36.0
        let df = DateFormatter()
        df.dateFormat = "MM/dd/yy"
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
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
            context.cgContext.drawLinearGradient(headerGradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: 80), options: [])
            let title = "VEROflow-4 Test Results"
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.white
            ]
            title.draw(at: CGPoint(x: margin, y: margin), withAttributes: titleAttributes)
            let pageText = "Page \(currentPage)"
            let pageAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.white
            ]
            pageText.draw(at: CGPoint(x: pageRect.width - margin - 50, y: margin), withAttributes: pageAttributes)
            currentY = 100
        }
        
        func drawTableHeader(context: UIGraphicsPDFRendererContext) {
            let headerBackgroundRect = CGRect(x: margin, y: currentY - 5, width: tableWidth, height: 25)
            context.cgContext.setFillColor(UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0).cgColor)
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
            let fullHeaderRect = CGRect(x: margin, y: currentY - 5, width: tableWidth, height: 25)
            context.cgContext.stroke(fullHeaderRect)
            currentY += 25
        }
        
        func drawFooter(context: UIGraphicsPDFRendererContext, pageRect: CGRect) {
            let footerText = "VEROflow-4 Test Report"
            let footerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.gray
            ]
            let textSize = footerText.size(withAttributes: footerAttributes)
            let textRect = CGRect(x: pageRect.width - textSize.width - 20,
                                  y: pageRect.height - textSize.height - 20,
                                  width: textSize.width,
                                  height: textSize.height)
            footerText.draw(in: textRect, withAttributes: footerAttributes)
        }
        
        return renderer.pdfData { context in
            context.beginPage()
            drawPageHeader(context: context)
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
                text.draw(at: CGPoint(x: margin, y: currentY), withAttributes: summaryAttributes)
                currentY += 20
            }
            currentY += 20
            drawTableHeader(context: context)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            paragraphStyle.lineBreakMode = .byWordWrapping
            let baseAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor.black,
                .paragraphStyle: paragraphStyle
            ]
            for result in filteredResults {
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
                var dynamicRowHeight: CGFloat = 0
                for (i, text) in rowData.enumerated() {
                    let extraPadding: CGFloat = (i == headers.count - 1) ? 10 : 0
                    let boundingRect = (text as NSString).boundingRect(
                        with: CGSize(width: columnWidths[i] - 10, height: .greatestFiniteMagnitude),
                        options: [.usesLineFragmentOrigin, .usesFontLeading],
                        attributes: baseAttributes,
                        context: nil
                    )
                    dynamicRowHeight = max(dynamicRowHeight, boundingRect.height + 10 + extraPadding)
                }
                dynamicRowHeight = max(dynamicRowHeight, 40)
                if currentY + dynamicRowHeight > pageRect.height - margin {
                    drawFooter(context: context, pageRect: pageRect)
                    currentPage += 1
                    context.beginPage()
                    drawPageHeader(context: context)
                    drawTableHeader(context: context)
                }
                let rowBackground = result.isPassing
                    ? UIColor(red: 0.9, green: 1.0, blue: 0.9, alpha: 0.2)
                    : UIColor(red: 1.0, green: 0.9, blue: 0.9, alpha: 0.2)
                let rowRect = CGRect(x: margin, y: currentY - 5, width: tableWidth, height: dynamicRowHeight)
                context.cgContext.setFillColor(rowBackground.cgColor)
                context.cgContext.fill(rowRect)
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
            drawFooter(context: context, pageRect: pageRect)
        }
    }
    
    // MARK: - TestResultRow
    /// The custom row that displays each test result in a row with quick actions
    struct TestResultRow: View {
        let result: TestResult
        @State private var isMenuExpanded = false
        @EnvironmentObject var viewModel: TestViewModel
        @State private var showShareSheet = false
        @State private var exportURL: URL?
        @State private var feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        
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
                        Label(String(format: "%.1f", result.reading.smallMeterStart),
                              systemImage: "arrow.forward.circle.fill")
                            .foregroundColor(.blue)
                        Label(String(format: "%.1f", result.reading.smallMeterEnd),
                              systemImage: "arrow.backward.circle.fill")
                            .foregroundColor(.purple)
                        Label(String(format: "%.1f Gal", result.reading.totalVolume),
                              systemImage: "drop.fill")
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
                            .opacity(isMenuExpanded ? 1 : 0)
                            .scaleEffect(isMenuExpanded ? 1 : 0.5)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isMenuExpanded)
                            .onTapGesture { handleMenuAction(index) }
                    }
                    
                    Button {
                        feedbackGenerator.prepare()
                        feedbackGenerator.impactOccurred()
                        withAnimation {
                            isMenuExpanded.toggle()
                        }
                    } label: {
                        Image("Drop")
                            .resizable()
                            .frame(width: 48, height: 48)
                            .rotationEffect(.degrees(isMenuExpanded ? 180 : 0))
                            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isMenuExpanded)
                    }
                }
                .zIndex(1)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.secondarySystemBackground))
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue.opacity(0.9), lineWidth: 2)
            )
            .shadow(color: Color.blue.opacity(0.5), radius: 4, x: 0, y: 0)
            .contentShape(Rectangle())
            .sheet(isPresented: $showShareSheet, onDismiss: { exportURL = nil }) {
                if let url = exportURL { ShareSheet(activityItems: [url]) }
            }
        }
        
        private func handleMenuAction(_ index: Int) {
            switch index {
            case 0:
                // Delete
                if let idx = viewModel.testResults.firstIndex(where: { $0.id == result.id }) {
                    viewModel.testResults.remove(at: idx)
                }
            case 1:
                // Quick PDF share
                if let pdfData = generatePDFForSingleTest() {
                    let url = FileManager.default.temporaryDirectory.appendingPathComponent("test_result_\(result.date.timeIntervalSince1970).pdf")
                    try? pdfData.write(to: url)
                    exportURL = url
                    showShareSheet = true
                }
            case 2:
                // Print
                if let pdfData = generatePDFForSingleTest(), let _ = PDFDocument(data: pdfData) {
                    let printInteractionController = UIPrintInteractionController.shared
                    let printInfo = UIPrintInfo(dictionary: nil)
                    printInfo.jobName = "Test Result - \(result.date.formatted())"
                    printInfo.outputType = .general
                    printInteractionController.printInfo = printInfo
                    printInteractionController.printingItem = pdfData
                    printInteractionController.present(animated: true)
                }
            case 3:
                // PDF with name
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
            case 4:
                // CSV
                if let csvData = generateCSVForSingleTest() {
                    let url = FileManager.default.temporaryDirectory.appendingPathComponent("test_result_\(result.date.timeIntervalSince1970).csv")
                    try? csvData.write(to: url)
                    exportURL = url
                    showShareSheet = true
                }
            default:
                break
            }
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isMenuExpanded = false
            }
        }
        
        /// Single-test PDF export, matching the "Export All" format (using only 'result')
        func generatePDFForSingleTest() -> Data? {
            let pdfMetaData = [
                kCGPDFContextCreator: "MARS Company",
                kCGPDFContextAuthor: "VEROflow-4 Test System",
                kCGPDFContextTitle: "Test History Report",
                kCGPDFContextKeywords: "VEROflow, Test Results, Water Meter Testing"
            ]
            let format = UIGraphicsPDFRendererFormat()
            format.documentInfo = pdfMetaData as [String: Any]
            let pageRect = CGRect(x: 0, y: 0, width: 11 * 72.0, height: 8.5 * 72.0)
            let margin: CGFloat = 36.0
            let df = DateFormatter()
            df.dateFormat = "MM/dd/yy"
            let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
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
                context.cgContext.drawLinearGradient(headerGradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: 80), options: [])
                let title = "VEROflow-4 Test Results"
                let titleAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 24),
                    .foregroundColor: UIColor.white
                ]
                title.draw(at: CGPoint(x: margin, y: margin), withAttributes: titleAttributes)
                let pageText = "Page \(currentPage)"
                let pageAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 12),
                    .foregroundColor: UIColor.white
                ]
                pageText.draw(at: CGPoint(x: pageRect.width - margin - 50, y: margin), withAttributes: pageAttributes)
                currentY = 100
            }
            
            func drawTableHeader(context: UIGraphicsPDFRendererContext) {
                let headerBackgroundRect = CGRect(x: margin, y: currentY - 5, width: tableWidth, height: 25)
                context.cgContext.setFillColor(UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0).cgColor)
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
                let fullHeaderRect = CGRect(x: margin, y: currentY - 5, width: tableWidth, height: 25)
                context.cgContext.stroke(fullHeaderRect)
                currentY += 25
            }
            
            func drawFooter(context: UIGraphicsPDFRendererContext, pageRect: CGRect) {
                let footerText = "VEROflow-4 Test Report"
                let footerAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 12),
                    .foregroundColor: UIColor.gray
                ]
                let textSize = footerText.size(withAttributes: footerAttributes)
                let textRect = CGRect(x: pageRect.width - textSize.width - 20,
                                      y: pageRect.height - textSize.height - 20,
                                      width: textSize.width,
                                      height: textSize.height)
                footerText.draw(in: textRect, withAttributes: footerAttributes)
            }
            
            return renderer.pdfData { context in
                context.beginPage()
                drawPageHeader(context: context)
                let summaryAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 14),
                    .foregroundColor: UIColor.black
                ]
                let summaryTexts = [
                    "Date Range: \(df.string(from: result.date)) - \(df.string(from: result.date))",
                    "Total Tests: 1",
                    "Passed Tests: \(result.isPassing ? 1 : 0)",
                    "Failed Tests: \(result.isPassing ? 0 : 1)"
                ]
                for text in summaryTexts {
                    text.draw(at: CGPoint(x: margin, y: currentY), withAttributes: summaryAttributes)
                    currentY += 20
                }
                currentY += 20
                drawTableHeader(context: context)
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .left
                paragraphStyle.lineBreakMode = .byWordWrapping
                let baseAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 10),
                    .foregroundColor: UIColor.black,
                    .paragraphStyle: paragraphStyle
                ]
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
                var dynamicRowHeight: CGFloat = 0
                for (i, text) in rowData.enumerated() {
                    let extraPadding: CGFloat = (i == headers.count - 1) ? 10 : 0
                    let boundingRect = (text as NSString).boundingRect(
                        with: CGSize(width: columnWidths[i] - 10, height: .greatestFiniteMagnitude),
                        options: [.usesLineFragmentOrigin, .usesFontLeading],
                        attributes: baseAttributes,
                        context: nil
                    )
                    dynamicRowHeight = max(dynamicRowHeight, boundingRect.height + 10 + extraPadding)
                }
                dynamicRowHeight = max(dynamicRowHeight, 40)
                if currentY + dynamicRowHeight > pageRect.height - 36.0 {
                    drawFooter(context: context, pageRect: pageRect)
                    currentPage += 1
                    context.beginPage()
                    drawPageHeader(context: context)
                    drawTableHeader(context: context)
                }
                let rowBackground = result.isPassing
                    ? UIColor(red: 0.9, green: 1.0, blue: 0.9, alpha: 0.2)
                    : UIColor(red: 1.0, green: 0.9, blue: 0.9, alpha: 0.2)
                let rowRect = CGRect(x: margin, y: currentY - 5, width: tableWidth, height: dynamicRowHeight)
                context.cgContext.setFillColor(rowBackground.cgColor)
                context.cgContext.fill(rowRect)
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
                drawFooter(context: context, pageRect: pageRect)
            }
        }
        
        /// Single-test CSV export, matching the "Export All" columns
        func generateCSVForSingleTest() -> Data? {
            let df = DateFormatter()
            df.dateFormat = "MM/dd/yy h:mm a"
            
            func escapeCSV(_ text: String) -> String {
                // First escape quotes by doubling them
                var escaped = text.replacingOccurrences(of: "\"", with: "\"\"")
                
                // For CSV to properly handle multilines in Excel and other tools,
                // we need to preserve newlines but make sure they're preserved when opened in Excel
                // We'll replace newlines with a special character sequence that Excel recognizes
                escaped = escaped.replacingOccurrences(of: "\n", with: "\r")
                
                return escaped
            }
            
            let header = "Date,Serial Number,Test Type,Meter Size,Meter MFG,Accuracy,Status,Notes\n"
            // Create an array of strings first
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
            // Then convert each string to CSV format
            let formattedRow = rowData.map { "\"\(escapeCSV($0))\"" }.joined(separator: ",")
            
            let csvString = header + formattedRow + "\n"
            return csvString.data(using: .utf8)
        }
    }
    
    // MARK: - Export Menu Button
    struct ExportMenuButton: View {
        @Binding var isExpanded: Bool
        let onPDFWithNotes: () -> Void
        let onPDFWithoutNotes: () -> Void
        let onCSVWithNotes: () -> Void
        let onCSVWithoutNotes: () -> Void
        
        private let buttonSize: CGFloat = 56
        private let menuRadius: CGFloat = 120
        
        var body: some View {
            ZStack {
                // Menu items
                ForEach(0..<4) { index in
                    let radius: CGFloat = 170
                    let startAngle: Double = 23
                    let angleIncrement: Double = 23
                    let angle = (startAngle + angleIncrement * Double(index)) * .pi / 180

                    MenuButton(
                        icon: index < 2 ? "doc.fill" : "tablecells.fill",
                        color: index < 2
                            ? Color(red: 162/255, green: 9/255, blue: 8/255)
                            : Color(red: 16/255, green: 117/255, blue: 60/255),
                        label: {
                            switch index {
                            case 0: return "PDF"
                            case 1: return "PDF-"
                            case 2: return "CSV"
                            case 3: return "CSV-"
                            default: return ""
                            }
                        }(),
                        size: buttonSize
                    )
                    .offset(
                        x: isExpanded ? -radius * CGFloat(cos(angle)) : 0,
                        y: isExpanded ? -radius * CGFloat(sin(angle)) : 0
                    )
                    .opacity(isExpanded ? 1 : 0)
                    .scaleEffect(isExpanded ? 1 : 0.5)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0.3).delay(Double(index) * 0.05), value: isExpanded)
                    .onTapGesture {
                        switch index {
                        case 0: onPDFWithNotes()
                        case 1: onPDFWithoutNotes()
                        case 2: onCSVWithNotes()
                        case 3: onCSVWithoutNotes()
                        default: break
                        }
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isExpanded = false
                        }
                    }
                }
                
                // Main button
                Button {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.3)) {
                        isExpanded.toggle()
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.blue.gradient)
                            .shadow(radius: 4)
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(isExpanded ? 135 : 0))
                            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isExpanded)
                    }
                }
                .frame(width: buttonSize, height: buttonSize)
                .scaleEffect(isExpanded ? 0.9 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isExpanded)
            }
        }
        
        // Add this view struct inside ExportMenuButton
        struct MenuButton: View {
            let icon: String
            let color: Color
            let label: String
            let size: CGFloat
            
            var body: some View {
                ZStack {
                    Circle()
                        .fill(color.gradient)
                        .shadow(radius: 2)
                    VStack(spacing: 2) {
                        Image(systemName: icon)
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                        Text(label)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .frame(width: size, height: size)
            }
        }
    }
}
