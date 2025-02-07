import SwiftUI

// MARK: - FAQ Section
struct FAQItem: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
    let icon: String
}

struct FAQSectionView: View {
    private let faqItems: [FAQItem] = [
        FAQItem(question: "How do I record a test?", answer: "Go to the Test tab, input your meter readings, and tap 'Record Test' to store your data.", icon: "square.and.pencil"),
        FAQItem(question: "How can I view my test history?", answer: "Your test history is available under the History tab, where you can search, view details, and export results.", icon: "clock.arrow.circlepath"),
        FAQItem(question: "Does the app work offline?", answer: "Yes, all test data is stored locally so you can work offline and sync or export when connectivity is restored.", icon: "wifi.slash"),
        FAQItem(question: "How do I adjust the settings?", answer: "Use the Settings tab to customize appearance, volume units, and other preferences.", icon: "gearshape.fill"),
        FAQItem(question: "Where can I get help?", answer: "Visit the Help tab for FAQs, troubleshooting guides, and contact support information.", icon: "questionmark.circle.fill")
    ]
    
    @State private var expandedIDs: Set<UUID> = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "questionmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.blue)
                Text("Frequently Asked Questions")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .padding(.horizontal)
            
            ForEach(faqItems) { item in
                DisclosureGroup(
                    isExpanded: Binding(
                        get: { expandedIDs.contains(item.id) },
                        set: { isExpanded in
                            withAnimation(.spring()) {
                                if isExpanded {
                                    expandedIDs.insert(item.id)
                                } else {
                                    expandedIDs.remove(item.id)
                                }
                            }
                        }
                    )
                ) {
                    Text(item.answer)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding(.top, 8)
                        .multilineTextAlignment(.leading)
                } label: {
                    HStack {
                        Image(systemName: item.icon)
                            .foregroundColor(.blue)
                            .font(.system(size: 20))
                        Text(item.question)
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
}

// MARK: - Checkbox Toggle Style
struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: ToggleStyleConfiguration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(configuration.isOn ? .blue : .gray)
                    .font(.system(size: 22))
                configuration.label
            }
        }
    }
}

// MARK: - Operator Checklist Section
struct ChecklistItem: Identifiable {
    let id = UUID()
    let title: String
    var isCompleted: Bool = false
}

struct ChecklistSection: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    var items: [ChecklistItem]
}

struct OperatorChecklistView: View {
    @State private var sections: [ChecklistSection] = [
        ChecklistSection(title: "1. Preparation", icon: "wrench.and.screwdriver.fill", items: [
            ChecklistItem(title: "Identify meter size & type"),
            ChecklistItem(title: "Verify test port size and install necessary adapters"),
            ChecklistItem(title: "Ensure bypass is closed to isolate test")
        ]),
        ChecklistSection(title: "2. Debris Purge", icon: "drop.fill", items: [
            ChecklistItem(title: "Connect test port to diffuser"),
            ChecklistItem(title: "Open meter pit valve fully"),
            ChecklistItem(title: "Run water until clear (~30 sec - 1 min)"),
            ChecklistItem(title: "Close meter pit valve")
        ]),
        ChecklistSection(title: "3. Air Purge", icon: "bubble.right.fill", items: [
            ChecklistItem(title: "Connect test port to VF4 inlet"),
            ChecklistItem(title: "Open 3\" float & spill valve fully"),
            ChecklistItem(title: "Crack open ¾\" float & spill valve (~¼ turn)"),
            ChecklistItem(title: "Slowly open meter pit valve fully"),
            ChecklistItem(title: "Observe steady water stream at exit (No sputtering)"),
            ChecklistItem(title: "Close ¾\" valve first, then close 3\" valve"),
            ChecklistItem(title: "Ensure pressure gauge ≥20 PSI")
        ]),
        ChecklistSection(title: "4. Low-Flow Test", icon: "arrow.down.right.circle.fill", items: [
            ChecklistItem(title: "Reset VF4 totalizer to zero"),
            ChecklistItem(title: "Write down meter start read"),
            ChecklistItem(title: "Set flow control valve to target GPM"),
            ChecklistItem(title: "Run test to desired volume (e.g., 100 gallons)"),
            ChecklistItem(title: "Slowly close flow control valve at end"),
            ChecklistItem(title: "Write down meter end read"),
            ChecklistItem(title: "Calculate accuracy ((End Read - Start Read) ÷ Totalizer Volume)")
        ]),
        ChecklistSection(title: "5. Mid-Flow Test", icon: "arrow.right.circle.fill", items: [
            ChecklistItem(title: "Determine mid-flow GPM from chart"),
            ChecklistItem(title: "Run test using the 3\" side (recommended)"),
            ChecklistItem(title: "Follow same steps as low-flow test")
        ]),
        ChecklistSection(title: "6. High-Flow Test", icon: "arrow.up.right.circle.fill", items: [
            ChecklistItem(title: "Reset VF4 totalizer & meter start read"),
            ChecklistItem(title: "Open 3\" flow control valve to max achievable GPM"),
            ChecklistItem(title: "Run for 3 min (if full volume can't be achieved)"),
            ChecklistItem(title: "Slowly close flow control valve at end"),
            ChecklistItem(title: "Write down meter end read"),
            ChecklistItem(title: "Calculate accuracy")
        ]),
        ChecklistSection(title: "7. Test Completion", icon: "checkmark.circle.fill", items: [
            ChecklistItem(title: "Close meter pit valve fully"),
            ChecklistItem(title: "Depressurize VF4 by opening 3\" & ¾\" valves"),
            ChecklistItem(title: "Verify pressure gauge at 0 PSI"),
            ChecklistItem(title: "Disconnect hoses & store equipment")
        ]),
        ChecklistSection(title: "8. Special Notes", icon: "exclamationmark.triangle.fill", items: [
            ChecklistItem(title: "Raise exit hose above VF4 for optimal pressure")
        ])
    ]
    
    @State private var expandedSectionIDs: Set<UUID> = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "checklist")
                    .font(.title)
                    .foregroundColor(.blue)
                Text("VF4 In-Field Testing Checklist")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .padding(.horizontal)
            
            ForEach($sections) { $section in
                DisclosureGroup(
                    isExpanded: Binding(
                        get: { expandedSectionIDs.contains(section.id) },
                        set: { newValue in
                            withAnimation(.spring()) {
                                if newValue {
                                    expandedSectionIDs.insert(section.id)
                                } else {
                                    expandedSectionIDs.remove(section.id)
                                }
                            }
                        }
                    )
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach($section.items) { $item in
                            Toggle(isOn: $item.isCompleted) {
                                Text(item.title)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.leading)
                            }
                            .toggleStyle(CheckboxToggleStyle())
                        }
                    }
                    .padding(.top, 12)
                } label: {
                    HStack {
                        Image(systemName: section.icon)
                            .foregroundColor(.blue)
                            .font(.system(size: 24))
                        Text(section.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                .shadow(radius: 3)
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
}

// MARK: - Contact Support View
struct ContactSupportView: View {
    @Environment(\.openURL) var openURL
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "headphones.circle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.blue)
                Text("Contact Support")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            Divider()
                .padding(.vertical, 4)
            
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "building.2.fill")
                        .foregroundColor(.blue)
                    Text("MARS Company")
                        .font(.headline)
                }
                
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.blue)
                    VStack {
                        Text("3925 SW 13th Street")
                        Text("Ocala, FL 34474")
                    }
                    .font(.subheadline)
                }
                
                Link(destination: URL(string: "https://marswater.com")!) {
                    HStack {
                        Image(systemName: "globe")
                        Text("Visit our website")
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
                }
                .padding(.top, 4)
            }
            
            HStack(spacing: 20) {
                Button(action: {
                    if let phoneURL = URL(string: "tel://8777MYMARS") {
                        openURL(phoneURL)
                    }
                }) {
                    Label("Call Support", systemImage: "phone.circle.fill")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.15))
                        .cornerRadius(12)
                }
                
                Button(action: {
                    if let emailURL = URL(string: "mailto:support@marswater.com") {
                        openURL(emailURL)
                    }
                }) {
                    Label("Email Support", systemImage: "envelope.circle.fill")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.15))
                        .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color(UIColor.tertiarySystemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
}

// MARK: - Main Help View
struct HelpView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    FAQSectionView()
                    ContactSupportView()
                    OperatorChecklistView()
                }
                .padding()
            }
            .navigationTitle("Help & Support")
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
            .preferredColorScheme(.light)
        
        HelpView()
            .preferredColorScheme(.dark)
    }
}
