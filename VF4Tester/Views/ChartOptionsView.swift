import SwiftUI

struct ChartOptionsView: View {
    @Binding var showTrendLine: Bool
    @Binding var chartStartDate: Date
    @Binding var chartEndDate: Date
    
    var body: some View {
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
    }
}

