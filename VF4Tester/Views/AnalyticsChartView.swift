import SwiftUI
import Charts

struct AnalyticsChartView: View {
    let chartFilteredResults: [TestResult]
    let averageAccuracy: Double
    let accuracyDomain: ClosedRange<Double>
    @Binding var showTrendLine: Bool
    
    var body: some View {
        Chart {
            if let minDate = chartFilteredResults.map(\.date).min(),
               let maxDate = chartFilteredResults.map(\.date).max() {
                RectangleMark(
                    xStart: .value("Start", minDate),
                    xEnd: .value("End", maxDate),
                    yStart: .value("Lower", 95),
                    yEnd: .value("Upper", 101)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.green.opacity(0.1), Color.green.opacity(0.2)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            
            ForEach(chartFilteredResults.sorted(by: { $0.date < $1.date })) { result in
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
            }

            if showTrendLine {
                RuleMark(y: .value("Average", averageAccuracy))
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                    .foregroundStyle(Color.blue.opacity(0.7))
                    .annotation(position: .leading) {
                        Text(String(format: "Avg: %.1f%%", averageAccuracy))
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.blue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
            }

            RuleMark(y: .value("Low Flow Min", 95))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                .foregroundStyle(Color.yellow.opacity(0.7))
            RuleMark(y: .value("High Flow Min", 98.5))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                .foregroundStyle(Color.green.opacity(0.7))
            RuleMark(y: .value("Max", 101.5))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                .foregroundStyle(Color.red.opacity(0.7))
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
            AxisMarks(position: .leading, values: .stride(by: 5)) { value in
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
}

