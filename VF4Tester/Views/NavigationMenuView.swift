import SwiftUI
#if os(iOS)
import SafariServices
#endif

struct NavigationMenuView: View {
    @Binding var isMenuOpen: Bool
    @Binding var selectedTab: AppNavigationItem
    @State private var showSafari = false
    var onTabSelect: (AppNavigationItem) -> Void
    
    var body: some View {
        ZStack {
            MenuBackgroundView()
                .edgesIgnoringSafeArea(.all)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    title
                    menuButtons
                    Spacer(minLength: 0)
                    safariButton
                }
                .padding(.horizontal, 20)
            }
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
    }
    
    private var menuButtons: some View {
        ForEach(AppNavigationItem.allCases, id: \.self) { item in
            Button(action: {
                onTabSelect(item)
                // Slight delay before closing menu
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeOut(duration: 0.25)) {
                        isMenuOpen = false
                    }
                }
            }) {
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
                    selectedTab == item ?
                    RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    ) : nil
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
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
        .sheet(isPresented: $showSafari) {
            SafariView(url: URL(string: "https://elevenlabs.io/app/talk-to?agent_id=Md5eKB1FeOQI9ykuKDxB")!)
        }
    }
}

#if os(iOS)
private struct MenuSafariView: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
#endif
