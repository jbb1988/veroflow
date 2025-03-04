import SwiftUI

struct TypingEffect: View {
    @State private var displayedText = ""
    var fullText: String
    @State private var currentCharacterIndex: String.Index!
    @Binding var isExpanded: Bool
    
    var body: some View {
        VStack {
            Text(displayedText)
                .font(.custom("Courier", size: 15))
                .foregroundColor(.white)
                .frame(width: 380, height: 150, alignment: .topLeading)
        }
        .onChange(of: isExpanded) { newValue in
            if newValue {
                startTypingEffect()
            }
        }
    }
    
    func startTypingEffect() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            currentCharacterIndex = fullText.startIndex
            Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
                displayedText.append(fullText[currentCharacterIndex])
                currentCharacterIndex = fullText.index(after: currentCharacterIndex)
                if currentCharacterIndex == fullText.endIndex {
                    timer.invalidate()
                }
            }
        }
    }
}
