import SwiftUI
#if os(iOS)
import SafariServices
#endif

struct NavigationMenuView: View {
    @Binding var isMenuOpen: Bool
    @Binding var selectedTab: AppNavigationItem
    @State private var selectedItemId: UUID? = nil
    @Namespace private var menuNamespace
    @State private var showSafari = false

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("BROWSE")
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(0.7)
                        .padding(.bottom, 8)
                        .blur(radius: 0.5)
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(Color.white.opacity(0.3))
                        .blur(radius: 0.5)
                        .padding(.bottom, 12)
                }
                .padding(.top, 100)
                
                ForEach(AppNavigationItem.allCases, id: \.self) { item in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = item
                            selectedItemId = UUID()
                            isMenuOpen = false
                        }
                    }) {
                        HStack(spacing: 15) {
                            Image(systemName: item.icon)
                                .font(.system(size: 20, weight: .medium))
                                .frame(width: 24)
                                .matchedGeometryEffect(id: "icon_\(item)", in: menuNamespace)
                            Text(item.rawValue)
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(
                            ZStack {
                                if selectedTab == item {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.15))
                                        .matchedGeometryEffect(id: "background_\(item)", in: menuNamespace)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                        )
                                }
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .scaleEffect(selectedTab == item ? 1.02 : 1.0)
                    .overlay(
                        selectedTab == item ?
                        HStack {
                            Spacer()
                            Rectangle()
                                .fill(Color.white)
                                .frame(width: 3, height: 24)
                                .cornerRadius(1.5)
                        } : nil
                    )
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
                }
                
                Spacer()

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
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .edgesIgnoringSafeArea(.all)
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
