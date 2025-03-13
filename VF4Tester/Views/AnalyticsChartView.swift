import SwiftUI
import Charts

struct AnalyticsChartView: View {
    let chartFilteredResults: [TestResult]
    let averageAccuracy: Double
    let accuracyDomain: ClosedRange<Double>
    @Binding var showTrendLine: Bool
    @Binding var chartType: ChartType

    private let transitionDuration: Double = 0.3

    private var sortedResults: [TestResult] {
        chartFilteredResults.sorted { $0.date < $1.date }
    }

    var body: some View {
        Chart {
            // Draw background area once if available
            if let minDate = chartFilteredResults.map({ $0.date }).min(),
               let maxDate = chartFilteredResults.map({ $0.date }).max() {
                RectangleMark(
                    xStart: .value("Start", minDate),
                    xEnd: .value("End", maxDate),
                    yStart: .value("Lower", 95),
                    yEnd: .value("Upper", 101)
                )
                .foregroundStyle(Color.green.opacity(0.1))
            }
            
            // Simplified chart marks with better scaling
            ForEach(chartFilteredResults.sorted(by: { $0.date < $1.date })) { result in
                switch chartType {
                case .line:
                    LineMark(
                        x: .value("Date", result.date),
                        y: .value("Accuracy", result.reading.accuracy)
                    )
                    .foregroundStyle(result.isPassing ?
                        Color.green.opacity(0.8) : Color.red.opacity(0.8))
                    .symbol {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        result.isPassing ? .green : .red,
                                        result.isPassing ? .green.opacity(0.7) : .red.opacity(0.7)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 10, height: 10)
                            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                    }
                case .bar:
                    BarMark(
                        x: .value("Date", result.date),
                        y: .value("Accuracy", result.reading.accuracy)
                    )
                    .foregroundStyle(result.isPassing ?
                        Color.green.opacity(0.8) : Color.red.opacity(0.8))
                    .cornerRadius(4)
                case .scatter:
                    PointMark(
                        x: .value("Date", result.date),
                        y: .value("Accuracy", result.reading.accuracy)
                    )
                    .foregroundStyle(result.isPassing ?
                        Color.green.opacity(0.8) : Color.red.opacity(0.8))
                }
            }
        }
        .chartYScale(domain: accuracyDomain)
        // Add padding to chart scale for better bar display
        .chartXScale(domain: {
            let dates = chartFilteredResults.map { $0.date }
            guard let minDate = dates.min(), let maxDate = dates.max() else {
                return Date().addingTimeInterval(-86400)...Date()
            }
            return minDate.addingTimeInterval(-7200)...maxDate.addingTimeInterval(7200)
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
