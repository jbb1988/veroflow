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
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text(selectedFilter.rawValue)
                        .font(.system(size: 14))
                        .foregroundColor(.blue)
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(.blue)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(
                    ZStack {
                        Color.black.opacity(0.5)
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue.opacity(0.2),
                                Color.blue.opacity(0.05)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.blue.opacity(0.8),
                                    Color.blue.opacity(0.2)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: Color.blue.opacity(0.2), radius: 8, x: 0, y: 0)
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
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color(hex: "003366"), Color(hex: "007AFF")]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                        VisualEffectBlur(blurStyle: .systemUltraThinMaterialDark)
                                    }
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.blue.opacity(0.9), lineWidth: 2)
                                )
                                .shadow(color: Color.blue.opacity(0.5), radius: 20, x: 0, y: 10)
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
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color(hex: "660000"), Color(hex: "FF2D55")]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                        VisualEffectBlur(blurStyle: .systemUltraThinMaterialDark)
                                    }
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.red.opacity(0.9), lineWidth: 2)
                                )
                                .shadow(color: Color.red.opacity(0.5), radius: 20, x: 0, y: 10)
                        }
                    }
                }
                .padding(16)
                .background(
                    ZStack {
                        Color.black.opacity(0.5)
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue.opacity(0.2),
                                Color.blue.opacity(0.05)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.blue.opacity(0.8),
                                    Color.blue.opacity(0.2)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: Color.blue.opacity(0.2), radius: 8, x: 0, y: 0)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}
