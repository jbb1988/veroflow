import SwiftUI

struct PaginatedTestHistoryView: View {
    @EnvironmentObject var viewModel: TestViewModel
    @State private var displayedResults: [TestResult] = []
    @State private var currentPage = 0
    @State private var isLoading = false
    private let resultsPerPage = 20
    
    var body: some View {
        VStack {
            // Header stays the same
            Text("Test History")
                .font(.largeTitle)
                .padding()
            
            if displayedResults.isEmpty && !isLoading {
                Text("No test results available")
                    .foregroundColor(.secondary)
            } else {
                List {
                    ForEach(displayedResults) { result in
                        TestHistoryRow(result: result)
                            .onAppear {
                                // If this is one of the last items, load more
                                if result.id == displayedResults.last?.id {
                                    loadMoreContent()
                                }
                            }
                    }
                    
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .listRowBackground(Color.clear)
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .onAppear {
            loadInitialContent()
        }
    }
    
    private func loadInitialContent() {
        currentPage = 0
        displayedResults = Array(viewModel.testResults.prefix(resultsPerPage))
    }
    
    private func loadMoreContent() {
        guard !isLoading else { return }
        
        isLoading = true
        
        // Simulate network delay for smooth loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let nextBatch = viewModel.testResults
                .dropFirst(currentPage * resultsPerPage)
                .prefix(resultsPerPage)
            
            displayedResults.append(contentsOf: nextBatch)
            currentPage += 1
            isLoading = false
        }
    }
}

struct TestHistoryRow: View {
    let result: TestResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(result.isPassing ? Color.green : Color.red)
                    .frame(width: 12, height: 12)
                
                Text(result.testType.rawValue)
                    .font(.headline)
                
                Spacer()
                
                Text(result.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Label("Accuracy:", systemImage: "percent")
                Text(String(format: "%.1f%%", result.reading.accuracy))
                    .foregroundColor(result.isPassing ? .green : .red)
            }
            .font(.subheadline)
            
            if !result.notes.isEmpty {
                Text(result.notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 8)
    }
}