import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        ZStack {
            // Background
            WeavePattern()
                .ignoresSafeArea()
            
            VStack {
                // Logo - keep current size
                Image("veroflowLogo")
                    .resizable()
                    .renderingMode(.original)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: UIScreen.main.bounds.width * 1.2)
                    .padding(.top, 60)
                
                Spacer()
                
                // Login Card with reduced size
                VStack(spacing: 16) { 
                    // Email field
                    TextField("Email", text: $email)
                        .textFieldStyle(.plain)
                        .padding(.vertical, 12) 
                        .padding(.horizontal, 16) 
                        .background(Color.black.opacity(0.7))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.blue.opacity(0.8),
                                            Color.blue.opacity(0.2)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.8) 
                    
                    // Password field
                    SecureField("Password", text: $password)
                        .textFieldStyle(.plain)
                        .padding(.vertical, 12) 
                        .padding(.horizontal, 16) 
                        .background(Color.black.opacity(0.7))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.blue.opacity(0.8),
                                            Color.blue.opacity(0.2)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.8) 
                    
                    if let errorMessage = authManager.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    // Sign In button
                    Button(action: {
                        authManager.signIn(email: email, password: password)
                    }) {
                        Text("Sign In")
                            .frame(maxWidth: UIScreen.main.bounds.width * 0.8) 
                            .padding(.vertical, 12) 
                            .background(
                                ZStack {
                                    Color.black.opacity(0.5)
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.blue.opacity(0.2),
                                            Color.blue.opacity(0.05)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                }
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.blue.opacity(0.8),
                                                Color.blue.opacity(0.2)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                            .cornerRadius(12)
                            .shadow(color: Color.blue.opacity(0.2), radius: 8, x: 0, y: 0)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal) 
                
                // Contact info
                HStack(spacing: 0) {
                    Text("Need access? Contact us at ")
                        .foregroundColor(.white)
                    Text("support@marswater.com")
                        .foregroundColor(.blue)
                }
                .font(.caption)
                .multilineTextAlignment(.center)
                .padding(.top, 16) 
                .padding(.bottom, 30)
            }
            .padding()
        }
    }
}
