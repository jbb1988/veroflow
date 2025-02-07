import SwiftUI
import Charts

struct AnalyticsView: View {
    @EnvironmentObject var viewModel: TestViewModel
    @State private var selectedFilter: FilterOption = .all
    @State private var showTrendLine: Bool = false
    @State private var showingExportSheet: Bool = false
    @State private var exportData: Data? = nil
    @State private var showFailedTests = false

    enum FilterOption: String, CaseIterable, Identifiable {
        case all = "All Tests"
        case lowFlow = "Low Flow"
        case highFlow = "High Flow"
        var id: Self { self }
    }

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

    var failedTestsCount: Int {
        filteredResults.filter { !$0.isPassing }.count
    }

    var chartContent: some View {
        Chart {
            // Add pass/fail zones
            ForEach(filteredResults.sorted(by: { $0.date < $1.date })) { result in
                RectangleMark(
                    xStart: .value("Start", result.date),
                    xEnd: .value("End", result.date),
                    yStart: .value("Lower", 95),
                    yEnd: .value("Upper", 101)
                )
                .foregroundStyle(Color.green.opacity(0.1))
            }

            // Add data points
            ForEach(filteredResults.sorted(by: { $0.date < $1.date })) { result in
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

            // Add threshold lines
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
        .chartYScale(domain: 0...120)
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

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                DetailCard(title: "Chart Options") {
                    VStack(spacing: 12) {
                        Picker("Test Type", selection: $selectedFilter) {
                            ForEach(FilterOption.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())

                        Divider()

                        Toggle("Show Trend Line", isOn: $showTrendLine)
                    }
                }

                VStack(spacing: 16) {
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
                    }
                    
                    HStack(spacing: 16) {
                        StatCard(
                            title: "Total Tests",
                            value: "\(filteredResults.count)",
                            color: .purple,
                            icon: "number.circle.fill"
                        )
                        
                        NavigationLink {
                            TestHistoryView()
                                .onAppear {
                                    viewModel.selectedHistoryFilter = .failing
                                }
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
                Button(action: { showingExportSheet = true }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showingExportSheet) {
            if let data = generateExportData() {
                ShareSheet(activityItems: [data])
            }
        }
    }

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
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
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
