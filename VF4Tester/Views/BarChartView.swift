import SwiftUI
import Charts

struct BarChartView: View {
    let result: TestResult
    
    var body: some View {
        BarMark(
            x: .value("Date", result.date),
            y: .value("Accuracy", result.reading.accuracy)
        )
        .foregroundStyle(result.isPassing ?
            Color.green.opacity(0.8) : Color.red.opacity(0.8))
    }
}

