import SwiftUI
import Charts

struct LineChartView: View {
    let result: TestResult
    
    var body: some View {
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
}

