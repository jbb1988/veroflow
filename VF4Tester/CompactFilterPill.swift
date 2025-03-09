import SwiftUI

extension TestHistoryView.SortOrder: Identifiable {
    public var id: Self { self }
}

struct CompactFilterPill: View {
    @Binding var isExpanded: Bool
    @Binding var selectedFilter: TestHistoryView.FilterOption
    @Binding var selectedSort: TestHistoryView.SortOrder
    @Binding var startDate: Date
    @Binding var endDate: Date
    @Binding var selectedMeterSize: TestHistoryView.MeterSizeFilter
    @Binding var selectedManufacturer: TestHistoryView.MeterManufacturerFilter
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .foregroundColor(.blue)
                    
                    Text("Filters & Sort")
                        .font(.system(size: 15, weight: .medium))
                    
                    Spacer()
                    
                    Text(selectedFilter.rawValue)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(UIColor.secondarySystemBackground))
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                VStack(spacing: 16) {
                    // Test Type Filter
                    FilterDropdown(
                        title: "Test Type",
                        options: Array(TestHistoryView.FilterOption.allCases),
                        selection: $selectedFilter,
                        color: selectedFilter.borderColor
                    )
                    
                    // Meter Size Filter
                    FilterDropdown(
                        title: "Meter Size",
                        options: Array(TestHistoryView.MeterSizeFilter.allCases),
                        selection: $selectedMeterSize,
                        color: .green
                    )
                    
                    // Manufacturer Filter
                    FilterDropdown(
                        title: "Manufacturer",
                        options: Array(TestHistoryView.MeterManufacturerFilter.allCases),
                        selection: $selectedManufacturer,
                        color: .orange
                    )
                    
                    // Sort Order
                    FilterDropdown(
                        title: "Sort By",
                        options: Array(TestHistoryView.SortOrder.allCases),
                        selection: $selectedSort,
                        color: .purple
                    )
                    
                    // Date Range
                    DateRangeSelector(
                        title: "Date Range",
                        startDate: $startDate,
                        endDate: $endDate
                    )
                    
                    // Close Button
                    Button(action: {
                        withAnimation {
                            isExpanded = false
                        }
                    }) {
                        Text("Close")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(UIColor.systemBackground))
                        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}