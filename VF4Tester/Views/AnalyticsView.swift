import SwiftUI
import Charts

// MARK: - Analytics View
struct AnalyticsView: View {
    @EnvironmentObject var viewModel: TestViewModel
    @State private var selectedFilter: FilterOption = .all
    @State private var selectedChartType: ChartType = .bar
    @State private var showTrendLine: Bool = false
    @State private var showExportSheet: Bool = false
    @State private var exportData: Data? = nil

    // MARK: - Filter Options
    enum FilterOption: String, CaseIterable, Identifiable {
        case all = "All Tests"
        case lowFlow = "Low Flow"
        case highFlow = "High Flow"
        var id: Self { self }
    }

    enum ChartType: String, CaseIterable, Identifiable {
        case bar = "Bar"
        case line = "Line"
        var id: Self { self }
    }

    // MARK: - Computed Properties
    var filteredResults: [TestResult] {
        switch selectedFilter {
        case .all: return viewModel.testResults
        case .lowFlow: return viewModel.testResults.filter { $0.testType == .lowFlow }
        case .highFlow: return viewModel.testResults.filter { $0.testType == .highFlow }
        }
    }

    var passRate: Double {
        guard !filteredResults.isEmpty else { return 0 }
        let passingTests = filteredResults.filter { $0.isPassing }.count
        return Double(passingTests) / Double(filteredResults.count) * 100
    }

    var averageAccuracy: Double {
        guard !filteredResults.isEmpty else { return 0 }
        let total = filteredResults.reduce(0.0) { $0 + $1.reading.accuracy }
        return total / Double(filteredResults.count)
    }

    // MARK: - Chart Content
    @ViewBuilder
    var chartContent: some View {
        Chart {
            // Pass/Fail Threshold Zones - Using RectangleMark without zIndex
            ForEach(filteredResults) { result in
                // Draw the threshold zones first
                RectangleMark(
                    xStart: .value("Start", result.date),
                    xEnd: .value("End", result.date),
                    yStart: .value("Lower", 95),
                    yEnd: .value("Upper", 101)
                )
                .foregroundStyle(Color.green.opacity(0.1))

                RectangleMark(
                    xStart: .value("Start", result.date),
                    xEnd: .value("End", result.date),
                    yStart: .value("Lower", 98.5),
                    yEnd: .value("Upper", 101.5)
                )
                .foregroundStyle(Color.blue.opacity(0.1))

                // Then draw the data points on top
                if selectedChartType == .bar {
                    BarMark(
                        x: .value("Date", result.date),
                        y: .value("Accuracy", result.reading.accuracy)
                    )
                    .foregroundStyle(result.isPassing ? Color.green : Color.red)
                } else {
                    LineMark(
                        x: .value("Date", result.date),
                        y: .value("Accuracy", result.reading.accuracy)
                    )
                    .foregroundStyle(result.isPassing ? Color.green : Color.red)
                    .symbol {
                        Circle()
                            .fill(result.isPassing ? Color.green : Color.red)
                            .frame(width: 8, height: 8)
                    }
                }
            }

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
        }
        .chartYScale(domain: 90...105)
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
        .frame(height: 300)
        .padding()
    }

    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Controls Card
                DetailCard(title: "Chart Options") {
                    VStack(spacing: 12) {
                        Picker("Test Type", selection: $selectedFilter) {
                            ForEach(FilterOption.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())

                        Divider()

                        Picker("Chart Type", selection: $selectedChartType) {
                            ForEach(ChartType.allCases) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())

                        Toggle("Show Trend Line", isOn: $showTrendLine)
                    }
                }

                // Stats Grid
                HStack(spacing: 16) {
                    StatCard(
                        title: "Pass Rate",
                        value: String(format: "%.1f%%", passRate),
                        color: .green,
                        icon: "checkmark.circle.fill"
                    )

                    StatCard(
                        title: "Average Accuracy",
                        value: String(format: "%.1f%%", averageAccuracy),
                        color: .blue,
                        icon: "gauge.with.dots.needle.bottom.50percent"
                    )

                    StatCard(
                        title: "Total Tests",
                        value: "\(filteredResults.count)",
                        color: .purple,
                        icon: "number.circle.fill"
                    )
                }

                // Chart Card
                DetailCard(title: "Test Results") {
                    if filteredResults.isEmpty {
                        Text("No test results available")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else {
                        chartContent
                    }
                }

                // Recent Results
                DetailCard(title: "Recent Tests") {
                    ForEach(filteredResults.prefix(5)) { result in
                        VStack(spacing: 8) {
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
                            Divider()
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Analytics")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showExportSheet = true }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showExportSheet) {
            if let data = generateExportData() {
                ShareSheet(activityItems: [data])
            }
        }
    }

    // MARK: - Helper Functions
    private func generateExportData() -> Data? {
        var csvString = "Date,Test Type,Accuracy,Status,Meter Size,Meter Type,Job Number\n"
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        
        for result in filteredResults {
            let line = "\(df.string(from: result.date)),\(result.testType.rawValue),\(String(format: "%.1f", result.reading.accuracy)),\(result.isPassing ? "PASS" : "FAIL"),\(result.meterSize),\(result.meterType),\(result.jobNumber)\n"
            csvString += line
        }
        return csvString.data(using: .utf8)
    }
}

// MARK: - Supporting Views
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
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(value)
                .font(.title2)
                .bold()
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// MARK: - Preview
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
            AnalyticsView()
                .environmentObject(vm)
        }
    }
}
