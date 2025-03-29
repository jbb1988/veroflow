import SwiftUI

struct RecentTestsView: View {
    let results: [TestResult]
    @Binding var selectedTest: TestResult?
    
    var body: some View {
        DetailCard(title: "Recent Tests") {
            ForEach(results.sorted(by: { $0.date > $1.date }).prefix(5)) { result in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        selectedTest = result
                    }
                } label: {
                    HStack(spacing: 16) {
                        Circle()
                            .fill(result.isPassing ? Color.green : Color.red)
                            .frame(width: 8, height: 8)
                            .padding(4)
                            .background(
                                Circle()
                                    .fill(result.isPassing ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                            )
                        
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(result.testType.rawValue)
                                    .font(.headline)
                                Spacer()
                                Text(String(format: "%.1f%%", result.reading.accuracy))
                                    .font(.title3)
                                    .bold()
                                    .foregroundColor(result.isPassing ? .green : .red)
                            }
                            
                            Text(result.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 12) {
                                Label(
                                    String(format: "%.1f", result.reading.smallMeterStart),
                                    systemImage: "arrow.forward.circle.fill"
                                )
                                .foregroundColor(.blue)
                                
                                Label(
                                    String(format: "%.1f", result.reading.smallMeterEnd),
                                    systemImage: "arrow.backward.circle.fill"
                                )
                                .foregroundColor(.purple)
                                
                                Label(
                                    String(format: "%.1f Gal", result.reading.totalVolume),
                                    systemImage: "drop.fill"
                                )
                                .foregroundColor(.cyan)
                            }
                            .font(.footnote)
                        }
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue.opacity(0.9), lineWidth: 2)
                    )
                    .shadow(color: Color.blue.opacity(0.5), radius: 4, x: 0, y: 0)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.vertical, 4)
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
}
