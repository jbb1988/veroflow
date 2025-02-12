import SwiftUI

// MARK: - Data Models
struct TestingStep: Identifiable {
    let id: String
    let title: String
    let icon: String
    let steps: [String]
}

struct GlossaryTerm: Identifiable {
    let id = UUID()
    let term: String
    let definition: String
}

struct FAQItem: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
    let icon: String
}

// MARK: - Sample Data
let faqItems: [FAQItem] = [
    FAQItem(
        question: "How do I record a test?",
        answer: "Go to the Test tab, input your meter readings, and tap 'Record Test' to store your data.",
        icon: "square.and.pencil"
    ),
    FAQItem(
        question: "How can I view my test history?",
        answer: "Your test history is available under the History tab, where you can search, view details, and export results.",
        icon: "clock.arrow.circlepath"
    ),
    FAQItem(
        question: "Does the app work offline?",
        answer: "Yes, all test data is stored locally so you can work offline and sync or export when connectivity is restored.",
        icon: "wifi.slash"
    ),
    FAQItem(
        question: "How do I adjust the settings?",
        answer: "Use the Settings tab to customize appearance, volume units, and other preferences.",
        icon: "gearshape.fill"
    ),
    FAQItem(
        question: "Where can I get help?",
        answer: "Visit the Help tab for FAQs, troubleshooting guides, and contact support information.",
        icon: "questionmark.circle.fill"
    )
]

let testingSteps = [
    TestingStep(
        id: "preparation",
        title: "1. Preparation",
        icon: "wrench.and.screwdriver.fill",
        steps: [
            "Identify meter size & type",
            "Verify test port size and install necessary adapters",
            "Ensure bypass is closed to isolate test",
            "Check all required tools are available",
            "Verify system pressure is adequate"
        ]
    ),
    TestingStep(
        id: "debris",
        title: "2. Debris Purge",
        icon: "drop.fill",
        steps: [
            "Connect test port to diffuser",
            "Open meter pit valve fully",
            "Run water until clear (~30 sec - 1 min)",
            "Close meter pit valve",
            "Verify water is clear of debris"
        ]
    ),
    TestingStep(
        id: "air",
        title: "3. Air Purge",
        icon: "bubble.right.fill",
        steps: [
            "Connect test port to VF4 inlet",
            "Open 3\" float & spill valve fully",
            "Crack open ¾\" float & spill valve (~¼ turn)",
            "Slowly open meter pit valve fully",
            "Observe steady water stream at exit (No sputtering)",
            "Close ¾\" valve first, then close 3\" valve",
            "Ensure pressure gauge ≥20 PSI"
        ]
    ),
    TestingStep(
        id: "lowflow",
        title: "4. Low-Flow Test",
        icon: "arrow.down.right.circle.fill",
        steps: [
            "Reset VF4 totalizer to zero",
            "Write down meter start read",
            "Set flow control valve to target GPM",
            "Run test to desired volume (e.g., 100 gallons)",
            "Slowly close flow control valve at end",
            "Write down meter end read",
            "Calculate accuracy"
        ]
    ),
    TestingStep(
        id: "midflow",
        title: "5. Mid-Flow Test",
        icon: "arrow.right.circle.fill",
        steps: [
            "Determine mid-flow GPM from chart",
            "Run test using the 3\" side (recommended)",
            "Follow same steps as low-flow test",
            "Record all readings accurately"
        ]
    ),
    TestingStep(
        id: "highflow",
        title: "6. High-Flow Test",
        icon: "arrow.up.right.circle.fill",
        steps: [
            "Reset VF4 totalizer & meter start read",
            "Open 3\" flow control valve to max achievable GPM",
            "Run for 3 min (if full volume can't be achieved)",
            "Slowly close flow control valve at end",
            "Write down meter end read",
            "Calculate accuracy"
        ]
    ),
    TestingStep(
        id: "completion",
        title: "7. Test Completion",
        icon: "checkmark.circle.fill",
        steps: [
            "Close meter pit valve fully",
            "Depressurize VF4 by opening 3\" & ¾\" valves",
            "Verify pressure gauge at 0 PSI",
            "Disconnect hoses & store equipment",
            "Document all test results",
            "Clean up workspace"
        ]
    )
]

let glossaryTerms = [
    GlossaryTerm(
        term: "Flow Rate",
        definition: "The volume of water passing through the meter per unit of time, typically measured in gallons per minute (GPM)."
    ),
    GlossaryTerm(
        term: "Test Port",
        definition: "The connection point on a water meter where testing equipment can be attached."
    ),
    GlossaryTerm(
        term: "Accuracy",
        definition: "The degree to which a meter's reading matches the actual volume of water that passed through it."
    ),
    GlossaryTerm(
        term: "Bypass",
        definition: "A secondary pipe that allows water to flow around the meter during maintenance or testing."
    )
]

// MARK: - Main Help View
struct HelpView: View {
    @State private var selectedSection: HelpSection = .testing
    @State private var searchQuery = ""

    enum HelpSection: String, CaseIterable {
        case testing = "Guide"
        case faq = "FAQ"
        case glossary = "Glossary"
        case support = "Support"
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Section Picker
                Picker("Section", selection: $selectedSection) {
                    ForEach(HelpSection.allCases, id: \.self) { section in
                        Text(section.rawValue).tag(section)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                // Search Bar (for FAQ and Glossary sections)
                if selectedSection == .faq || selectedSection == .glossary {
                    SearchBar(text: $searchQuery)
                        .padding(.horizontal)
                }

                // Content
                ScrollView {
                    VStack(spacing: 20) {
                        switch selectedSection {
                        case .testing:
                            InteractiveTestingGuide()
                        case .faq:
                            EnhancedFAQView(searchQuery: searchQuery)
                        case .glossary:
                            GlossaryView(searchQuery: searchQuery)
                        case .support:
                            EnhancedSupportView()
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Help & Support")
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
}

// MARK: - Search Bar
struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("Search", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

// MARK: - Interactive Testing Guide
struct InteractiveTestingGuide: View {
    @State private var expandedSections: Set<String> = []
    @State private var completedSteps: Set<String> = []

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Interactive Testing Guide")
                .font(.title2)
                .bold()
                .padding(.bottom, 8)

            ForEach(testingSteps) { section in
                TestingSection(
                    section: section,
                    isExpanded: expandedSections.contains(section.id),
                    completedSteps: $completedSteps,
                    onToggle: {
                        withAnimation {
                            if expandedSections.contains(section.id) {
                                expandedSections.remove(section.id)
                            } else {
                                expandedSections.insert(section.id)
                            }
                        }
                    }
                )
            }
        }
    }
}

struct TestingSection: View {
    let section: TestingStep
    let isExpanded: Bool
    @Binding var completedSteps: Set<String>
    let onToggle: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Button(action: onToggle) {
                HStack {
                    Image(systemName: section.icon)
                        .foregroundColor(.blue)
                        .frame(width: 24)

                    Text(section.title)
                        .font(.headline)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .foregroundColor(.secondary)
                }
            }

            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(section.steps, id: \.self) { step in
                        StepRow(
                            step: step,
                            isCompleted: completedSteps.contains(step),
                            onToggle: {
                                if completedSteps.contains(step) {
                                    completedSteps.remove(step)
                                } else {
                                    completedSteps.insert(step)
                                }
                            }
                        )
                    }
                }
                .padding(.leading, 32)
                .padding(.top, 8)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct StepRow: View {
    let step: String
    let isCompleted: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(alignment: .top) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isCompleted ? .green : .secondary)

                Text(step)
                    .strikethrough(isCompleted)
                    .foregroundColor(isCompleted ? .secondary : .primary)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)

                Spacer()
            }
        }
    }
}

// MARK: - Enhanced FAQ View
struct EnhancedFAQView: View {
    let searchQuery: String
    @State private var expandedQuestions: Set<UUID> = []
    @State private var helpfulResponses: Set<UUID> = []

    var filteredFAQs: [FAQItem] {
        if searchQuery.isEmpty {
            return faqItems
        }
        return faqItems.filter { item in
            item.question.localizedCaseInsensitiveContains(searchQuery) ||
            item.answer.localizedCaseInsensitiveContains(searchQuery)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if filteredFAQs.isEmpty {
                Text("No matching questions found")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(filteredFAQs) { item in
                    FAQItemView(
                        item: item,
                        isExpanded: expandedQuestions.contains(item.id),
                        isHelpful: helpfulResponses.contains(item.id),
                        onToggle: {
                            withAnimation {
                                if expandedQuestions.contains(item.id) {
                                    expandedQuestions.remove(item.id)
                                } else {
                                    expandedQuestions.insert(item.id)
                                }
                            }
                        },
                        onHelpfulTap: {
                            if helpfulResponses.contains(item.id) {
                                helpfulResponses.remove(item.id)
                            } else {
                                helpfulResponses.insert(item.id)
                            }
                        }
                    )
                }
            }
        }
    }
}

struct FAQItemView: View {
    let item: FAQItem
    let isExpanded: Bool
    let isHelpful: Bool
    let onToggle: () -> Void
    let onHelpfulTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: onToggle) {
                HStack {
                    Image(systemName: item.icon)
                        .foregroundColor(.blue)
                        .frame(width: 24)

                    Text(item.question)
                        .font(.headline)
                        .multilineTextAlignment(.leading)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .foregroundColor(.secondary)
                }
            }

            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.answer)
                        .padding(.leading, 32)

                    HStack {
                        Spacer()
                        Button(action: onHelpfulTap) {
                            HStack {
                                Image(systemName: isHelpful ? "hand.thumbsup.fill" : "hand.thumbsup")
                                Text(isHelpful ? "Helpful" : "Was this helpful?")
                            }
                            .foregroundColor(isHelpful ? .green : .secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Glossary View
struct GlossaryView: View {
    let searchQuery: String

    var filteredTerms: [GlossaryTerm] {
        if searchQuery.isEmpty {
            return glossaryTerms
        }
        return glossaryTerms.filter { term in
            term.term.localizedCaseInsensitiveContains(searchQuery) ||
            term.definition.localizedCaseInsensitiveContains(searchQuery)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if filteredTerms.isEmpty {
                Text("No matching terms found")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(filteredTerms) { term in
                    GlossaryTermView(term: term)
                }
            }
        }
    }
}

struct GlossaryTermView: View {
    let term: GlossaryTerm

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(term.term)
                .font(.headline)

            Text(term.definition)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Enhanced Support View
struct EnhancedSupportView: View {
    @Environment(\.openURL) var openURL

    var body: some View {
        VStack(spacing: 24) {
            ContactSupportView()
        }
    }
}

struct ContactSupportView: View {
    @Environment(\.openURL) var openURL
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 24) {
            // Logo Section
            Image("MARS Company")
                .resizable()
                .scaledToFit()
                .frame(height: 60)
                .padding(.vertical)
                .background(
                    Group {
                        if colorScheme == .light {
                            Color.black
                        }
                    }
                )
                .cornerRadius(12)
                .padding(.horizontal, colorScheme == .light ? 20 : 0)
            
            // Contact Information Card
            VStack(spacing: 16) {
                // Header
                HStack {
                    Image(systemName: "headphones.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(.blue)
                    Text("Contact Support")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                }
                
                Divider()
                
                // Company Information
                VStack(spacing: 16) {
                    // Address Section
                    HStack(alignment: .top) {
                        Image(systemName: "building.2.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("MARS Company")
                                .font(.headline)
                            Text("3925 SW 13th Street")
                            Text("Ocala, FL 34474")
                        }
                        .font(.subheadline)
                        Spacer()
                    }
                    
                    // Hours Section
                    HStack(alignment: .top) {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Business Hours")
                                .font(.headline)
                            Text("Monday - Friday")
                            Text("8:00 AM - 5:00 PM EST")
                        }
                        .font(.subheadline)
                        Spacer()
                    }
                }
                .padding(.vertical, 8)
                
                // Contact Buttons
                VStack(spacing: 12) {
                    // Phone Button
                    Button(action: {
                        if let phoneURL = URL(string: "tel://8777MYMARS") {
                            openURL(phoneURL)
                        }
                    }) {
                        HStack {
                            Image(systemName: "phone.circle.fill")
                                .font(.title2)
                            VStack(alignment: .leading) {
                                Text("Call Support")
                                    .font(.headline)
                                Text("1-877-7MY-MARS")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Email Button
                    Button(action: {
                        if let emailURL = URL(string: "mailto:support@marswater.com") {
                            openURL(emailURL)
                        }
                    }) {
                        HStack {
                            Image(systemName: "envelope.circle.fill")
                                .font(.title2)
                            VStack(alignment: .leading) {
                                Text("Email Support")
                                    .font(.headline)
                                Text("support@marswater.com")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Website Button
                    Link(destination: URL(string: "https://marswater.com")!) {
                        HStack {
                            Image(systemName: "globe.americas.fill")
                                .font(.title2)
                            VStack(alignment: .leading) {
                                Text("Visit Website")
                                    .font(.headline)
                                Text("www.marswater.com")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .padding()
    }
}

// MARK: - Preview Provider
struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
            .preferredColorScheme(.light)

        HelpView()
            .preferredColorScheme(.dark)
    }
}
