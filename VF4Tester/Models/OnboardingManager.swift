import SwiftUI
import Combine

// Define the structure for each onboarding step
struct OnboardingStep: Identifiable {
    let id = UUID()
    let targetElementID: String // An identifier for the UI element to highlight
    let title: String
    let text: String
    let preferredEdge: Edge = .bottom // Default tooltip position preference
    // Add other properties like preferred alignment if needed
}

// ObservableObject to manage the onboarding process
class OnboardingManager: ObservableObject {
    @Published var isOnboardingActive: Bool = false
    @Published private(set) var currentStepIndex: Int = 0
    @AppStorage("showInteractiveOnboarding") private var showOnboarding: Bool = true
    @Published var showMenu: Bool = false
    
    let steps: [OnboardingStep] = [
        // Step 1: Menu Button
        OnboardingStep(
            targetElementID: "menuButton", // Exists
            title: "Main Menu",
            text: "Tap here to access all app sections like Test History, Settings, Shop, and Help."
        ),
        // Step 2: Test Area
        OnboardingStep(
            targetElementID: "testTabContent", // Exists
            title: "Meter Testing",
            text: "Enter your start/end readings and other details here to perform a meter test."
        ),
        // Step 3: History Menu Item
        OnboardingStep(
            targetElementID: "historyMenuItem", // Needs anchor added to NavigationMenuView
            title: "Test History",
            text: "View past test results and export reports from the History section."
        ),
        // Step 4: Help Menu Item
        OnboardingStep(
            targetElementID: "helpMenuItem", // Needs anchor added to NavigationMenuView
            title: "Help & Resources",
            text: "Find video demos, testing guides, FAQs, and support contact information here."
        ),
        // Step 5: MARS Chat AI
        OnboardingStep(
            targetElementID: "chatAIButtonHelp", // Needs anchor added to HelpView
            title: "MARS Chat AI",
            text: "Need assistance? Tap the water drop to chat with our AI assistant for guidance on testing, troubleshooting, and more."
        )
    ]

    var currentStep: OnboardingStep? {
        guard isOnboardingActive, currentStepIndex < steps.count else {
            return nil
        }
        return steps[currentStepIndex]
    }

    // MARK: - Control Functions
    func startOnboardingIfNeeded() {
        if showOnboarding && !isOnboardingActive {
            print("[OnboardingManager] Starting onboarding. showOnboarding: \(showOnboarding)")
            elementFrames.removeAll()
            currentStepIndex = 0
            isOnboardingActive = true
        } else {
             print("[OnboardingManager] No need to start. showOnboarding: \(showOnboarding), isOnboardingActive: \(isOnboardingActive)")
        }
    }

    func nextStep() {
        guard isOnboardingActive else {
            print("[OnboardingManager] Cannot advance - onboarding not active")
            return
        }
        
        print("[OnboardingManager] Current step: \(currentStepIndex), Total steps: \(steps.count)")
        
        if currentStepIndex < steps.count - 1 {
            let nextStep = steps[currentStepIndex + 1]
            
            // If moving to or from a menu item step
            if nextStep.targetElementID.contains("MenuItem") {
                print("[OnboardingManager] Opening menu for menu item step")
                showMenu = true
                // Give time for the menu to appear and register its frame
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.currentStepIndex += 1
                    print("[OnboardingManager] Advanced to step \(self.currentStepIndex): \(self.steps[self.currentStepIndex].title)")
                }
            } else {
                // If we're leaving a menu item step, keep the menu open
                let currentStep = steps[currentStepIndex]
                if !currentStep.targetElementID.contains("MenuItem") {
                    showMenu = false
                }
                currentStepIndex += 1
            }
            
            // Verify frame exists for current step
            let stepID = steps[currentStepIndex].targetElementID
            if elementFrames[stepID] == nil {
                print("[OnboardingManager] Warning: No frame found for step \(currentStepIndex) - \(stepID)")
            }
        } else {
            print("[OnboardingManager] Reached final step - completing onboarding")
            completeOnboarding()
        }
    }

    func skipOnboarding() {
        print("[OnboardingManager] Skipping onboarding")
        completeOnboarding()
    }

    private func completeOnboarding() {
        print("[OnboardingManager] Completing onboarding")
        isOnboardingActive = false
        showMenu = false
        showOnboarding = false
        currentStepIndex = 0
        elementFrames.removeAll()
    }

    // --- Frame Tracking ---
    @Published var elementFrames: [String: Anchor<CGRect>] = [:]

    func setFrame(id: String, anchor: Anchor<CGRect>) {
        if isOnboardingActive {
            DispatchQueue.main.async {
                if self.elementFrames[id] != anchor {
                    print("[OnboardingManager] Setting frame for ID: \(id)")
                    self.elementFrames[id] = anchor
                    
                    // Verify if this is the frame we're waiting for
                    if let currentStep = self.currentStep, currentStep.targetElementID == id {
                        print("[OnboardingManager] Received frame for current step: \(id)")
                    }
                }
            }
        }
    }
}

// PreferenceKey remains the same
struct OnboardingFramePreferenceKey: PreferenceKey {
    typealias Value = [String: Anchor<CGRect>]

    static var defaultValue: Value = [:]

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}
