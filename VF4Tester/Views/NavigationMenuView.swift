import SwiftUI

struct AppNavigationMenuView: View {
    @Binding var isMenuOpen: Bool
    @Binding var selectedTab: AppNavigationItem

    var body: some View {
        List(AppNavigationItem.allCases, id: \.self) { item in
            Button(action: {
                selectedTab = item
                isMenuOpen = false
            }) {
                HStack {
                    Image(systemName: item.icon)
                    Text(item.rawValue)
                }
            }
        }
        .listStyle(SidebarListStyle())
    }
}