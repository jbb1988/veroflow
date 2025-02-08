import SwiftUI

#if os(iOS)
import UIKit
#endif

struct TestView: View {
    @EnvironmentObject var viewModel: TestViewModel
    @Environment(\.colorScheme) var colorScheme
    @FocusState private var focusedField: Field?
    @State private var showingClearConfirmation = false
    
    // Local state for input fields with empty defaults
    @State private var totalVolumeText: String = ""
    @State private var flowRateText: String = ""
    @State private var selectedMeterSize: MeterSize = .one
    @State private var selectedMeterType: MeterType = .neptune
    @State private var jobNumberText: String = ""
    @State private var additionalRemarksText: String = ""
    
    // Custom colors
    private let primaryColor = Color.blue
    private let accentColor = Color.purple
    private let sectionHeaderColor = Color.white
    
    var isLowFlowTest: Bool {
        viewModel.currentTest == .lowFlow
    }
    
    var passRangeText: String {
        isLowFlowTest ? "95% - 101%" : "98.5% - 101.5%"
    }
    
    private func clearAllFields() {
        // Clear all text fields
        totalVolumeText = ""
        flowRateText = ""
        jobNumberText = ""
        additionalRemarksText = ""
        
        // Clear meter readings
        viewModel.smallMeterStart = ""
        viewModel.smallMeterEnd = ""
        viewModel.largeMeterStart = ""
        viewModel.largeMeterEnd = ""
        
        // Reset view model values
        viewModel.totalVolume = 0.0
        viewModel.flowRate = 0.0
        viewModel.notes = ""
        
        // Reset selections to defaults
        selectedMeterSize = .one
        selectedMeterType = .neptune
        
        // Dismiss keyboard if active
        dismissKeyboard()
    }
    
    var body: some View {
        Form {
            testTypeSection
            meterReadingsSection
            testParametersSection
            additionalDetailsSection
            notesSection
            recordTestSection
            latestResultSection
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Image("veroflowLogo")
                    .resizable()
                    .renderingMode(.original)
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 40)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(colorScheme == .dark ? Color.white : Color(UIColor.systemBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    )
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(action: { dismissKeyboard() }) {
                    Image(systemName: "keyboard.chevron.compact.down")
                        .foregroundColor(primaryColor)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingClearConfirmation = true
                }) {
                    Label("Clear All", systemImage: "trash")
                        .foregroundColor(primaryColor)
                }
            }
        }
        .onAppear {
            viewModel.loadData()
        }
        .alert(
            item: Binding(
                get: { viewModel.errorMessage.map { SimpleError(message: $0) } },
                set: { _ in viewModel.errorMessage = nil }
            )
        ) { error in
            Alert(
                title: Text("Error"),
                message: Text(error.message),
                dismissButton: .default(Text("OK"))
            )
        }
        .alert("Clear All Fields", isPresented: $showingClearConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                clearAllFields()
            }
        } message: {
            Text("Are you sure you want to clear all fields? This action cannot be undone.")
        }
    }
    
    // MARK: - Form Sections
    private var testTypeSection: some View {
        Section {
            Picker("Test Type", selection: $viewModel.currentTest) {
                Text("Low Flow (0.75-40 GPM)").tag(TestType.lowFlow)
                Text("High Flow (25-650 GPM)").tag(TestType.highFlow)
            }
            .pickerStyle(SegmentedPickerStyle())
        }
        .listRowBackground(Color(UIColor.systemGray6))
    }
    
    private var meterReadingsSection: some View {
        Section {
            VStack(spacing: 16) {
                smallMeterReadings
                Divider()
                largeMeterReadings
            }
        } header: {
            Label("Meter Readings", systemImage: "gauge")
                .foregroundColor(sectionHeaderColor)
                .font(.headline)
        }
    }
    
    private var smallMeterReadings: some View {
        VStack(alignment: .leading) {
            Label("Small Meter Readings", systemImage: "speedometer")
                .font(.subheadline)
                .bold()
                .foregroundColor(primaryColor)
            HStack {
                MarsReadingField(
                    title: "Start",
                    text: $viewModel.smallMeterStart,
                    focusField: _focusedField.projectedValue,
                    field: .smallStart
                )
                Spacer()
                MarsReadingField(
                    title: "End",
                    text: $viewModel.smallMeterEnd,
                    focusField: _focusedField.projectedValue,
                    field: .smallEnd
                )
                .onSubmit {
                    if let start = Double(viewModel.smallMeterStart),
                       let end = Double(viewModel.smallMeterEnd),
                       end < start {
                        viewModel.errorMessage = "Small meter: End reading must be ≥ start reading."
                    } else {
                        viewModel.errorMessage = nil
                    }
                }
            }
        }
    }

    private var largeMeterReadings: some View {
        VStack(alignment: .leading) {
            Label("Large Meter Readings", systemImage: "dial.max")
                .font(.subheadline)
                .bold()
                .foregroundColor(primaryColor)
            HStack {
                MarsReadingField(
                    title: "Start",
                    text: $viewModel.largeMeterStart,
                    focusField: _focusedField.projectedValue,
                    field: .largeStart
                )
                Spacer()
                MarsReadingField(
                    title: "End",
                    text: $viewModel.largeMeterEnd,
                    focusField: _focusedField.projectedValue,
                    field: .largeEnd
                )
                .onSubmit {
                    if let start = Double(viewModel.largeMeterStart),
                       let end = Double(viewModel.largeMeterEnd),
                       end < start {
                        viewModel.errorMessage = "Large meter: End reading must be ≥ start reading."
                    } else {
                        viewModel.errorMessage = nil
                    }
                }
            }
        }
    }
    
    private var testParametersSection: some View {
        Section {
            HStack {
                Label("Total Volume", systemImage: "drop")
                    .foregroundColor(primaryColor)
                Spacer()
                TextField("Volume", text: $totalVolumeText)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 100)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .totalVolume)
                    .onChange(of: totalVolumeText) { newValue in
                        if let newVolume = Double(newValue) {
                            viewModel.totalVolume = newVolume
                        }
                    }
            }
            HStack {
                Label("Flow Rate", systemImage: "water.waves")
                    .foregroundColor(primaryColor)
                Spacer()
                TextField("GPM", text: $flowRateText)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 100)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .flowRate)
                    .onChange(of: flowRateText) { newValue in
                        if let newFlowRate = Double(newValue) {
                            viewModel.flowRate = newFlowRate
                        }
                    }
                Text("GPM")
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Label("Meter Size", systemImage: "ruler")
                    .foregroundColor(primaryColor)
                Picker("", selection: $selectedMeterSize) {
                    ForEach(MeterSize.allCases, id: \.self) { size in
                        Text(size.rawValue).tag(size)
                    }
                }
            }
            
            HStack {
                Label("Meter Type", systemImage: "dial.medium")
                    .foregroundColor(primaryColor)
                Picker("", selection: $selectedMeterType) {
                    ForEach(MeterType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
            }
        } header: {
            Label("Test Parameters", systemImage: "slider.horizontal.3")
                .foregroundColor(sectionHeaderColor)
                .font(.headline)
        }
    }
    
    private var additionalDetailsSection: some View {
        Section {
            HStack {
                Label("Job Number", systemImage: "number")
                    .foregroundColor(primaryColor)
                TextField("Enter job number", text: $jobNumberText)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .jobNumber)
            }
            HStack {
                Label("Remarks", systemImage: "text.bubble")
                    .foregroundColor(primaryColor)
                TextField("Add remarks", text: $additionalRemarksText)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .additionalRemarks)
            }
        } header: {
            Label("Additional Details", systemImage: "doc.text")
                .foregroundColor(sectionHeaderColor)
                .font(.headline)
        }
    }
    
    private var notesSection: some View {
        Section {
            TextEditor(text: $viewModel.notes)
                .frame(minHeight: 100)
                .placeholder(when: viewModel.notes.isEmpty) {
                    Text("Enter additional notes here...")
                        .foregroundColor(.gray)
                }
        } header: {
            Label("Notes", systemImage: "note.text")
                .foregroundColor(sectionHeaderColor)
                .font(.headline)
        }
    }
    
    private var recordTestSection: some View {
        Section {
            Button(action: {
                dismissKeyboard()
                viewModel.isCalculatingResults = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    let additionalInfo = """
                        
                        Meter Size: \(selectedMeterSize.rawValue)
                        Meter Type: \(selectedMeterType.rawValue)
                        Job #: \(jobNumberText)
                        Remarks: \(additionalRemarksText)
                        """
                    viewModel.notes += additionalInfo
                    viewModel.calculateResults(with: nil)
                    
                    // Clear input fields
                    viewModel.smallMeterStart = ""
                    viewModel.smallMeterEnd = ""
                    viewModel.largeMeterStart = ""
                    viewModel.largeMeterEnd = ""
                    viewModel.totalVolume = 0.0
                    viewModel.flowRate = 0.0
                    viewModel.notes = ""
                    totalVolumeText = ""
                    flowRateText = ""
                    jobNumberText = ""
                    additionalRemarksText = ""
                    
                    viewModel.isCalculatingResults = false
                }
            }) {
                Label("Record Test", systemImage: "square.and.arrow.down")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [primaryColor, accentColor]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            .disabled(viewModel.isCalculatingResults)
        }
    }
    
    private var latestResultSection: some View {
        Group {
            if viewModel.showingResults, let result = viewModel.testResults.last {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Test Type: \(result.testType.rawValue)", systemImage: "checkmark.circle")
                            .font(.headline)
                            .foregroundColor(primaryColor)
                        Label("Accuracy: \(String(format: "%.1f%%", result.reading.accuracy))",
                              systemImage: "percent")
                            .foregroundColor(result.isPassing ? .green : .red)
                        Label("Status: \(result.isPassing ? "PASS" : "FAIL")",
                              systemImage: result.isPassing ? "checkmark.seal" : "xmark.seal")
                            .foregroundColor(result.isPassing ? .green : .red)
                        Label("Pass Range: \(passRangeText)", systemImage: "ruler.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Label("Latest Result", systemImage: "chart.bar")
                        .foregroundColor(sectionHeaderColor)
                        .font(.headline)
                }
            }
        }
    }
    
    private func dismissKeyboard() {
        focusedField = nil
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
    }
}

struct SimpleError: Identifiable {
    let id = UUID()
    let message: String
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TestView()
                .environmentObject(TestViewModel())
        }
    }
}
