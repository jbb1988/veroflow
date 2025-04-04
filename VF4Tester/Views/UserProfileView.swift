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
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        // Profile Header
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(width: 100, height: 100)
                                
                                Circle()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 2)
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 70))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            
                            if let email = authManager.user?.email {
                                VStack(spacing: 8) {
                                    Text(email)
                                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                    
                                    Text("VEROflow User")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
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
                        .padding(.top, 20)
                        
                        // Support Section
                        VStack(alignment: .leading, spacing: 24) {
                            sectionHeader("Support")
                            
                            if let supportUrl = URL(string: "mailto:support@marswater.com") {
                                Button(action: {}) {
                                    Link(destination: supportUrl) {
                                        HStack(spacing: 12) {
                                            Image(systemName: "envelope.fill")
                                                .font(.system(size: 20, weight: .medium))
                                            
                                            Text("Contact MARS Support")
                                                .font(.system(size: 17, weight: .medium))
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(.white.opacity(0.3))
                                        }
                                        .foregroundColor(.white)
                                        .padding(.vertical, 16)
                                        .padding(.horizontal, 20)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white.opacity(0.05))
                                        )
                                    }
                                }
                            }
                            
                            if let phoneUrl = URL(string: "tel:1877696277") {
                                Button(action: {}) {
                                    Link(destination: phoneUrl) {
                                        HStack(spacing: 12) {
                                            Image(systemName: "phone.fill")
                                                .font(.system(size: 20, weight: .medium))
                                            
                                            Text("Call 1-877-MY-MARS")
                                                .font(.system(size: 17, weight: .medium))
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(.white.opacity(0.3))
                                        }
                                        .foregroundColor(.white)
                                        .padding(.vertical, 16)
                                        .padding(.horizontal, 20)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white.opacity(0.05))
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Account Section
                        VStack(alignment: .leading, spacing: 24) {
                            sectionHeader("Account")
                            
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
                                }
                                .foregroundColor(.red)
                                .padding(.vertical, 16)
                                .padding(.horizontal, 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.05))
                                )
                            }
                        }
                        .padding(.horizontal)
                        
                        // MARS Logo
                        VStack(spacing: 20) {
                            Image("MARS Company")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 60)
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                    }
                }
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
    
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.white.opacity(0.6))
            .textCase(.uppercase)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
