import SwiftUI

// MARK: - MenuView
struct MenuView: View {
    @Binding var isOpen: Bool
    @Binding var selectedView: NavigationItem

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer()
                .frame(height: 60)
            
            ForEach(NavigationItem.allCases, id: \.self) { item in
                Button(action: {
                    withAnimation {
                        selectedView = item
                        isOpen = false
                    }
                }) {
                    HStack(spacing: 15) {
                        Image(systemName: item.icon)
                            .frame(width: 24)
                        Text(item.rawValue)
                            .font(.system(size: 18, weight: .medium))
                    }
                    .foregroundColor(selectedView == item ? .blue : .white)
                    .padding(.vertical, 8)
                }
            }
            
            Spacer()
            
            Image("marsLogo")
                .resizable()
                .scaledToFit()
                .frame(height: 50)
                .padding(.bottom, 20)
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0/255, green: 79/255, blue: 137/255))
    }
}

// End of file
