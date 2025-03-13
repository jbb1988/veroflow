import SwiftUI
import Charts

struct ChartTooltip: View {
    let date: Date
    let accuracy: Double
    let isPassing: Bool
    let meterSize: String
    let meterType: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(date.formatted(.dateTime.month().day()))
                .font(.system(.headline, design: .rounded))
            Text(date.formatted(.dateTime.hour().minute()))
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(.secondary)
            Divider()
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Accuracy")
                        .font(.system(.subheadline, design: .rounded))
                    Spacer()
                    Text(String(format: "%.1f%%", accuracy))
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(isPassing ? .green : .red)
                }
                HStack {
                    Text("Meter Size")
                        .font(.system(.subheadline, design: .rounded))
                    Spacer()
                    Text(meterSize)
                        .font(.system(.subheadline, design: .rounded))
                }
                HStack {
                    Text("Meter Mfg.")
                        .font(.system(.subheadline, design: .rounded))
                    Spacer()
                    Text(meterType)
                        .font(.system(.subheadline, design: .rounded))
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isPassing ? Color.green.opacity(0.3) : Color.red.opacity(0.3), lineWidth: 1)
        )
    }
}

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

    @State private var selectedResult: TestResult?
    @GestureState private var scale: CGFloat = 1.0
    @State private var tooltipPosition: CGPoint = .zero
    @State private var chartSize: CGSize = .zero
    
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
            .interpolationMethod(.monotone)
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

    private func formatDate(_ date: Date) -> String {
        date.formatted(.dateTime.month().day().hour().minute())
    }

    private func updateTooltipPosition(in geometry: GeometryProxy, proxy: ChartProxy, at xPosition: CGFloat) {
        let padding: CGFloat = 20
        let tooltipWidth: CGFloat = 200
        let tooltipHeight: CGFloat = 160

        var xPos = xPosition - tooltipWidth/2
        xPos = max(padding, xPos)
        xPos = min(geometry.size.width - tooltipWidth - padding, xPos)

        var yPos: CGFloat
        if let result = selectedResult,
           let yPosition = proxy.position(forY: result.reading.accuracy) {
            if yPosition < geometry.size.height / 2 {
                yPos = yPosition + padding
            } else {
                yPos = yPosition - tooltipHeight - padding
            }
        } else {
            yPos = padding
        }

        yPos = max(padding, yPos)
        yPos = min(geometry.size.height - tooltipHeight - padding, yPos)

        tooltipPosition = CGPoint(x: xPos, y: yPos)
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
            return minDate...maxDate
        }())
        .chartPlotStyle { plotArea in
            plotArea.frame(height: 300)
                .clipped()
        }
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
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle()
                    .fill(.clear)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let tapLocation = value.location
                                guard let date = proxy.value(atX: tapLocation.x, as: Date.self),
                                      let accuracy = proxy.value(atY: tapLocation.y, as: Double.self) else {
                                    return
                                }

                                let closestResult = sortedResults.min(by: { result1, result2 in
                                    let x1 = proxy.position(forX: result1.date) ?? 0
                                    let y1 = proxy.position(forY: result1.reading.accuracy) ?? 0
                                    let distance1 = sqrt(pow(x1 - tapLocation.x, 2) + pow(y1 - tapLocation.y, 2))

                                    let x2 = proxy.position(forX: result2.date) ?? 0
                                    let y2 = proxy.position(forY: result2.reading.accuracy) ?? 0
                                    let distance2 = sqrt(pow(x2 - tapLocation.x, 2) + pow(y2 - tapLocation.y, 2))

                                    return distance1 < distance2
                                })

                                if let closestResult = closestResult,
                                   selectedResult?.id != closestResult.id {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedResult = closestResult
                                        if let xPosition = proxy.position(forX: closestResult.date) {
                                            updateTooltipPosition(in: geometry, proxy: proxy, at: xPosition)
                                        }
                                    }
                                }
                            }
                            .onEnded { _ in
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedResult = nil
                                }
                            }
                    )
            }
        }
        .chartBackground { proxy in
            GeometryReader { geometry in
                if let result = selectedResult {
                    ChartTooltip(
                        date: result.date,
                        accuracy: result.reading.accuracy,
                        isPassing: result.isPassing,
                        meterSize: result.meterSize,
                        meterType: result.meterType
                    )
                    .frame(width: 200)
                    .position(tooltipPosition)
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
                }
            }
        }
        .animation(.easeInOut(duration: transitionDuration), value: chartType)
        .animation(.easeInOut(duration: transitionDuration), value: sortedResults)
        .frame(height: 300)
        .padding()
    }
}
