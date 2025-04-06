import SwiftUI

struct AccuracyToleranceView: View {
    // MARK: - Models
    struct ToleranceData: Identifiable {
        let id = UUID()
        let meterType: String
        let lowFlow: String
        let midHighFlow: String
    }
    
    // MARK: - Properties
    private let largeMeterData: [ToleranceData] = [
        // CHANGE: Fixed low flow range for PD & Single-Jet to show 95% - 101%
        .init(meterType: "Positive Displacement & Single-Jet", lowFlow: "95% - 101%", midHighFlow: "98.5% - 101.5%"),
        .init(meterType: "Multi-Jet", lowFlow: "97% - 103%", midHighFlow: "98.5% - 101.5%"),
        .init(meterType: "Turbine (Class II)", lowFlow: "98.5% - 101.5%", midHighFlow: "98.5% - 101.5%"),
        .init(meterType: "Electromagnetic/Ultrasonic", lowFlow: "95% - 105%", midHighFlow: "98.5% - 101.5%"),
        .init(meterType: "Fire Service", lowFlow: "95% - 101.5%", midHighFlow: "98.5% - 101.5%"),
        .init(meterType: "Compound", lowFlow: "95% - 101%", midHighFlow: "98.5% - 101.5%\n97% - 103%")
    ]
    
    private let smallMeterData: [ToleranceData] = [
        // CHANGE: Fixed low flow range for PD & Single-Jet to show 95% - 101%
        .init(meterType: "Positive Displacement & Single-Jet", lowFlow: "95% - 101%", midHighFlow: "98.5% - 101.5%")
    ]
    
    // MARK: - Body
    var body: some View {
        List {
            Section {
                ToleranceTableView(title: "Large Meters (3\" and Larger)", data: largeMeterData)
            }
            
            Section {
                ToleranceTableView(title: "Small Meters (5/8\" to 2\")", data: smallMeterData)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Accuracy Tolerances")
    }
}

// MARK: - ToleranceTableView
struct ToleranceTableView: View {
    let title: String
    let data: [AccuracyToleranceView.ToleranceData]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .padding(.bottom, 8)
            
            // Header
            HStack {
                Text("Meter Type")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Low Flow")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(width: 100)
                
                Text("Mid/High")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(width: 100)
            }
            
            // Data rows
            ForEach(data) { item in
                Divider()
                HStack(alignment: .top) {
                    Text(item.meterType)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(item.lowFlow)
                        .font(.subheadline)
                        .frame(width: 100)
                    
                    Text(item.midHighFlow)
                        .font(.subheadline)
                        .frame(width: 100)
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(10)
    }
}
