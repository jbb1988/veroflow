import SwiftUI
import AVKit
#if os(iOS)
import UIKit
#endif
import WebKit

// MARK: - Data Models
struct TestingStep: Identifiable {
    let id: String
    let title: String
    let icon: String
    let steps: [String]
    var isComplete: Bool = false
    var onComplete: (() -> Void)?
}

struct FAQItem: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
    let icon: String
    let category: Category
    
    enum Category: String, CaseIterable {
        case general = "General"
        case testing = "Testing"
        case hardware = "Hardware"
        case troubleshooting = "Troubleshooting"
        
        var icon: String {
            switch self {
            case .general: return "info.circle.fill"
            case .testing: return "wrench.and.screwdriver.fill"
            case .hardware: return "cpu.fill"
            case .troubleshooting: return "exclamationmark.triangle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .general: return .blue
            case .testing: return .green
            case .hardware: return .purple
            case .troubleshooting: return .orange
            }
        }
    }
}

// MARK: - Sample Data
let faqItems: [FAQItem] = [
    FAQItem(
        question: "What is MARS VEROflow Calibration?",
        answer: "MARS VEROflow Calibration ensures precise measurement accuracy for VF-1 and VF-4 field test units with expert calibration and quick turnaround.",
        icon: "wrench.and.screwdriver.fill",
        category: .general
    ),
    FAQItem(
        question: "Why choose MARS for calibration?",
        answer: "We offer expert technicians, industry-leading precision, and a customer-focused process to minimize downtime and keep your operations running smoothly.",
        icon: "star.fill",
        category: .general
    ),
    FAQItem(
        question: "What does the calibration include?",
        answer: "Our service includes flow rate and pressure calibration, a 16-point calibration linearization (VF-4), battery replacement, and repair assessments.",
        icon: "list.bullet.clipboard.fill",
        category: .testing
    ),
    FAQItem(
        question: "How fast is the turnaround time?",
        answer: "Our efficient process ensures a faster return than competitors, reducing downtime and potential revenue loss.",
        icon: "clock.badge.checkmark.fill",
        category: .general
    ),
    FAQItem(
        question: "Are the VF-4 units NIST-traceable?",
        answer: "Yes, our VF-1 and VF-4 units are the only field test units with NIST traceability, ensuring global compliance and measurement reliability.",
        icon: "checkmark.shield.fill",
        category: .testing
    ),
    FAQItem(
        question: "How do repairs work?",
        answer: "Repairs are quoted separately and proceed only with your approval, ensuring transparency and optimal performance.",
        icon: "gear.badge.checkmark",
        category: .general
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
            "Open bypass valve",
            "Purge debris from meter",
            "Close bypass valve"
        ]
    ),
    TestingStep(
        id: "air",
        title: "3. Air Purge",
        icon: "bubble.right.fill",
        steps: [
            "Open air purge valve",
            "Purge air from meter",
            "Close air purge valve"
        ]
    ),
    TestingStep(
        id: "lowflow",
        title: "4. Low-Flow Test",
        icon: "arrow.down.right.circle.fill",
        steps: [
            "Set flow rate to low flow",
            "Record flow rate and pressure",
            "Verify flow rate and pressure are within tolerance"
        ]
    ),
    TestingStep(
        id: "midflow",
        title: "5. Mid-Flow Test",
        icon: "arrow.right.circle.fill",
        steps: [
            "Set flow rate to mid flow",
            "Record flow rate and pressure",
            "Verify flow rate and pressure are within tolerance"
        ]
    ),
    TestingStep(
        id: "highflow",
        title: "6. High-Flow Test",
        icon: "arrow.up.right.circle.fill",
        steps: [
            "Set flow rate to high flow",
            "Record flow rate and pressure",
            "Verify flow rate and pressure are within tolerance"
        ]
    ),
    TestingStep(
        id: "completion",
        title: "7. Test Completion",
        icon: "checkmark.circle.fill",
        steps: [
            "Record test results",
            "Verify test results are within tolerance",
            "Complete test report"
        ]
    )
]

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
        Color.clear
            .frame(height: 1)
    }
}

public struct VeroflowHeader: ToolbarContent {
    public var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Image("veroflowLogo")
                .resizable()
                .renderingMode(.original)
                .aspectRatio(contentMode: .fit)
                .frame(height: 80)
        }
    }
}

// MARK: - Main Help View
struct HelpView: View {
    private let headerSpacing: CGFloat = 30
    @State private var selectedSection: HelpSection = .support
    @State private var searchQuery = ""
    @State private var showShareSheet = false

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "001830"),
                    Color(hex: "000C18")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay(WeavePattern())
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Color.clear.frame(height: 50)

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
                                .background(
                                    ZStack {
                                        if selectedSection == section {
                                            Color.blue.opacity(0.3)
                                        } else {
                                            Color.black.opacity(0.5)
                                        }
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.blue.opacity(selectedSection == section ? 0.4 : 0.2),
                                                Color.blue.opacity(selectedSection == section ? 0.2 : 0.05)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    }
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.blue.opacity(selectedSection == section ? 0.8 : 0.3), lineWidth: 1)
                                        .blur(radius: selectedSection == section ? 0.5 : 0)
                                )
                                .cornerRadius(10)
                                .foregroundColor(selectedSection == section ? .white : .gray)
                            }
                        }
                    }
                    Spacer()
                }
                .padding(.vertical, 4)
                .padding(.bottom, 8)
                .background(Color.clear)

                if selectedSection == .faq {
                    SearchBar(text: $searchQuery)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                }

                scrollViewContent
            }
        }
        .ignoresSafeArea(.keyboard)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .principal) {
                Image("veroflowLogo")
                    .resizable()
                    .renderingMode(.original)
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 40)
            }
        }
    }

    private var scrollViewContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                switch selectedSection {
                case .support:
                    EnhancedSupportView()
                case .testing:
                    VStack {
                        InteractiveTestingGuide()
                        Button(action: {
                            showShareSheet = true
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share Checklist")
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                ZStack {
                                    Color.black.opacity(0.5)
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.blue.opacity(0.4),
                                            Color.blue.opacity(0.1)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                }
                            )
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue.opacity(0.8), lineWidth: 2)
                                    .shadow(color: Color.blue.opacity(0.8), radius: 4, x: 0, y: 0)
                            )
                            .foregroundColor(.white)
                        }
                        .padding()
                        .sheet(isPresented: $showShareSheet) {
                            ChecklistShareSheet(activityItems: [UIImage(named: "checklist") ?? UIImage()])
                        }
                    }
                case .faq:
                    EnhancedFAQView(searchQuery: searchQuery)
                case .demo:
                    VStack(spacing: 16) {
                        Text("Tutorial Videos")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)

                        VStack(spacing: 20) {
                            VideoCard(
                                title: "Getting Started",
                                description: "Learn the basics of VEROflow testing",
                                url: URL(string: "https://player.vimeo.com/video/1061388492")!,
                                thumbnailName: "getting-started-thumb"
                            )

                            VideoCard(
                                title: "VEROflow App Overview",
                                description: "Overview of the VEROflow App features",
                                url: URL(string: "https://player.vimeo.com/video/1069799610")!,
                                thumbnailName: "getting-started-thumb"
                            )
                        }
                        .padding()
                    }
                case .testChart:
                    MeterToleranceChartView()
                }
            }
            .padding()
        }
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

// MARK: - Enhanced Support View
struct EnhancedSupportView: View {
    @Environment(\.openURL) var openURL
    @State private var showSafari = false

    var body: some View {
        VStack(spacing: 24) {
            AnimatedSafariButton {
                showSafari = true
            }
            .anchorPreference(key: OnboardingFramePreferenceKey.self, value: .bounds) { anchor in
                 ["chatAIButtonHelp": anchor]
             }
            .sheet(isPresented: $showSafari) {
                SafariView(url: URL(string: "https://elevenlabs.io/app/talk-to?agent_id=Md5eKB1FeOQI9ykuKDxB")!)
            }

            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("MARS Chat AI")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Need help with the app? Chat with MARS Chat AI, your dedicated virtual assistant for guidance on testing procedures, troubleshooting, and more. Just press the water drop above or in the menu and reach out instantly for expert advice and support!")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(
                ZStack {
                    Color(red: 21/255, green: 21/255, blue: 21/255)
                    
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 200, height: 200)
                        .blur(radius: 60)
                        .offset(y: -30)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: .blue.opacity(0.3), radius: 20, x: 0, y: 10)
            .padding(.horizontal)
            
            ContactSupportView()
        }
        .padding()
    }
}

// MARK: - Contact Support View
struct ContactSupportView: View {
    @Environment(\.openURL) var openURL
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "headphones.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.blue)
                Text("Contact Support")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.bottom, 8)
            
            VStack(spacing: 16) {
                ContactCard(
                    icon: "building.2.fill",
                    title: "MARS Company",
                    details: ["3925 SW 13th Street", "Ocala, FL 34474"]
                )
                
                ContactCard(
                    icon: "clock.fill",
                    title: "Business Hours",
                    details: ["Monday - Friday", "8:00 AM - 5:00 PM EST"]
                )
            }
            
            VStack(spacing: 12) {
                ContactButton(
                    action: { if let url = URL(string: "tel://18777MYMARS") { openURL(url) } },
                    icon: "phone.circle.fill",
                    title: "Call Support",
                    subtitle: "1-877-7MY-MARS",
                    color: .blue
                )
                
                ContactButton(
                    action: { if let url = URL(string: "mailto:support@marswater.com") { openURL(url) } },
                    icon: "envelope.circle.fill",
                    title: "Email Support",
                    subtitle: "support@marswater.com",
                    color: .green
                )
                
                ContactButton(
                    action: { if let url = URL(string: "https://marswater.com") { openURL(url) } },
                    icon: "globe.americas.fill",
                    title: "Visit Website",
                    subtitle: "www.marswater.com",
                    color: .purple
                )
            }
        }
        .padding()
        .background(
            ZStack {
                Color.black.opacity(0.3)
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.1),
                        Color.blue.opacity(0.05)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        )
        .cornerRadius(16)
    }
}

// MARK: - ContactCard Component
struct ContactCard: View {
    let icon: String
    let title: String
    let details: [String]
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                ForEach(details, id: \.self) { detail in
                    Text(detail)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
        }
        .padding()
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
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                .blur(radius: 0.5)
        )
        .cornerRadius(12)
    }
}

// MARK: - ContactButton Component
struct ContactButton: View {
    let action: () -> Void
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
            }
            .padding()
            .background(
                ZStack {
                    Color.black.opacity(0.5)
                    LinearGradient(
                        gradient: Gradient(colors: [
                            color.opacity(0.2),
                            color.opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(0.3), lineWidth: 1)
                    .blur(radius: 0.5)
            )
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Interactive Testing Guide
struct InteractiveTestingGuide: View {
    @State private var expandedSections: Set<String> = []
    @State private var completedSteps: Set<String> = []
    @State private var testSteps: [TestingStep] = testingSteps
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Interactive Testing Guide")
                .font(.title2)
                .bold()
                .foregroundColor(.white)
                .padding(.bottom, 8)
            
            VStack(spacing: 16) {
                ForEach(Array(testSteps.enumerated()), id: \.element.id) { index, section in
                    TestingSection(
                        section: section,
                        isExpanded: expandedSections.contains(section.id),
                        isLastItem: index == testSteps.count - 1,
                        completedSteps: $completedSteps,
                        onToggle: {
                            withAnimation {
                                if expandedSections.contains(section.id) {
                                    expandedSections.remove(section.id)
                                } else {
                                    expandedSections.insert(section.id)
                                }
                            }
                        },
                        onComplete: {
                            withAnimation(.spring(duration: 0.3)) {
                                testSteps[index].isComplete.toggle()
                                if testSteps[index].isComplete {
                                    section.steps.forEach { completedSteps.insert($0) }
                                } else {
                                    section.steps.forEach { completedSteps.remove($0) }
                                }
                            }
                        }
                    )
                }
                
                if !testSteps.isEmpty {
                    HStack {
                        Image(systemName: testSteps.allSatisfy({ $0.isComplete }) ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(testSteps.allSatisfy({ $0.isComplete }) ? .green : .gray)
                        Text("Complete All Steps")
                            .foregroundColor(testSteps.allSatisfy({ $0.isComplete }) ? .white : .gray)
                        Spacer()
                    }
                    .padding(.vertical, 16)
                    .onTapGesture {
                        withAnimation(.spring(duration: 0.3)) {
                            let allComplete = testSteps.allSatisfy({ $0.isComplete })
                            testSteps.indices.forEach { index in
                                testSteps[index].isComplete = !allComplete
                                if !allComplete {
                                    testSteps[index].steps.forEach { completedSteps.insert($0) }
                                } else {
                                    testSteps[index].steps.forEach { completedSteps.remove($0) }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct TestingSection: View {
    let section: TestingStep
    let isExpanded: Bool
    let isLastItem: Bool
    @Binding var completedSteps: Set<String>
    let onToggle: () -> Void
    let onComplete: () -> Void
    
    var body: some View {
        ZStack(alignment: .leading) {
            if !isLastItem {
                VStack(spacing: 0) {
                    Circle()
                        .fill(section.isComplete ? Color.green : Color.gray)
                        .frame(width: 20, height: 20)
                    
                    Rectangle()
                        .fill(section.isComplete ? Color.green : Color.gray)
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
                .padding(.leading, 10)
            } else {
                Circle()
                    .fill(section.isComplete ? Color.green : Color.gray)
                    .frame(width: 20, height: 20)
                    .padding(.leading, 10)
            }
            
            VStack(alignment: .leading) {
                Button(action: onToggle) {
                    HStack {
                        Text(section.title)
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: section.isComplete ? "checkmark.circle.fill" : "chevron.right")
                            .rotationEffect(.degrees(isExpanded ? 90 : 0))
                            .foregroundColor(section.isComplete ? .green : .gray)
                    }
                }
                
                if isExpanded {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(section.steps, id: \.self) { step in
                            StepRow(
                                step: step,
                                isCompleted: completedSteps.contains(step),
                                onToggle: {
                                    withAnimation(.spring(duration: 0.3)) {
                                        if completedSteps.contains(step) {
                                            completedSteps.remove(step)
                                        } else {
                                            completedSteps.insert(step)
                                        }
                                        if section.steps.allSatisfy({ completedSteps.contains($0) }) {
                                            onComplete()
                                        } else if section.isComplete {
                                            onComplete()
                                        }
                                    }
                                }
                            )
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .padding()
            .padding(.leading, 24)
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
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    .blur(radius: 0.5)
            )
            .cornerRadius(12)
        }
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
                    .foregroundColor(isCompleted ? .green : .gray)
                Text(step)
                    .strikethrough(isCompleted)
                    .foregroundColor(isCompleted ? .gray : .white)
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
    @State private var selectedCategory: FAQItem.Category? = .general
    
    var filteredFAQs: [FAQItem] {
        var items = faqItems
        if let category = selectedCategory {
            items = items.filter { $0.category == category }
        }
        if !searchQuery.isEmpty {
            items = items.filter { item in
                item.question.localizedCaseInsensitiveContains(searchQuery) ||
                item.answer.localizedCaseInsensitiveContains(searchQuery)
            }
        }
        return items
    }
    
    var body: some View {
        VStack(spacing: 20) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach([FAQItem.Category.general, .testing, .hardware, .troubleshooting], id: \.self) { category in
                        CategoryPill(
                            icon: category.icon,
                            title: String(describing: category).capitalized,
                            isSelected: selectedCategory == category,
                            color: category.color
                        ) {
                            withAnimation { selectedCategory = category }
                        }
                    }
                    
                    CategoryPill(
                        icon: "tag.fill",
                        title: "All",
                        isSelected: selectedCategory == nil,
                        color: .blue
                    ) {
                        withAnimation { selectedCategory = nil }
                    }
                }
                .padding(.horizontal)
            }
            
            if filteredFAQs.isEmpty {
                EmptyStateView()
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(filteredFAQs) { item in
                            FAQItemView(
                                item: item,
                                isExpanded: expandedQuestions.contains(item.id)
                            ) {
                                withAnimation(.spring()) {
                                    if expandedQuestions.contains(item.id) {
                                        expandedQuestions.remove(item.id)
                                    } else {
                                        expandedQuestions.insert(item.id)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

struct CategoryPill: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(isSelected ? .white : color)
                Text(title)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                ZStack {
                    if isSelected {
                        color.opacity(0.3)
                    } else {
                        Color.black.opacity(0.5)
                    }
                    LinearGradient(
                        gradient: Gradient(colors: [
                            color.opacity(isSelected ? 0.4 : 0.2),
                            color.opacity(isSelected ? 0.2 : 0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(color.opacity(isSelected ? 0.8 : 0.3), lineWidth: 1)
                    .blur(radius: isSelected ? 0.5 : 0)
            )
            .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FAQItemView: View {
    let item: FAQItem
    let isExpanded: Bool
    let onToggle: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: onToggle) {
                HStack {
                    Image(systemName: item.icon)
                        .foregroundColor(item.category.color)
                        .frame(width: 24)
                    
                    Text(item.question)
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .foregroundColor(.gray)
                }
            }
            
            if isExpanded {
                Text(item.answer)
                    .padding(.leading, 32)
                    .foregroundColor(.gray)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding()
        .background(
            ZStack {
                Color.black.opacity(0.5)
                LinearGradient(
                    gradient: Gradient(colors: [
                        item.category.color.opacity(0.2),
                        item.category.color.opacity(0.05)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(item.category.color.opacity(0.3), lineWidth: 1)
                .blur(radius: 0.5)
        )
        .cornerRadius(12)
        .shadow(color: item.category.color.opacity(isHovered ? 0.2 : 0.1),
                radius: isHovered ? 12 : 8,
                x: 0,
                y: isHovered ? 6 : 4)
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.spring(response: 0.3), value: isHovered)
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.blue)
            Text("No matching questions found")
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(glassmorphicBackground)
    }
}

// MARK: - Video Card
struct VideoCard: View {
    let title: String
    let description: String
    let url: URL
    let thumbnailName: String
    @State private var showingVideo = false

    var body: some View {
        Button(action: { showingVideo = true }) {
            HStack {
                Image(systemName: "play.circle.fill")
                    .font(.title)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding()
            .background(glassmorphicBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    .blur(radius: 0.5)
            )
        }
        .sheet(isPresented: $showingVideo) {
            WebView(url: url)
        }
    }
}

// MARK: - WebView Definition
struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

// MARK: - MeterToleranceChartView
struct MeterToleranceChartView: View {
    @State private var selectedCategory: String? = nil
    @State private var expandedTypes: Set<String> = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                HStack(spacing: 16) {
                    ToleranceCategoryButton(
                        title: "Small Meters",
                        subtitle: "5/8″ to 2″",
                        isSelected: selectedCategory == "small",
                        action: { selectedCategory = selectedCategory == "small" ? nil : "small" }
                    )
                    ToleranceCategoryButton(
                        title: "Large Meters",
                        subtitle: "3″ and Larger",
                        isSelected: selectedCategory == "large",
                        action: { selectedCategory = selectedCategory == "large" ? nil : "large" }
                    )
                }
                .padding(.horizontal)
                
                if let category = selectedCategory {
                    let tolerances = category == "large" ? largeMeterTolerances : smallMeterTolerances
                    
                    ForEach(tolerances, id: \.type) { item in
                        MeterToleranceCard(
                            type: item.type,
                            lowFlow: item.lowFlow,
                            highFlow: item.highFlow,
                            isExpanded: expandedTypes.contains(item.type)
                        ) {
                            withAnimation(.spring()) {
                                if expandedTypes.contains(item.type) {
                                    expandedTypes.remove(item.type)
                                } else {
                                    expandedTypes.insert(item.type)
                                }
                            }
                        }
                    }
                } else {
                    Text("Select a meter category to view tolerances")
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
            .padding()
        }
        .navigationTitle("Meter Tolerances")
    }
}

struct ToleranceCategoryButton: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                ZStack {
                    Color(red: 21/255, green: 21/255, blue: 21/255)
                    
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 150, height: 150)
                        .blur(radius: 60)
                        .offset(y: -30)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.blue.opacity(isSelected ? 0.5 : 0.3), lineWidth: 1)
            )
            .shadow(color: .blue.opacity(isSelected ? 0.3 : 0.1), radius: 20, x: 0, y: 10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MeterToleranceCard: View {
    let type: String
    let lowFlow: String
    let highFlow: String
    let isExpanded: Bool
    let onTap: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: onTap) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(type)
                            .font(.headline)
                            .foregroundColor(.white)
                        if !isExpanded {
                            Text("Tap to view tolerances")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .foregroundColor(.gray)
                }
            }
            
            if isExpanded {
                VStack(spacing: 16) {
                    ToleranceInfoRow(title: "Low Flow", value: lowFlow)
                    ToleranceInfoRow(title: "High Flow", value: highFlow)
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding()
        .background(glassmorphicBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                .blur(radius: 0.5)
        )
    }
}

struct ToleranceInfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .bold()
                .foregroundColor(.white)
        }
        .font(.system(.body, design: .rounded))
    }
}

// MARK: - ChecklistShareSheet
struct ChecklistShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - glassmorphicBackground
private var glassmorphicBackground: some View {
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
    .overlay(
        LinearGradient(
            gradient: Gradient(colors: [
                Color.blue.opacity(0.4),
                Color.blue.opacity(0.1)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .mask(Rectangle().stroke(lineWidth: 1))
    )
}

// MARK: - MeterToleranceData
struct MeterToleranceData {
    let type: String
    let lowFlow: String
    let highFlow: String
}

// MARK: - tolerance arrays
let largeMeterTolerances = [
    MeterToleranceData(type: "Positive Displacement & Single-Jet", lowFlow: "95% – 101.5%", highFlow: "98.5% – 101.5%"),
    MeterToleranceData(type: "Multi-Jet", lowFlow: "97% – 103%", highFlow: "98.5% – 101.5%"),
    MeterToleranceData(type: "Turbine (Class II)", lowFlow: "98.5% – 101.5%", highFlow: "98.5% – 101.5%"),
    MeterToleranceData(type: "Electromagnetic/Ultrasonic", lowFlow: "95% – 105%", highFlow: "98.5% – 101.5%"),
    MeterToleranceData(type: "Fire Service", lowFlow: "95% – 101.5%", highFlow: "98.5% – 101.5%"),
    MeterToleranceData(type: "Compound", lowFlow: "95% – 101%", highFlow: "98.5% – 101.5% (Mid),\n97% – 103% (High)")
]

let smallMeterTolerances = [
    MeterToleranceData(type: "Positive Displacement & Single-Jet", lowFlow: "95% – 101.5%", highFlow: "98.5% – 101.5%"),
    MeterToleranceData(type: "Multi-Jet", lowFlow: "97% – 103%", highFlow: "98.5% – 101.5%"),
    MeterToleranceData(type: "Turbine", lowFlow: "98.5% – 101.5%", highFlow: "98.5% – 101.5%"),
    MeterToleranceData(type: "Electromagnetic/Ultrasonic", lowFlow: "95% – 105%", highFlow: "98.5% – 101.5%"),
    MeterToleranceData(type: "Fire Service", lowFlow: "95% – 101.5%", highFlow: "98.5% – 101.5%"),
    MeterToleranceData(type: "Compound", lowFlow: "95% – 101%", highFlow: "98.5% – 101.5% (Mid),\n97% – 103% (High)")
]
