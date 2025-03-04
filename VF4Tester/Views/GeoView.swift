import SwiftUI

struct GeoView: View {
    // Binding variables for animation control
    @Binding var isExpanded: Bool
    @Binding var startTyping: Bool
    @Binding var showText: Bool
    
    // View configuration
    let color: String
    let text: String
    @Binding var showNextView: Bool
    var shouldToggleExpand: Bool = true
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Animated circle background
                Circle()
                    .foregroundColor(Color(color))
                    .frame(width: isExpanded ? max(geometry.size.width, geometry.size.height) * 1.5 : 200,
                           height: isExpanded ? max(geometry.size.width, geometry.size.height) * 1.5 : 200)
                
                // NEXT button with arrow
                if !isExpanded {
                    HStack {
                        Text(text)
                        Image(systemName: "arrow.right")
                    }
                    .bold()
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                }
                
                Text(text)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .opacity(isExpanded ? 1 : 0)
                    .scaleEffect(isExpanded ? 1 : 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .offset(x: isExpanded ? -250 : 40, y: isExpanded ? -150 : 20)
            .onTapGesture {
                withAnimation(.spring(response: 0.9, dampingFraction: 0.8)) {
                    if shouldToggleExpand {
                        isExpanded.toggle()
                    } else {
                        isExpanded = true
                    }
                }
                
                showText.toggle()
                startTyping = true
                
                if showNextView {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showNextView.toggle()
                    }
                }
            }
        }
    }
}
