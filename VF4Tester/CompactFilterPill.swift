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
    
    private let darkShadow = Color.black.opacity(0.2)
    private let lightShadow = Color.white.opacity(0.7)
    
    @State private var feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: {
                feedbackGenerator.prepare() 
                feedbackGenerator.impactOccurred() 
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
                        color: .marsBlue
                    )
                    
                    // Meter Size Filter
                    FilterDropdown(
                        title: "Meter Size",
                        options: Array(TestHistoryView.MeterSizeFilter.allCases),
                        selection: $selectedMeterSize,
                        color: .marsBlue
                    )
                    
                    // Manufacturer Filter
                    FilterDropdown(
                        title: "Manufacturer",
                        options: Array(TestHistoryView.MeterManufacturerFilter.allCases),
                        selection: $selectedManufacturer,
                        color: .marsBlue
                    )
                    
                    // Sort Order
                    FilterDropdown(
                        title: "Sort By",
                        options: Array(TestHistoryView.SortOrder.allCases),
                        selection: $selectedSort,
                        color: .marsBlue
                    )
                    
                    // Date Range
                    DateRangeSelector(
                        title: "Date Range",
                        startDate: $startDate,
                        endDate: $endDate
                    )
                    
                    // Close and Clear All buttons
                    HStack(spacing: 12) {
                        Button(action: {
                            withAnimation {
                                isExpanded = false
                            }
                        }) {
                            Text("Close")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.blue.opacity(0.7))
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(darkShadow, lineWidth: 4)
                                            .blur(radius: 4)
                                            .offset(x: 2, y: 2)
                                            .mask(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .fill(LinearGradient(gradient: Gradient(colors: [.black, .clear]),
                                                                       startPoint: .topLeading,
                                                                       endPoint: .bottomTrailing))
                                            )
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(lightShadow, lineWidth: 4)
                                            .blur(radius: 4)
                                            .offset(x: -2, y: -2)
                                            .mask(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .fill(LinearGradient(gradient: Gradient(colors: [.clear, .black]),
                                                                       startPoint: .topLeading,
                                                                       endPoint: .bottomTrailing))
                                            )
                                    }
                                )
                        }
                        
                        Button(action: {
                            // Reset all filters
                            selectedFilter = .all
                            selectedSort = .descending
                            selectedMeterSize = .all
                            selectedManufacturer = .all
                            startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
                            endDate = Date()
                        }) {
                            Text("Clear All")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.red.opacity(0.7))
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(darkShadow, lineWidth: 4)
                                            .blur(radius: 4)
                                            .offset(x: 2, y: 2)
                                            .mask(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .fill(LinearGradient(gradient: Gradient(colors: [.black, .clear]),
                                                                       startPoint: .topLeading,
                                                                       endPoint: .bottomTrailing))
                                            )
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(lightShadow, lineWidth: 4)
                                            .blur(radius: 4)
                                            .offset(x: -2, y: -2)
                                            .mask(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .fill(LinearGradient(gradient: Gradient(colors: [.clear, .black]),
                                                                       startPoint: .topLeading,
                                                                       endPoint: .bottomTrailing))
                                            )
                                    }
                                )
                        }
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
