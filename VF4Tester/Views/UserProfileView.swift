import SwiftUI
import FirebaseAuth

struct UserProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "1B2838")
                    .ignoresSafeArea()

                ConfigurableWeavePattern(opacity: 0.3)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            VStack(spacing: 24) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.1))
                                        .frame(width: 110, height: 110)

                                    Circle()
                                        .stroke(Color.white.opacity(0.2), lineWidth: 2)
                                        .frame(width: 110, height: 110)

                                    Image(systemName: "person.circle.fill")
                                        .font(.system(size: 80))
                                        .foregroundColor(.white.opacity(0.9))
                                }
                                .padding(.top, 20)

                                if let email = authManager.user?.email {
                                    VStack(spacing: 8) {
                                        Text(email)
                                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                                            .foregroundColor(.white)

                                        Text("VEROflow User")
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                            .foregroundColor(.white.opacity(0.6))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(
                                                Capsule()
                                                    .fill(Color.white.opacity(0.1))
                                            )
                                    }
                                }
                            }
                            .padding(.bottom, 40)

                            VStack(spacing: 16) {
                                VStack(spacing: 2) {
                                    HStack {
                                        Text("Account Settings")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white.opacity(0.6))
                                            .textCase(.uppercase)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 24)
                                    .padding(.bottom, 8)

                                    Button(action: {
                                        authManager.signOut()
                                        dismiss()
                                    }) {
                                        HStack(spacing: 12) {
                                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                                .font(.system(size: 20, weight: .medium))

                                            Text("Sign Out")
                                                .font(.system(size: 17, weight: .medium))

                                            Spacer()

                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(.red.opacity(0.7))
                                        }
                                        .foregroundColor(.red)
                                        .padding(.vertical, 16)
                                        .padding(.horizontal, 20)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white.opacity(0.05))
                                        )
                                    }
                                    .padding(.horizontal, 24)
                                }
                            }
                        }
                    }

                    Spacer()

                    VStack(spacing: 15) {
                        Image("MARS Company")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 80)

                        VStack(spacing: 5) {
                            if let url = URL(string: "tel:1877696277") {
                                Link("1-877-MY-MARS", destination: url)
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(hex: "66C0F4"))
                            } else {
                                Text("1-877-MY-MARS")
                                   .font(.system(size: 14, weight: .medium, design: .rounded))
                                   .foregroundColor(.white.opacity(0.7))
                            }

                            if let emailUrl = URL(string: "mailto:support@marswater.com") {
                                 Link("support@marswater.com", destination: emailUrl)
                                     .font(.system(size: 14, weight: .medium, design: .rounded))
                                     .foregroundColor(Color(hex: "66C0F4"))
                             } else {
                                 Text("support@marswater.com")
                                     .font(.system(size: 14, weight: .medium, design: .rounded))
                                     .foregroundColor(.white.opacity(0.7))
                             }
                        }
                    }
                    .padding(.bottom, 30)

                }
                .padding(.top, 20)

            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "xmark")
                                .font(.system(size: 17, weight: .medium))
                            Text("Close")
                                .font(.system(size: 17, weight: .regular))
                        }
                        .foregroundColor(.white.opacity(0.8))
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text("Profile")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
    }
}
