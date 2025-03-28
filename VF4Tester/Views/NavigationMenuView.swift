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

    @State private var drops: [MenuDrop] = []
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            ForEach(drops) { drop in
                Image("mars3d")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .scaleEffect(drop.scale)
                    .opacity(drop.opacity)
                    .position(x: drop.x, y: drop.y)
                    .shadow(color: Color.white.opacity(0.5), radius: 4)
            }
            
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
                
                MenuAnimatedSafariButton {
                    showSafari = true
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 100)
                .padding(.top, -150)
                .sheet(isPresented: $showSafari) {
                    #if os(iOS)
                    MenuSafariView(url: URL(string: "https://elevenlabs.io/app/talk-to?agent_id=Md5eKB1FeOQI9ykuKDxB")!)
                    #else
                    EmptyView()
                    #endif
                }
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            startRain()
        }
        .onReceive(timer) { _ in
            updateDrops()
        }
    }
    
    private func startRain() {
        let menuWidth: CGFloat = UIScreen.main.bounds.width * 0.55
        for _ in 0...7 {
            drops.append(MenuDrop(
                x: CGFloat.random(in: 0...menuWidth),
                y: -50,
                scale: CGFloat.random(in: 0.4...0.8),
                opacity: Double.random(in: 0.2...0.4),
                speed: Double.random(in: 2...5)
            ))
        }
    }
    
    private func updateDrops() {
        let menuWidth: CGFloat = UIScreen.main.bounds.width * 0.55
        let screenHeight = UIScreen.main.bounds.height
        if drops.count < 10 {
            drops.append(MenuDrop(
                x: CGFloat.random(in: 0...menuWidth),
                y: -50,
                scale: CGFloat.random(in: 0.4...0.8),
                opacity: Double.random(in: 0.2...0.4),
                speed: Double.random(in: 2...5)
            ))
        }
        drops = drops.compactMap { drop in
            var updatedDrop = drop
            updatedDrop.y += drop.speed
            return updatedDrop.y > screenHeight + 50 ? nil : updatedDrop
        }
    }
}

private struct MenuDrop: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var scale: CGFloat
    var opacity: Double
    var speed: Double
}

private struct MenuAnimatedSafariButton: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image("veroflowLogo")
                .resizable()
                .scaledToFit()
                .frame(height: 40)
                .shadow(radius: 2)
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
