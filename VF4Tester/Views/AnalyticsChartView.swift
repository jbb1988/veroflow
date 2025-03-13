import SwiftUI
import Charts

struct AnalyticsChartView: View {
    let chartFilteredResults: [TestResult]
    let averageAccuracy: Double
    let accuracyDomain: ClosedRange<Double>
    @Binding var showTrendLine: Bool
    @Binding var chartType: ChartType

    private let transitionDuration: Double = 0.3

    private var dateRange: (min: Date?, max: Date?) {
        let dates = chartFilteredResults.map { $0.date }
        return (dates.min(), dates.max())
    }

    private var sortedResults: [TestResult] {
        chartFilteredResults.sorted { $0.date < $1.date }
    }

    @ChartContentBuilder
    private func makeChartBackgroundArea(minDate: Date?, maxDate: Date?) -> some ChartContent {
        if let minDate = minDate, let maxDate = maxDate {
            RectangleMark(
                xStart: .value("Start", minDate),
                xEnd: .value("End", maxDate),
                yStart: .value("Lower", 95),
                yEnd: .value("Upper", 101)
            )
            .foregroundStyle(Color.green.opacity(0.1))
        }
    }

    private func makeAverageLine() -> some ChartContent {
        RuleMark(y: .value("Average", averageAccuracy))
            .foregroundStyle(.blue.opacity(0.5))
            .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
    }

    @ChartContentBuilder
    private func makeChartMarks(for result: TestResult) -> some ChartContent {
        switch chartType {
        case .line:
            LineMark(
                x: .value("Date", result.date),
                y: .value("Accuracy", result.reading.accuracy)
            )
            .foregroundStyle(result.isPassing ? Color.green.opacity(0.8) : Color.red.opacity(0.8))
            .symbol { makeSymbol(isPassing: result.isPassing) }
        case .area:
            AreaMark(
                x: .value("Date", result.date),
                y: .value("Accuracy", result.reading.accuracy)
            )
            .foregroundStyle(makeGradient(isPassing: result.isPassing))
            .symbol { makeSmallSymbol(isPassing: result.isPassing) }
        case .scatter:
            PointMark(
                x: .value("Date", result.date),
                y: .value("Accuracy", result.reading.accuracy)
            )
            .foregroundStyle(result.isPassing ? Color.green.opacity(0.8) : Color.red.opacity(0.8))
        }
    }

    private func makeSymbol(isPassing: Bool) -> some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [
                        isPassing ? .green : .red,
                        isPassing ? .green.opacity(0.7) : .red.opacity(0.7)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: 10, height: 10)
            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
    }

    private func makeSmallSymbol(isPassing: Bool) -> some View {
        Circle()
            .fill(isPassing ? Color.green : Color.red)
            .frame(width: 6, height: 6)
    }

    private func makeGradient(isPassing: Bool) -> LinearGradient {
        LinearGradient(
            colors: [
                isPassing ? Color.green.opacity(0.3) : Color.red.opacity(0.3),
                isPassing ? Color.green.opacity(0.1) : Color.red.opacity(0.1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    var body: some View {
        Chart {
            makeChartBackgroundArea(minDate: dateRange.min, maxDate: dateRange.max)
            makeAverageLine()
            ForEach(sortedResults) { result in
                makeChartMarks(for: result)
            }
        }
        .chartYScale(domain: accuracyDomain)
        .chartXScale(domain: {
            guard let minDate = dateRange.min,
                  let maxDate = dateRange.max else {
                return Date().addingTimeInterval(-86400)...Date()
            }
            let startInterval = minDate.addingTimeInterval(-7200)
            let endInterval = maxDate.addingTimeInterval(7200)
            return startInterval...endInterval
        }())
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { value in
                if let date = value.as(Date.self) {
                    AxisValueLabel {
                        Text(date.formatted(.dateTime.month().day()))
                            .font(.system(.caption2, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    AxisTick()
                    AxisGridLine()
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: .stride(by: 5)) { value in
                AxisGridLine()
                    .foregroundStyle(Color.gray.opacity(0.2))
                AxisValueLabel {
                    if let accuracy = value.as(Double.self) {
                        Text("\(Int(accuracy))%")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .animation(.easeInOut(duration: transitionDuration), value: chartType)
        .animation(.easeInOut(duration: transitionDuration), value: sortedResults)
        .frame(height: 300)
        .padding()
    }
}
