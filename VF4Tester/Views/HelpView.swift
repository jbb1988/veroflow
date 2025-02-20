import SwiftUI
import WebKit
import SafariServices

// MARK: - Data Models
struct TestingStep: Identifiable {
    let id: String
    let title: String
    let icon: String
    let steps: [String]
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
            "Determine low-flow GPM from chart",
            "Reset VF4 totalizer to zero",
            "Collect meter start read",
            "Set low flow control valve to target GPM",
            "Run test to desired volume (e.g., 100 gallons)",
            "Slowly close flow control valve once desired volume is reached",
            "Collect meter end read",
            "Click Record Test"
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

// MARK: - SafariView for Opening External Links
struct SafariView: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) { }
}

// MARK: - Animated Gradient Button
struct AnimatedSafariButton: View {
    @State private var isAnimating = false
    let gradient = Gradient(colors: [.red, .blue])
    let action: () -> Void
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: gradient,
                startPoint: isAnimating ? .topTrailing : .bottomLeading,
                endPoint: isAnimating ? .bottomTrailing : .center
            )
            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isAnimating)
            .frame(width: 280, height: 86)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .blur(radius: 8)
            
            Button(action: action) {
                Text("MARS AI Chat")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 280, height: 80)
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        }
        .onAppear { isAnimating = true }
    }
}

// MARK: - HelpSection Enum
enum HelpSection: String, CaseIterable {
    case support = "Support"
    case testing = "Guide"
    case faq = "FAQ"
    case demo = "Demo"
    case testChart = "Chart"
    
    var icon: String {
        switch self {
        case .support: return "headphones.circle.fill"
        case .testing: return "book.fill"
        case .faq: return "questionmark.circle.fill"
        case .demo: return "play.circle.fill"
        case .testChart: return "chart.bar.fill"
        }
    }
}

// MARK: - Custom Top Bar
struct CustomTopBar: View {
    var body: some View {
        HStack {
            Spacer()
            Image("MARS Company")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 44)  // Adjust as needed
            Spacer()
        }
        .padding(.vertical, 8)
        .background(Color(UIColor.systemBackground))
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
    }
}

// MARK: - Main Help View (Custom Top Bar, No Navigation Bar)
struct HelpView: View {
    @State private var selectedSection: HelpSection = .support
    @State private var searchQuery = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Top Bar with MARS logo
            CustomTopBar()
            
            // Filter Bar
            HStack {
                Spacer()
                HStack(spacing: 0) {
                    ForEach(HelpSection.allCases, id: \.self) { section in
                        Button(action: { selectedSection = section }) {
                            VStack(spacing: 4) {
                                Image(systemName: section.icon)
                                    .font(.system(size: 18))
                                Text(section.rawValue)
                                    .font(.subheadline)
                                    .minimumScaleFactor(0.8)
                            }
                            .frame(width: UIScreen.main.bounds.width / CGFloat(HelpSection.allCases.count) - 12)
                            .frame(height: 52)
                            .background(selectedSection == section ? Color.blue : Color(UIColor.secondarySystemBackground))
                            .foregroundColor(selectedSection == section ? .white : .primary)
                            .cornerRadius(10)
                            .shadow(color: selectedSection == section ? Color.blue.opacity(0.3) : Color.clear,
                                    radius: 4, x: 0, y: 2)
                        }
                    }
                }
                Spacer()
            }
            .padding(.vertical, 4)
            .background(Color(UIColor.systemBackground))
            
            // Optional Search Bar (FAQ only)
            if selectedSection == .faq {
                SearchBar(text: $searchQuery)
                    .padding(.horizontal)
            }
            
            // Main Content
            ScrollView {
                VStack(spacing: 20) {
                    switch selectedSection {
                    case .support:
                        EnhancedSupportView()
                    case .testing:
                        InteractiveTestingGuide()
                    case .faq:
                        EnhancedFAQView(searchQuery: searchQuery)
                    case .demo:
                        DemoView()
                    case .testChart:
                        TestChartView()
                    }
                }
                .padding()
            }
        }
        // Hide any parent Navigation Bar if needed
        .navigationBarHidden(true)
    }
}

// MARK: - Search Bar
struct SearchBar: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused($isFocused)
                .submitLabel(.search)
                .onSubmit { isFocused = false }
            
            if !text.isEmpty {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        text = ""
                        isFocused = false
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 8)
        .animation(.spring(response: 0.3), value: text)
    }
}

// MARK: - Enhanced Support View (Consistent Card Styling)
struct EnhancedSupportView: View {
    @Environment(\.openURL) var openURL
    @State private var showSafari = false
    
    var body: some View {
        VStack(spacing: 24) {
            // AI Assistant Overview Card
            VStack(alignment: .leading, spacing: 12) {
                Text("MARS Company AI Assistant")
                    .font(.headline)
                Text("Ask questions about using the app, like how often should water meters be tested? What are the economic implications of not maintaining water meters properly? Learn about the associated VEROflow-4 hardware steps to test, or just share feedback. If you need further asistance just give MARS a call or email - The MARS Company AI is here to help!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            .frame(maxWidth: .infinity)
            
            // Animated Gradient Button
            AnimatedSafariButton {
                showSafari = true
            }
            .sheet(isPresented: $showSafari) {
                SafariView(url: URL(string: "https://elevenlabs.io/app/talk-to?agent_id=Md5eKB1FeOQI9ykuKDxB")!)
            }
            
            // Contact Support Card wrapped in same styling
            VStack {
                ContactSupportView()
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            .frame(maxWidth: .infinity)
        }
        .padding()
    }
}

// MARK: - Contact Support View (Inner Content Only)
struct ContactSupportView: View {
    @Environment(\.openURL) var openURL
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
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
                VStack(spacing: 16) {
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
                VStack(spacing: 12) {
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
        }
    }
}

// MARK: - Interactive Testing Guide & Other Views
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

struct EnhancedFAQView: View {
    let searchQuery: String
    @State private var expandedQuestions: Set<UUID> = []
    @State private var helpfulResponses: Set<UUID> = []
    var filteredFAQs: [FAQItem] {
        if searchQuery.isEmpty { return faqItems }
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

struct DemoView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Setup Video")
                .font(.title2)
                .bold()
                .padding(.bottom, 8)
            WebView(url: URL(string: "https://marswater.notion.site/vf4?pvs=4")!)
                .frame(height: 300)
                .cornerRadius(12)
        }
        .padding()
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    func makeUIView(context: Context) -> WKWebView { WKWebView() }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(URLRequest(url: url))
    }
}

// MARK: - Test Chart View
struct TestChartView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Meter Accuracy Tolerances")
                    .font(.title2)
                    .bold()
                VStack(alignment: .leading, spacing: 16) {
                    Text("Large Meters (3″ and Larger)")
                        .font(.headline)
                    ToleranceTable(rows: [
                        ("Positive Displacement & Single-Jet", "95% – 101.5%", "98.5% – 101.5%"),
                        ("Multi-Jet", "97% – 103%", "98.5% – 101.5%"),
                        ("Turbine (Class II)", "98.5% – 101.5%", "98.5% – 101.5%"),
                        ("Electromagnetic/Ultrasonic", "95% – 105%", "98.5% – 101.5%"),
                        ("Fire Service", "95% – 101.5%", "98.5% – 101.5%"),
                        ("Compound", "95% – 101%", "98.5% – 101.5% (Mid),\n97% – 103% (High)")
                    ])
                }
                .padding(16)
                .background(Color(UIColor.tertiarySystemBackground))
                .cornerRadius(16)
                VStack(alignment: .leading, spacing: 16) {
                    Text("Small Meters (5/8″ to 2″)")
                        .font(.headline)
                    ToleranceTable(rows: [
                        ("Positive Displacement & Single-Jet", "95% – 101.5%", "98.5% – 101.5%"),
                        ("Multi-Jet", "97% – 103%", "98.5% – 101.5%"),
                        ("Turbine", "98.5% – 101.5%", "98.5% – 101.5%"),
                        ("Electromagnetic/Ultrasonic", "95% – 105%", "98.5% – 101.5%"),
                        ("Fire Service", "95% – 101.5%", "98.5% – 101.5%"),
                        ("Compound", "95% – 101?", "98.5% – 101.5% (Mid),\n97% – 103% (High)")
                    ])
                }
                .padding(16)
                .background(Color(UIColor.tertiarySystemBackground))
                .cornerRadius(16)
                VStack(alignment: .leading, spacing: 16) {
                    Text("Calculation Overview")
                        .font(.headline)
                    Text("The app automatically selects the appropriate tolerance range based on the meter type and test flow (low, mid, or high). It calculates the meter's accuracy as the ratio of the combined meter reading to the test volume (expressed as a percentage).")
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, 8)
                    Text("A test passes only if the calculated accuracy falls within the designated tolerance range. For example, for a Multi-Jet meter at low flow, the accuracy must be between 97% and 103% for the test to pass.")
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(16)
                .background(Color(UIColor.tertiarySystemBackground))
                .cornerRadius(16)
            }
            .padding()
        }
    }
}

struct ToleranceTable: View {
    let rows: [(String, String, String)]
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 16) {
                Text("Meter Type")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Low Flow")
                    .frame(width: 100, alignment: .leading)
                Text("Mid-Flow /\nHigh Flow")
                    .frame(width: 100, alignment: .leading)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.blue.opacity(0.1))
            .font(.footnote.bold())
            ForEach(rows, id: \.0) { row in
                Divider()
                HStack(spacing: 16) {
                    Text(row.0)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(row.1)
                        .frame(width: 100, alignment: .leading)
                    Text(row.2)
                        .frame(width: 100, alignment: .leading)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .font(.footnote)
            }
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
            .preferredColorScheme(.light)
    }
}

