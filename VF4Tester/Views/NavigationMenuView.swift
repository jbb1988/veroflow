import SwiftUI
#if os(iOS)
import SafariServices
#endif

struct NavigationMenuView: View {
    @Binding var isMenuOpen: Bool
    @Binding var selectedTab: AppNavigationItem
    @State private var showSafari = false
    @EnvironmentObject var authManager: AuthManager
    var onTabSelect: (AppNavigationItem) -> Void
    
    // ADD: Cached menu items
    private let menuItems = AppNavigationItem.allCases
    
    var body: some View {
        ZStack {
            MenuBackgroundView()
                .edgesIgnoringSafeArea(.all)
            
            ScrollView(showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 20) {
                    title
                    menuButtons
                    Spacer(minLength: 0)
                    
                    // Add Sign Out button
                    Button(action: {
                        authManager.signOut()
                    }) {
                        HStack(spacing: 15) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 20, weight: .medium))
                                .frame(width: 24)
                            Text("Sign Out")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                        }
                        .foregroundColor(.red)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                    }
                    .padding(.top, 20)
                    
                    safariButton
                }
                .padding(.horizontal, 20)
            }
            // ADD: Optimize scroll performance
            .scrollDismissesKeyboard(.immediately)
        }
    }
    
    private var title: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("BROWSE")
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .opacity(0.7)
                .padding(.bottom, 8)
            Rectangle()
                .frame(height: 2)
                .foregroundColor(Color.white.opacity(0.3))
                .padding(.bottom, 12)
        }
        .padding(.top, 100)
        // ADD: Reduce redraws
        .drawingGroup()
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
    
    private var safariButton: some View {
        HStack {
            Spacer()
            AnimatedSafariButton {
                showSafari = true
            }
            .scaleEffect(1.2)
            Spacer()
        }
        .padding(.bottom, 100)
        // CHANGE: Optimize sheet presentation
        .sheet(isPresented: $showSafari) {
            SafariView(url: URL(string: "https://elevenlabs.io/app/talk-to?agent_id=Md5eKB1FeOQI9ykuKDxB")!)
                .edgesIgnoringSafeArea(.all)
        }
    }
}

// ADD: Optimized menu button component
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
