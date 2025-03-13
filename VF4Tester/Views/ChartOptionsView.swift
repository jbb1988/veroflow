import SwiftUI

struct ChartOptionsView: View {
    @Binding var showTrendLine: Bool
    @Binding var chartStartDate: Date
    @Binding var chartEndDate: Date
    @Binding var selectedHistoryFilter: TestHistoryView.FilterOption
    @Binding var selectedSortOrder: TestHistoryView.SortOrder
    @Binding var selectedMeterSize: TestHistoryView.MeterSizeFilter
    @Binding var selectedManufacturer: TestHistoryView.MeterManufacturerFilter
    @Binding var selectedChartType: ChartType

    @State private var isFilterExpanded: Bool = false

    var body: some View {
        DetailCard(title: "Chart Options") {
            VStack(spacing: 16) {
                Toggle("Show Trend Line", isOn: $showTrendLine)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Chart Date Range")
                        .font(.headline)
                    DatePicker("Start", selection: $chartStartDate, displayedComponents: .date)
                    DatePicker("End", selection: $chartEndDate, displayedComponents: .date)
                }

                CompactFilterPill(
                    isExpanded: $isFilterExpanded,
                    selectedFilter: $selectedHistoryFilter,
                    selectedSort: $selectedSortOrder,
                    startDate: $chartStartDate,
                    endDate: $chartEndDate,
                    selectedMeterSize: $selectedMeterSize,
                    selectedManufacturer: $selectedManufacturer
                )
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.black)
            }
        }
    }
}
