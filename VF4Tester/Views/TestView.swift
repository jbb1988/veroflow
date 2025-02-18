import SwiftUI
import Foundation
#if os(iOS)
import UIKit
#endif

// Reusable Test Type Button remains unchanged.
struct TestTypeButton: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let borderColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(8)
            .background(isSelected ? borderColor.opacity(0.2) : Color(UIColor.secondarySystemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(borderColor, lineWidth: 2)
            )
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TestView: View {
    @EnvironmentObject var viewModel: TestViewModel
    @Environment(\.colorScheme) var colorScheme
    @FocusState private var focusedField: Field?
    @State private var showingClearConfirmation = false
    @State private var showToast = false
    @State private var isRecordSuccess = false
    @State private var showingValidationAlert = false
    @State private var validationErrors: [String] = []

    // AppStorage properties
    @AppStorage("showMeterMfgInput") var showMeterMfgInput: Bool = true
    @AppStorage("showMeterModelInput") var showMeterModelInput: Bool = true

    // MARK: - Input State Variables
    @State private var totalVolumeText: String = ""
    @State private var flowRateText: String = ""
    @State private var selectedMeterSize: MeterSize = .one
    @State private var selectedMeterType: MeterType = .neptune
    @State private var selectedMeterModel: MeterModel = .positiveDisplacement
    @State private var jobNumberText: String = ""
    @State private var additionalRemarksText: String = ""
    @State private var isCompoundMeter: Bool = false

    enum SingleMeterOption: String, CaseIterable {
        case small = "Small Meter"
        case large = "Large Meter"
    }
    @State private var selectedSingleMeter: SingleMeterOption = .small
    @State private var selectedCompoundSmallMeterSize: MeterSize = .one
    @State private var selectedCompoundLargeMeterSize: MeterSize = .one

    // Custom colors
    private let primaryColor = Color.blue
    private let accentColor = Color.purple
    private let successColor = Color.green

    private var sectionHeaderColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    // Computed property for pass range text.
    var passRangeText: String {
        switch viewModel.currentTest {
        case .lowFlow:
            return "95% - 101%"
        case .midFlow:
            return "97% - 101.5%"
        case .highFlow:
            return "98.5% - 101.5%"
        }
    }
    
    // Helper for border color in test type filter.
    private func testTypeBorderColor(for test: TestType) -> Color {
        switch test {
        case .lowFlow: return .blue
        case .midFlow: return .orange
        case .highFlow: return .pink
        }
    }
    
    private var hasRequiredFields: Bool {
        let hasValidReadings = isCompoundMeter ?
            (!viewModel.smallMeterStart.isEmpty && !viewModel.smallMeterEnd.isEmpty &&
             !viewModel.largeMeterStart.isEmpty && !viewModel.largeMeterEnd.isEmpty) :
            (selectedSingleMeter == .small ?
                (!viewModel.smallMeterStart.isEmpty && !viewModel.smallMeterEnd.isEmpty) :
                (!viewModel.largeMeterStart.isEmpty && !viewModel.largeMeterEnd.isEmpty))
        
        let hasValidVolume = !totalVolumeText.isEmpty && Double(sanitizeNumericInput(totalVolumeText)) != nil
        let hasValidFlowRate = !flowRateText.isEmpty && Double(sanitizeNumericInput(flowRateText)) != nil
        
        return hasValidReadings && hasValidVolume && hasValidFlowRate
    }
    
    // MARK: - Updated Sections Using DetailCard
    
    private var testTypeSection: some View {
        DetailCard(title: "Test Type") {
            HStack(spacing: 8) {
                TestTypeButton(
                    title: "Low Flow",
                    subtitle: "(0.75-35 GPM)",
                    isSelected: viewModel.currentTest == .lowFlow,
                    borderColor: testTypeBorderColor(for: .lowFlow),
                    action: { viewModel.currentTest = .lowFlow }
                )
                TestTypeButton(
                    title: "Mid Flow",
                    subtitle: "(15-100 GPM)",
                    isSelected: viewModel.currentTest == .midFlow,
                    borderColor: testTypeBorderColor(for: .midFlow),
                    action: { viewModel.currentTest = .midFlow }
                )
                TestTypeButton(
                    title: "High Flow",
                    subtitle: "(25-650 GPM)",
                    isSelected: viewModel.currentTest == .highFlow,
                    borderColor: testTypeBorderColor(for: .highFlow),
                    action: { viewModel.currentTest = .highFlow }
                )
            }
        }
    }
    
    private var meterReadingsSection: some View {
        DetailCard(title: "Meter Readings") {
            Toggle("Compound Meter", isOn: $isCompoundMeter)
                .padding(.vertical, 4)
            if isCompoundMeter {
                smallMeterReadings
                Divider()
                largeMeterReadings
            } else {
                Picker("Meter Reading", selection: $selectedSingleMeter) {
                    Text("Small Meter").tag(SingleMeterOption.small)
                    Text("Large Meter").tag(SingleMeterOption.large)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.vertical, 4)
                if selectedSingleMeter == .small {
                    smallMeterReadings
                } else {
                    largeMeterReadings
                }
            }
        }
    }
    
    private var smallMeterReadings: some View {
        VStack(alignment: .leading) {
            Label("Small Meter Reading", systemImage: "speedometer")
                .font(.subheadline)
                .bold()
                .foregroundColor(primaryColor)
            HStack {
                MarsReadingField(title: "Start Read", text: $viewModel.smallMeterStart, field: .smallStart)
                Spacer()
                MarsReadingField(title: "End Read", text: $viewModel.smallMeterEnd, field: .smallEnd)
            }
        }
    }
    
    private var largeMeterReadings: some View {
        VStack(alignment: .leading) {
            Label("Large Meter Reading", systemImage: "dial.max")
                .font(.subheadline)
                .bold()
                .foregroundColor(primaryColor)
            HStack {
                MarsReadingField(title: "Start Read", text: $viewModel.largeMeterStart, field: .largeStart)
                Spacer()
                MarsReadingField(title: "End Read", text: $viewModel.largeMeterEnd, field: .largeEnd)
            }
        }
    }
    
    private var testParametersSection: some View {
        DetailCard(title: "Test Parameters") {
            VStack(spacing: 12) {
                HStack(spacing: 0) {
                    Label("Total Volume", systemImage: "drop")
                        .foregroundColor(primaryColor)
                        .lineLimit(1)
                        .frame(width: 150, alignment: .leading)
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        TextField("", text: $totalVolumeText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.black)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(showValidationOutlines && totalVolumeText.isEmpty ? Color.red : Color.clear, lineWidth: 2)
                            )
                            .focused($focusedField, equals: .totalVolume)
                            .onChange(of: totalVolumeText) { newValue in
                                if let value = Double(sanitizeNumericInput(newValue)) {
                                    viewModel.totalVolume = value
                                }
                            }
                        Text(viewModel.configuration.preferredVolumeUnit.rawValue)
                            .foregroundColor(.secondary)
                            .frame(width: 60, alignment: .leading)
                    }
                }
                
                HStack(spacing: 0) {
                    Label("Flow Rate", systemImage: "water.waves")
                        .foregroundColor(primaryColor)
                        .lineLimit(1)
                        .frame(width: 150, alignment: .leading)
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        TextField("", text: $flowRateText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.black)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(showValidationOutlines && flowRateText.isEmpty ? Color.red : Color.clear, lineWidth: 2)
                            )
                            .focused($focusedField, equals: .flowRate)
                            .onChange(of: flowRateText) { newValue in
                                if let value = Double(sanitizeNumericInput(newValue)) {
                                    viewModel.flowRate = value
                                }
                            }
                        Text("GPM")
                            .foregroundColor(.secondary)
                            .frame(width: 60, alignment: .leading)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - Meter Details Section with Full-Width Fix
    private var meterDetailsSection: some View {
        DetailCard(title: "Meter Details") {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Meter Size", systemImage: "ruler")
                        .foregroundColor(primaryColor)

                    if isCompoundMeter {
                        VStack {
                            Picker("Small Meter", selection: $selectedCompoundSmallMeterSize) {
                                ForEach(MeterSize.allCases, id: \.self) { size in
                                    Text(size.rawValue).tag(size)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())

                            Picker("Large Meter", selection: $selectedCompoundLargeMeterSize) {
                                ForEach(MeterSize.allCases, id: \.self) { size in
                                    Text(size.rawValue).tag(size)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                    } else {
                        Picker("", selection: $selectedMeterSize) {
                            ForEach(MeterSize.allCases, id: \.self) { size in
                                Text(size.rawValue).tag(size)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                
                if showMeterMfgInput {
                    HStack {
                        Label("Meter Mfg.", systemImage: "dial.medium")
                            .foregroundColor(primaryColor)
                        Picker("", selection: $selectedMeterType) {
                            ForEach(MeterType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                    }
                }
                
                if showMeterModelInput {
                    HStack {
                        Label("Meter Type", systemImage: "gear")
                            .foregroundColor(primaryColor)
                        Picker("", selection: $selectedMeterModel) {
                            ForEach(MeterModel.allCases, id: \.self) { model in
                                Text(model.rawValue).tag(model)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .layoutPriority(1)
        }
    }
    
    private var additionalDetailsSection: some View {
        DetailCard(title: "Additional Details") {
            HStack {
                Label("Job Number", systemImage: "number")
                    .foregroundColor(primaryColor)
                TextField("Optional", text: $jobNumberText)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .jobNumber)
            }
        }
    }
    
    private var notesSection: some View {
        DetailCard(title: "Notes") {
            TextEditor(text: $viewModel.notes)
                .frame(minHeight: 100)
                .placeholder(when: viewModel.notes.isEmpty, placeholder: "Enter additional notes here...")
        }
    }
    
    private var recordTestSection: some View {
        DetailCard(title: "Record Test") {
            Button(action: recordTest) {
                Label(isRecordSuccess ? "Test Recorded!" : "Record Test",
                      systemImage: isRecordSuccess ? "checkmark" : "square.and.arrow.down")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: isRecordSuccess ? [successColor, successColor.opacity(0.8)] : [primaryColor, accentColor]),
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
    
    private func latestResultSection(result: TestResult) -> some View {
        DetailCard(title: "Latest Result") {
            NavigationLink(destination: TestDetailView(result: result)) {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Test Type: \(result.testType.rawValue)", systemImage: "checkmark.circle")
                        .font(.headline)
                        .foregroundColor(primaryColor)
                    Label("Accuracy: \(String(format: "%.1f%%", result.reading.accuracy))", systemImage: "percent")
                        .foregroundColor(result.isPassing ? .green : .red)
                    Label("Status: \(result.isPassing ? "PASS" : "FAIL")", systemImage: result.isPassing ? "checkmark.seal" : "xmark.seal")
                        .foregroundColor(result.isPassing ? .green : .red)
                    Label("Pass Range: \(passRangeText)", systemImage: "ruler.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Tap for more details")
                        .font(.caption2)
                        .foregroundColor(.blue)
                        .padding(.top, 4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // MARK: - Helper Functions
    private func sanitizeNumericInput(_ input: String) -> String {
        return input
            .replacingOccurrences(of: "'", with: ".")
            .replacingOccurrences(of: "`", with: "")
            .replacingOccurrences(of: "٫", with: ".")
            .replacingOccurrences(of: "،", with: ".")
    }
    
    private func validateFields() -> Bool {
        validationErrors.removeAll()
        
        // Validate meter readings
        if isCompoundMeter {
            if viewModel.smallMeterStart.isEmpty || viewModel.smallMeterEnd.isEmpty {
                validationErrors.append("Small meter readings are required")
            }
            if viewModel.largeMeterStart.isEmpty || viewModel.largeMeterEnd.isEmpty {
                validationErrors.append("Large meter readings are required")
            }
        } else {
            if selectedSingleMeter == .small {
                if viewModel.smallMeterStart.isEmpty || viewModel.smallMeterEnd.isEmpty {
                    validationErrors.append("Small meter readings are required")
                }
            } else {
                if viewModel.largeMeterStart.isEmpty || viewModel.largeMeterEnd.isEmpty {
                    validationErrors.append("Large meter readings are required")
                }
            }
        }
        
        // Validate volume and flow rate
        if totalVolumeText.isEmpty || Double(sanitizeNumericInput(totalVolumeText)) == nil {
            validationErrors.append("Valid total volume is required")
        }
        
        if flowRateText.isEmpty || Double(sanitizeNumericInput(flowRateText)) == nil {
            validationErrors.append("Valid flow rate is required")
        }
        
        if !validationErrors.isEmpty {
            showingValidationAlert = true
            return false
        }
        
        return true
    }
    
    @State private var showValidationOutlines = false
    @State private var rawInputs: [String: String] = [:]
    
    private func clearAllFields() {
        totalVolumeText = ""
        flowRateText = ""
        jobNumberText = ""
        additionalRemarksText = ""
        viewModel.smallMeterStart = ""
        viewModel.smallMeterEnd = ""
        viewModel.largeMeterStart = ""
        viewModel.largeMeterEnd = ""
        viewModel.totalVolume = 0
        viewModel.flowRate = 0
        viewModel.notes = ""
        selectedMeterSize = .one
        selectedMeterType = .neptune
        selectedMeterModel = .positiveDisplacement
        dismissKeyboard()
        showValidationOutlines = false
    }
    
    private func recordTest() {
        dismissKeyboard()
        showValidationOutlines = true
        
        if !validateFields() {
            return
        }
        
        // Print all raw inputs for verification
        print("Recording test with raw inputs:")
        rawInputs.forEach { key, value in
            print("\(key): \(value)")
        }
        
        viewModel.isCalculatingResults = true
        withAnimation(.spring(response: 0.3)) {
            isRecordSuccess = true
        }
        let meterSizeValue = isCompoundMeter
            ? "\(selectedCompoundSmallMeterSize.rawValue)/\(selectedCompoundLargeMeterSize.rawValue)"
            : selectedMeterSize.rawValue
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            viewModel.calculateResults(
                with: nil,
                meterSize: meterSizeValue,
                meterType: selectedMeterType.rawValue,
                meterModel: selectedMeterModel.rawValue,
                jobNumber: jobNumberText,
                readingType: isCompoundMeter ? .compound : (selectedSingleMeter == .small ? .small : .large)
            )
            showToast = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                clearAllFields()
                viewModel.isCalculatingResults = false
                withAnimation {
                    isRecordSuccess = false
                }
            }
        }
    }
    
    private func dismissKeyboard() {
        #if os(iOS)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        #endif
    }
    
    private func MarsReadingField(title: String, text: Binding<String>, field: Field) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            TextField("", text: text)
                .keyboardType(.decimalPad)
                .textFieldStyle(PlainTextFieldStyle())
                .focused($focusedField, equals: field)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.black)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(showValidationOutlines && text.wrappedValue.isEmpty ? Color.red : Color.clear, lineWidth: 2)
                )
                .onChange(of: text.wrappedValue) { newValue in
                    let sanitized = sanitizeNumericInput(newValue)
                    text.wrappedValue = sanitized
                    Field.logAccess(field, value: sanitized)
                }
        }
    }
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                testTypeSection
                meterReadingsSection
                testParametersSection
                meterDetailsSection
                additionalDetailsSection
                notesSection
                recordTestSection
                if viewModel.showingResults, let result = viewModel.testResults.last {
                    latestResultSection(result: result)
                }
            }
            .padding()
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
                            .fill(colorScheme == .light ? Color.black : Color.blue)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    )
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingClearConfirmation = true }) {
                    Label("Clear All", systemImage: "trash")
                        .foregroundColor(primaryColor)
                }
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(action: { dismissKeyboard() }) {
                    Image(systemName: "keyboard.chevron.compact.down")
                        .foregroundColor(primaryColor)
                }
            }
        }
        .toast(isPresented: $showToast, message: "Test recorded successfully")
        .alert("Clear All Fields", isPresented: $showingClearConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) { clearAllFields() }
        } message: {
            Text("Are you sure you want to clear all fields? This action cannot be undone.")
        }
        .alert("Validation Errors", isPresented: $showingValidationAlert) {
            ForEach(validationErrors, id: \.self) { error in
                Button("OK", role: .cancel) { }
            }
        } message: {
            Text(validationErrors.joined(separator: "\n"))
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TestView()
                .environmentObject(TestViewModel())
        }
    }
}
