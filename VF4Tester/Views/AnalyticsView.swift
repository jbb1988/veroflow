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
    
    // Chart filtering.
    var chartFilteredResults: [TestResult] {
        statFilteredResults.filter { $0.date >= chartStartDate && $0.date <= effectiveEndDate }
    }
    
    var totalVolumeAllTests: Double {
        viewModel.testResults.reduce(0) { $0 + $1.reading.totalVolume }
    }
    
    // Dynamic y-axis domain.
    var accuracyDomain: ClosedRange<Double> {
        let accuracies = chartFilteredResults.map { $0.reading.accuracy }
        if let maxAcc = accuracies.max(), maxAcc < 95 {
            return 0...120
        }
        guard !accuracies.isEmpty else { return 0...120 }
        let minAcc = accuracies.min() ?? 0
        return max(0, minAcc - 5)...(accuracies.max()! + 5)
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
    
    var chartContent: some View {
        Chart {
            // Draw pass/fail zone.
            if let minDate = chartFilteredResults.map(\.date).min(),
               let maxDate = chartFilteredResults.map(\.date).max() {
                RectangleMark(
                    xStart: .value("Start", minDate),
                    xEnd: .value("End", maxDate),
                    yStart: .value("Lower", 95),
                    yEnd: .value("Upper", 101)
                )
                .foregroundStyle(Color.green.opacity(0.1))
            }
            
            // Plot test results.
            ForEach(chartFilteredResults.sorted(by: { $0.date < $1.date })) { result in
                LineMark(
                    x: .value("Date", result.date),
                    y: .value("Accuracy", result.reading.accuracy)
                )
                .foregroundStyle(result.isPassing ? .green : .red)
                .symbol {
                    Circle()
                        .fill(result.isPassing ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                }
            }
            
            // Optional trend line.
            if showTrendLine {
                RuleMark(y: .value("Average", averageAccuracy))
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                    .foregroundStyle(.blue.opacity(0.5))
                    .annotation(position: .leading) {
                        Text(String(format: "Avg: %.1f%%", averageAccuracy))
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
            }
            
            // Threshold lines.
            RuleMark(y: .value("Low Flow Min", 95))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                .foregroundStyle(.yellow.opacity(0.5))
            RuleMark(y: .value("High Flow Min", 98.5))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                .foregroundStyle(.green.opacity(0.5))
            RuleMark(y: .value("Max", 101.5))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                .foregroundStyle(.red.opacity(0.5))
        }
        .chartYScale(domain: accuracyDomain)
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { value in
                if let date = value.as(Date.self) {
                    AxisValueLabel {
                        Text(date.formatted(.dateTime.month().day()))
                            .font(.caption2)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: .stride(by: 20)) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let accuracy = value.as(Double.self) {
                        Text("\(Int(accuracy))%")
                            .font(.caption2)
                    }
                }
            }
        }
        .frame(height: 300)
        .padding()
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
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
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
                        NavigationLink {
                            TestHistoryView(initialFilter: .passed)
                        } label: {
                            StatCard(
                                title: "Pass Rate",
                                value: String(format: "%.1f%%", passRate),
                                color: .green,
                                icon: "checkmark.circle.fill"
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        StatCard(
                            title: "Average Accuracy",
                            value: String(format: "%.1f%%", averageAccuracy),
                            color: .blue,
                            icon: "gauge.with.dots.needle.bottom.50percent"
                        )
                    }
                    HStack(spacing: 16) {
                        NavigationLink {
                            TestHistoryView(initialFilter: .all)
                        } label: {
                            StatCard(
                                title: "Total Tests",
                                value: "\(statFilteredResults.count)",
                                color: .purple,
                                icon: "number.circle.fill"
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        NavigationLink {
                            TestHistoryView(initialFilter: .failed)
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
                
                // Chart Options Card.
                DetailCard(title: "Chart Options") {
                    VStack(spacing: 12) {
                        Toggle("Show Trend Line", isOn: $showTrendLine)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Chart Date Range")
                                .font(.headline)
                            DatePicker("Start", selection: $chartStartDate, displayedComponents: .date)
                            DatePicker("End", selection: $chartEndDate, displayedComponents: .date)
                        }
                    }
                }
                
                // Chart Card.
                DetailCard(title: "Test Results") {
                    if chartFilteredResults.isEmpty {
                        Text("No test results available")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else {
                        chartContent
                    }
                }
                
                // Recent Tests Card.
                DetailCard(title: "Recent Tests") {
                    ForEach(statFilteredResults.sorted(by: { $0.date > $1.date }).prefix(5)) { result in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(result.testType.rawValue)
                                        .font(.headline)
                                    Text(result.date.formatted())
                                        .font(.caption)
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
            }
            .padding()
        }
        .navigationTitle("Analytics")
        .toolbar {
            ToolbarItem(placement: .principal) {
                Image("veroflowLogo")
                    .resizable()
                    .renderingMode(.original)
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 40)
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .frame(maxHeight: 44)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
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
    }
}

struct AnalyticsView_Previews: PreviewProvider {
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
                    totalVolume: 53,
                    flowRate: 5,
                    readingType: .small
                ),
                notes: "Test LowFlow",
                date: Date().addingTimeInterval(-86400),
                meterImageData: nil,
                meterSize: "1\"",
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
                    totalVolume: 200,
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
            AnalyticsView().environmentObject(vm)
        }
    }
}
