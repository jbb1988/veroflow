import SwiftUI
import Charts

struct AnalyticsView: View {
    @EnvironmentObject var viewModel: TestViewModel
    
    // For the stat cards and recent tests.
    @State private var selectedFilter: FilterOption = .all
    // For the chart date range.
    @State private var chartStartDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var chartEndDate: Date = Date()
    
    @State private var showTrendLine: Bool = false
    @State private var showingExportSheet = false
    
    // New state for chart filtering options (same as TestHistoryView filters)
    @State private var chartHistoryFilter: TestHistoryView.FilterOption = .all
    @State private var chartSortOrder: TestHistoryView.SortOrder = .descending
    @State private var chartMeterSize: TestHistoryView.MeterSizeFilter = .all
    @State private var chartManufacturer: TestHistoryView.MeterManufacturerFilter = .all
    
    @Environment(\.presentationMode) var presentationMode
    
    enum FilterOption: String, CaseIterable, Identifiable {
        case all = "All Tests"
        case lowFlow = "Low Flow"
        case compound = "Compound"
        case highFlow = "High Flow"
        var id: Self { self }
    }
    
    // Filter for stats and recent tests.
    var statFilteredResults: [TestResult] {
        switch selectedFilter {
        case .all:
            return viewModel.testResults
        case .lowFlow:
            return viewModel.testResults.filter { $0.testType == .lowFlow }
        case .compound:
            return viewModel.testResults.filter { $0.reading.readingType == .compound }
        case .highFlow:
            return viewModel.testResults.filter { $0.testType == .highFlow }
        }
    }
    
    // Effective end date.
    var effectiveEndDate: Date {
        max(chartEndDate, Date())
    }
    
    // Chart filtering using the new chart filter options.
    var chartFilteredResults: [TestResult] {
        let filtered = viewModel.testResults.filter { result in
            let inDateRange = (result.date >= chartStartDate) && (result.date <= effectiveEndDate)
            let filterMatch: Bool = {
                switch chartHistoryFilter {
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
                switch chartMeterSize {
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
                switch chartManufacturer {
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
            return inDateRange && filterMatch && meterSizeMatch && manufacturerMatch
        }
        switch chartSortOrder {
        case .ascending:
            return filtered.sorted { $0.date < $1.date }
        case .descending:
            return filtered.sorted { $0.date > $1.date }
        }
    }
    
    var totalVolumeAllTests: Double {
        viewModel.testResults.reduce(0) { $0 + $1.reading.totalVolume }
    }
    
    // Dynamic y-axis domain.
    var accuracyDomain: ClosedRange<Double> {
        let accuracies = chartFilteredResults.map { $0.reading.accuracy }
        guard !accuracies.isEmpty else { return 90...105 } // Default passing scale range
        
        let minAcc = accuracies.min() ?? 90
        let maxAcc = accuracies.max() ?? 105
        
        // Ensure we always show the critical threshold lines
        let lowerBound = min(minAcc - 5, 90) // Show at least down to 90%
        let upperBound = max(maxAcc + 5, 105) // Show at least up to 105%
        
        return lowerBound...upperBound
    }
    
    var passRate: Double {
        guard !statFilteredResults.isEmpty else { return 0 }
        let passing = statFilteredResults.filter { $0.isPassing }.count
        return Double(passing) / Double(statFilteredResults.count) * 100
    }
    
    var averageAccuracy: Double {
        guard !statFilteredResults.isEmpty else { return 0 }
        let total = statFilteredResults.reduce(0.0) { $0 + $1.reading.accuracy }
        return total / Double(statFilteredResults.count)
    }
    
    var failedTestsCount: Int {
        statFilteredResults.filter { !$0.isPassing }.count
    }
    
    func generateShareText() -> String {
        """
        Analytics Summary:
        Pass Rate: \(String(format: "%.1f%%", passRate))
        Average Accuracy: \(String(format: "%.1f%%", averageAccuracy))
        Total Tests: \(statFilteredResults.count)
        Failed Tests: \(failedTestsCount)
        Water Usage: \(Int(totalVolumeAllTests)) Gallons
        Chart Date Range: \(chartStartDate.formatted(date: .abbreviated, time: .omitted)) to \(effectiveEndDate.formatted(date: .abbreviated, time: .omitted))
        """
    }
    
    @State private var selectedTest: TestResult? = nil
    
    @State private var showHistorySheet = false
    @State private var historyFilter: TestHistoryView.FilterOption = .all
    
    var body: some View {
        ScrollView {
            VStack {
                VStack(spacing: 16) {
                    Color.clear
                        .frame(height: 1)
                        .padding(.top, 100)

                    // Water Usage Card.
                    DetailCard(title: "Water Usage") {
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(viewModel.configuration.formatVolume(totalVolumeAllTests))
                                    .font(.headline)
                            }
                            Spacer()
                            WaveCircleGauge(totalVolume: totalVolumeAllTests, targetVolume: totalVolumeAllTests)
                                .frame(width: 80, height: 80)
                        }
                    }
                    
                    // Stat Cards.
                    VStack(spacing: 16) {
                        HStack(spacing: 16) {
                            Button {
                                selectedTest = nil
                                historyFilter = .passed
                                showHistorySheet = true
                            } label: {
                                StatCard(
                                    title: "Pass Rate",
                                    value: String(format: "%.1f%%", passRate),
                                    color: .green,
                                    icon: "checkmark.circle.fill"
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            Button {
                                selectedTest = nil
                                historyFilter = .all
                                showHistorySheet = true
                            } label: {
                                StatCard(
                                    title: "Average Accuracy",
                                    value: String(format: "%.1f%%", averageAccuracy),
                                    color: .blue,
                                    icon: "gauge.with.dots.needle.bottom.50percent"
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        HStack(spacing: 16) {
                            Button {
                                selectedTest = nil
                                historyFilter = .all
                                showHistorySheet = true
                            } label: {
                                StatCard(
                                    title: "Total Tests",
                                    value: "\(statFilteredResults.count)",
                                    color: .purple,
                                    icon: "number.circle.fill"
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            Button {
                                selectedTest = nil
                                historyFilter = .failed
                                showHistorySheet = true
                            } label: {
                                StatCard(
                                    title: "Failed Tests",
                                    value: "\(failedTestsCount)",
                                    color: .red,
                                    icon: "xmark.circle.fill"
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    
                    // Chart Options Card with updated filter bindings.
                    ChartOptionsView(
                        showTrendLine: $showTrendLine,
                        chartStartDate: $chartStartDate,
                        chartEndDate: $chartEndDate,
                        selectedHistoryFilter: $chartHistoryFilter,
                        selectedSortOrder: $chartSortOrder,
                        selectedMeterSize: $chartMeterSize,
                        selectedManufacturer: $chartManufacturer
                    )
                    
                    // Chart Card.
                    DetailCard(title: "Test Results") {
                        if chartFilteredResults.isEmpty {
                            Text("No test results available")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            AnalyticsChartView(
                                chartFilteredResults: chartFilteredResults,
                                averageAccuracy: averageAccuracy,
                                accuracyDomain: accuracyDomain.lowerBound - 5...accuracyDomain.upperBound + 5,
                                showTrendLine: $showTrendLine
                            )
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                        }
                    }
                    
                    // Recent Tests Card.
                    RecentTestsView(results: statFilteredResults, selectedTest: $selectedTest)
                }
                .padding()
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image("veroflowLogo")
                        .resizable()
                        .renderingMode(.original)
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 40)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingExportSheet = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .sheet(isPresented: $showingExportSheet) {
#if os(iOS)
                ShareSheet(activityItems: [generateShareText()])
#endif
            }
            .sheet(item: $selectedTest) { result in
                TestDetailView(result: result)
                    .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $showHistorySheet) {
                TestHistoryView(initialFilter: historyFilter)
                    .presentationDetents([.medium, .large])
            }
        }
    }
    
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
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Spacer()
                }
                Text(value)
                    .foregroundColor(color)
                    .font(.headline)
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(color, lineWidth: 1)
                    )
            )
        }
    }
    
    struct ChartOptionsView: View {
        @Binding var showTrendLine: Bool
        @Binding var chartStartDate: Date
        @Binding var chartEndDate: Date
        
        @Binding var selectedHistoryFilter: TestHistoryView.FilterOption
        @Binding var selectedSortOrder: TestHistoryView.SortOrder
        @Binding var selectedMeterSize: TestHistoryView.MeterSizeFilter
        @Binding var selectedManufacturer: TestHistoryView.MeterManufacturerFilter
        
        @State private var isFilterExpanded: Bool = false
        
        var body: some View {
            DetailCard(title: "Chart Options") {
                CompactFilterPill(
                    isExpanded: $isFilterExpanded,
                    selectedFilter: $selectedHistoryFilter,
                    selectedSort: $selectedSortOrder,
                    startDate: $chartStartDate,
                    endDate: $chartEndDate,
                    selectedMeterSize: $selectedMeterSize,
                    selectedManufacturer: $selectedManufacturer
                )
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.black)
            }
        }
    }
    
    struct AnalyticsView_Previews: PreviewProvider {
        static var previews: some View {
            let vm = TestViewModel()
            vm.testResults = [
                TestResult(
                    id: UUID(),
                    testType: .lowFlow,
                    date: Date().addingTimeInterval(-86400),
                    reading: MeterReading(
                        smallMeterStart: 10,
                        smallMeterEnd: 20,
                        largeMeterStart: 0,
                        largeMeterEnd: 0,
                        totalVolume: 53,
                        flowRate: 5,
                        readingType: .small
                    ),
                    notes: "Test LowFlow",
                    meterImageData: nil,
                    meterSize: "1\"",
                    meterType: "Neptune",
                    meterModel: "Positive Displacement",
                    jobNumber: "JOB-001",
                    latitude: nil,
                    longitude: nil,
                    locationDescription: nil
                ),
                TestResult(
                    id: UUID(),
                    testType: .highFlow,
                    date: Date(),
                    reading: MeterReading(
                        smallMeterStart: 15,
                        smallMeterEnd: 25,
                        largeMeterStart: 0,
                        largeMeterEnd: 0,
                        totalVolume: 200,
                        flowRate: 30,
                        readingType: .small
                    ),
                    notes: "Test HighFlow",
                    meterImageData: nil,
                    meterSize: "3\"",
                    meterType: "Sensus",
                    meterModel: "Multi-Jet",
                    jobNumber: "JOB-002",
                    latitude: nil,
                    longitude: nil,
                    locationDescription: nil
                )
            ]
            return NavigationView {
                AnalyticsView().environmentObject(vm)
            }
        }
    }
}