import SwiftUI
import MessageUI

struct ShopView: View {
    @State private var showingDetail = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Add top padding to avoid header overlap
                Spacer()
                    .frame(height: 60)
                
                // Overview Card
                VStack(alignment: .leading, spacing: 16) {
                    Text("MARS Company Diversified Products")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        // Remove lineLimit
                        .fixedSize(horizontal: false, vertical: true)

                    Text("From our NSF-61 Certified Test Port Spools and Strainers to our valve keys, zinc caps, drill taps and beyond—MARS offers a comprehensive range of water infrastructure solutions designed with industry expertise and manufactured to the highest standards.")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .lineSpacing(4)
                        // Allow text to wrap naturally
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        .shadow(radius: 10)
                )
                .frame(minHeight: 300)
                .padding(.horizontal)
                
                // Test Port Spools Card
                VStack(spacing: 0) {
                    ZStack(alignment: .topTrailing) {
                        Image("spool")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .padding(.top)
                        
                        Image("nsf")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .padding([.top, .trailing], 20)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Test Port Spools")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("NSF61 Certified spools designed for streamlined water meter installations")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .lineLimit(2)
                        
                        HStack(spacing: 24) {
                            FeatureItem(text: "NSF61 Cert...")
                            FeatureItem(text: "Custom Si...")
                            FeatureItem(text: "150 PSI Rat...")
                        }
                        .padding(.top, 8)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(
                    ZStack {
                        Color(red: 21/255, green: 21/255, blue: 21/255)
                        
                        // Blue glow behind image
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 200, height: 200)
                            .blur(radius: 60)
                            .offset(y: -30)
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .onTapGesture {
                    showingDetail = true
                }
                .shadow(color: .blue.opacity(0.3), radius: 20, x: 0, y: 10)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.vertical)
        }
        .background(Color.black)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingDetail) {
            TestPortSpoolsDetailView()
        }
    }
}

struct TestPortSpoolsDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false
    
    func composeEmail() {
        let subject = "Request For Quote - Test Port Spools"
        let body = "Hello,\n\nI'm interested in getting a quote for Test Port Spools.\n\nMy name is {name} from {company} and my number is {phone}."
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let mailtoString = "mailto:support@marswater.com?subject=\(encodedSubject)&body=\(encodedBody)"
        
        if let mailtoUrl = URL(string: mailtoString), UIApplication.shared.canOpenURL(mailtoUrl) {
            UIApplication.shared.open(mailtoUrl)
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Hero section with gradient and image
                    ZStack {
                        LinearGradient(
                            colors: [.blue, .blue.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(height: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                        Image("spool")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .shadow(radius: 10)
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Description section
                        Text("NSF61 Certified Fabricated Test Port Spools designed to streamline water meter installations and testing for municipalities, distributors, and meter manufacturers. This innovation ensures perfect fit during installation while meeting the highest standards for water safety and quality.")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        // Features section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Key Features")
                                .font(.headline)
                            
                            ForEach(["Control Epoxy Coating", "Material Body", "AWWA C707 Class D Flanges", "150 PSI Operating Pressure", "Multiple Size Options"], id: \.self) { feature in
                                Label(
                                    title: { Text(feature) },
                                    icon: { Image(systemName: "checkmark.circle.fill") }
                                )
                                .foregroundColor(.secondary)
                            }
                        }
                        
                        // Specifications section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Specifications")
                                .font(.headline)
                            
                            let specs = [
                                "Material": "Schedule 40 Steel Pipe",
                                "Coating": "Control Epoxy",
                                "Pressure Rating": "150 PSI",
                                "Oval Sizes": "1.5 to 2 inches",
                                "Round Sizes": "3 to 12 inches"
                            ]
                            
                            ForEach(Array(specs.keys.sorted()), id: \.self) { key in
                                HStack {
                                    Text(key)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(specs[key] ?? "")
                                        .bold()
                                }
                            }
                        }
                        
                        // Action buttons
                        HStack(spacing: 12) {
                            Button {
                                showShareSheet = true
                            } label: {
                                HStack {
                                    Image(systemName: "doc.text.fill")
                                    Text("View\nProduct Sheet")
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .tint(.blue)
                            
                            Button {
                                composeEmail()
                            } label: {
                                HStack {
                                    Image(systemName: "envelope.fill")
                                    Text("Request\nFor Quote")
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .tint(.blue)
                        }
                        .frame(maxHeight: 60)
                        .padding(.top)
                    }
                    .padding()
                }
            }
            .navigationTitle("Test Port Spools")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                NavigationView {
                    WebView(url: URL(string: "https://www.marswater.com/?wpdmdl=989")!)
                        .navigationTitle("Product Sheet")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Done") { showShareSheet = false }
                            }
                        }
                }
            }
        }
    }
}

struct CharacteristicRow: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            Text(description)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}

struct FeatureItem: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.blue)
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.white)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.title3)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct ShopView_Previews: PreviewProvider {
    static var previews: some View {
        ShopView()
    }
}
