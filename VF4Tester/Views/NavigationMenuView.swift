import SwiftUI
#if os(iOS)
import SafariServices
#endif

struct NavigationMenuView: View {
    @Binding var isMenuOpen: Bool
    @Binding var selectedTab: AppNavigationItem
    @State private var showSafari = false
    @State private var showProfile = false
    @EnvironmentObject var authManager: AuthManager
    var onTabSelect: (AppNavigationItem) -> Void
    
    private let menuItems = AppNavigationItem.allCases
    
    var body: some View {
        ZStack {
            MenuBackgroundView()
                .edgesIgnoringSafeArea(.all)
            
            ScrollView(showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 20) {
                    Button(action: {
                        showProfile = true
                    }) {
                        HStack(spacing: 15) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Profile")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.white.opacity(0.9))
                                Text("Tap to view")
                                    .font(.system(size: 12, weight: .regular, design: .rounded))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                    }
                    .standardContentSpacing()
                    .sheet(isPresented: $showProfile) {
                        UserProfileView()
                    }
                    
                    menuButtons
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        AnimatedSafariButton {
                            showSafari = true
                        }
                        .scaleEffect(1.2)
                        Spacer()
                    }
                    .padding(.bottom, 50)
                    .sheet(isPresented: $showSafari) {
                        SafariView(url: URL(string: "https://elevenlabs.io/app/talk-to?agent_id=Md5eKB1FeOQI9ykuKDxB")!)
                            .edgesIgnoringSafeArea(.all)
                    }
                }
                .padding(.horizontal, 20)
            }
            .scrollDismissesKeyboard(.immediately)
        }
    }
    
    private var menuButtons: some View {
        ForEach(menuItems, id: \.self) { item in
            MenuButton(
                item: item,
                isSelected: selectedTab == item,
                onTap: { onTabSelect(item) }
            )
        }
    }
}

private struct MenuButton: View, Equatable {
    let item: AppNavigationItem
    let isSelected: Bool
    let onTap: () -> Void
    
    static func == (lhs: MenuButton, rhs: MenuButton) -> Bool {
        lhs.item == rhs.item && lhs.isSelected == rhs.isSelected
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 15) {
                Image(systemName: item.icon)
                    .font(.system(size: 20, weight: .medium))
                    .frame(width: 24)
                Text(item.rawValue)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
            }
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                Group {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.15))
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#if os(iOS)
private struct MenuSafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let controller = SFSafariViewController(url: url)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
#endif
