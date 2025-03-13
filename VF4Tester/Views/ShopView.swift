import SwiftUI

struct ShopView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Add top padding to avoid header overlap
                Spacer()
                    .frame(height: 60)
                
                // Overview Card
                NavigationLink(destination: EmptyView()) {
                    ZStack {
                        // Card background
                        RoundedRectangle(cornerRadius: 15)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.black.opacity(0.7),
                                        Color.black.opacity(0.9)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                            .shadow(radius: 10)

                        VStack(alignment: .leading, spacing: 16) {
                            Text("MARS Company Diversified Products")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                // Remove lineLimit
                                .fixedSize(horizontal: false, vertical: true)

                            Text("Our NSF-61 Certified Fabricated Test Port Spools, Z-Plate Strainers, and No-Lead Bronze Strainers deliver exceptional quality and regulatory compliance. Custom sizes and configurations available to streamline your water management needs.\n\nFrom valve keys to zinc caps, drill taps and beyond—MARS offers a comprehensive range of water infrastructure solutions designed with industry expertise and manufactured to the highest standards.")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .lineSpacing(4)
                                // Allow text to wrap naturally
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(24)
                    }
                    .frame(minHeight: 300) // Change to minHeight to allow content to expand
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.vertical)
        }
        .background(Color.black)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ShopView_Previews: PreviewProvider {
    static var previews: some View {
        ShopView()
    }
}
