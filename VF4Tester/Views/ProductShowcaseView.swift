import SwiftUI
import WebKit

// MARK: - Product Model
struct VEROflowProduct: Identifiable {
    let id = UUID()
    let name: String
    let subtitle: String
    let description: String
    let features: [String]
    let specifications: [String: String]
    let imageName: String
    let gradient: LinearGradient
    
    // Optional PDF URL for product sheet
    let pdfURL: URL?
}

// MARK: - Product Data
let veroflowProducts = [
    VEROflowProduct(
        name: "VEROflow Calibration Service",
        subtitle: "Premium Testing Solution",
        description: "Experience MARS's comprehensive calibration service with the power of our VEROflow-4 companion app. Unlock advanced features including OCR meter reading technology, GPS location tracking, MARS AI assistance, analytics dashboard, and customizable data exports - all with secure local data storage.",
        features: [
            "16-Point NIST Calibration",
            "VEROflow App Features (VF-4 Only)",
            "OCR & GPS Technology",
            "MARS AI Integration",
            "Advanced Analytics",
            "Custom Data Export"
        ],
        specifications: [
            "Service Type": "Premium Calibration",
            "Supported Models": "VF-1 and VF-4",
            "App Compatibility": "VF-4 Touch Only",
            "Data Storage": "Local Device",
            "Export Options": "CSV, PDF, Custom"
        ],
        imageName: "certified",
        gradient: LinearGradient(
            colors: [Color.purple, Color.blue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        pdfURL: nil
    ),
    VEROflowProduct(
        name: "VEROflow-1",
        subtitle: "Residential Meter Tester",
        description: "The VEROflow-1 utilizes microprocessor technology for precise flow rate measurements up to 1/10 GPM, offering immediate, reliable readings with effortless installation.",
        features: [
            "Accurate To +/- 1.5%",
            "Locate Pressure Problems",
            "Resolve Customer Complaints",
            "Precision Microprocessor Test Unit",
            "Lightweight & Portable Field Testing"
        ],
        specifications: [
            "Flow Range": "3 to 50 GPM",
            "Pressure": "150 PSI",
            "Moving Parts": "1 Turbine Rotor",
            "Connections": "5/8\" x 3/4\" Meter Threads"
        ],
        imageName: "vf1-product",
        gradient: LinearGradient(
            colors: [Color.blue, Color.blue.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        pdfURL: URL(string: "https://www.marswater.com/?wpdmdl=989")
    ),
    VEROflowProduct(
        name: "VEROflow-4 Touch",
        subtitle: "Advanced Mobile Testing System",
        description: "The VEROflow-4 Touch represents the pinnacle of mobile meter testing technology. This advanced system features a user-friendly touchscreen interface, high-precision flow measurement, and compatibility with our exclusive companion app for comprehensive field testing solutions.",
        features: [
            "Intuitive Touchscreen Interface",
            "High-Precision Flow Measurement",
            "Companion App Compatible",
            "Automatic Flow Rate Detection",
            "Temperature Compensation",
            "NEMA 4X Water Resistant"
        ],
        specifications: [
            "Flow Range": "0.1 to 400 GPM",
            "Accuracy": "±1.5%",
            "Temperature Range": "32° F To 120° F",
            "Max Pressure": "300 PSI",
            "Display": "7\" Color Touchscreen"
        ],
        imageName: "vf4-product",
        gradient: LinearGradient(
            colors: [Color.red, Color.blue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        pdfURL: URL(string: "https://www.marswater.com/?wpdmdl=991")
    ),
    VEROflowProduct(
        name: "VEROflow-10",
        subtitle: "Mobile, Large-Meter Tester",
        description: "The VEROflow-10 is the industry's most advanced M3 Enterprise software-driven mobile testing device, featuring state-of-the-art turbine technology with 22-point linearization.",
        features: [
            "Test Large Meters (2\" to 10\")",
            "22-Point Linearization",
            "0.1% Repeatable Accuracy",
            "Automatic Flow Rate Detection",
            "NEMA 4X Water Resistant",
            "Powered by MARS M3 Enterprise Software"
        ],
        specifications: [
            "Weight": "765 lbs",
            "Dimensions": "72\" x 28\" x 26\"",
            "Min Flow": "0.75 GPM",
            "Max Flow": "1250 GPM",
            "Max Pressure": "150 PSI"
        ],
        imageName: "vf10-product",
        gradient: LinearGradient(
            colors: [Color.purple, Color.blue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        pdfURL: URL(string: "https://www.marswater.com/?wpdmdl=1694")
    )
]

// MARK: - Main View
struct ProductShowcaseView: View {
    @State private var selectedProduct: VEROflowProduct? = nil
    @State private var showPDFSheet = false
    @State private var isAnimating = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                Text("")
                    .font(.system(size: 28, weight: .bold))
                    .padding(.top)
                
                Text("Discover our comprehensive range of field testing solutions")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Product Cards
                ForEach(veroflowProducts) { product in
                    ProductCard(product: product, isAnimating: $isAnimating)
                        .onTapGesture {
                            selectedProduct = product
                        }
                }
            }
            .padding()
        }
        .sheet(item: $selectedProduct) { product in
            ProductDetailView(product: product)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Product Card
struct ProductCard: View {
    let product: VEROflowProduct
    @Binding var isAnimating: Bool
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Product Image section remains the same
            ZStack {
                Circle()
                    .fill(product.gradient)
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)
                    .opacity(0.8)
                
                Image(product.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 160)
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .frame(maxWidth: .infinity)
            .padding(.top)
            
            // Content section remains the same
            VStack(alignment: .leading, spacing: 8) {
                Text(product.name)
                    .font(.title2)
                    .bold()
                
                Text(product.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(product.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .padding(.top, 4)
            }
            
            // Features section remains the same
            HStack {
                ForEach(product.features.prefix(3), id: \.self) { feature in
                    Label(
                        title: { Text(feature).lineLimit(1) },
                        icon: { Image(systemName: "checkmark.circle.fill") }
                    )
                    .font(.caption)
                    .foregroundColor(.secondary)
                    
                    if feature != product.features.prefix(3).last {
                        Divider()
                    }
                }
            }
            .padding(.vertical, 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(color: isHovered ? .blue.opacity(0.3) : Color.black.opacity(0.1),
                        radius: isHovered ? 15 : 10,
                        x: 0,
                        y: isHovered ? 8 : 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(product.gradient, lineWidth: isHovered ? 2 : 0)
        )
        .offset(y: isAnimating ? 0 : 50)
        .opacity(isAnimating ? 1 : 0)
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.spring(response: 0.3), value: isHovered)
        .onHover { isHovered = $0 }
    }
}

// MARK: - Product Detail View
struct ProductDetailView: View {
    let product: VEROflowProduct
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false
    
    func composeEmail(for product: VEROflowProduct) {
        let subject = "Request For Quote - \(product.name)"
        let body = "Hello,\n\nI'm interested in getting a quote for \(product.name).\n\nMy name is {name} from {company} and my number is {phone}."
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
                    // Hero Image
                    ZStack {
                        product.gradient
                            .frame(height: 240)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                        Image(product.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .shadow(radius: 10)
                    }
                    .padding(.horizontal)
                    
                    // Product Info
                    VStack(alignment: .leading, spacing: 16) {
                        Text(product.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        // Features Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Key Features")
                                .font(.headline)
                            
                            ForEach(product.features, id: \.self) { feature in
                                Label(
                                    title: { Text(feature) },
                                    icon: { Image(systemName: "checkmark.circle.fill") }
                                )
                                .foregroundColor(.secondary)
                            }
                        }
                        
                        // Specifications Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Specifications")
                                .font(.headline)
                            
                            ForEach(Array(product.specifications.keys.sorted()), id: \.self) { key in
                                HStack {
                                    Text(key)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(product.specifications[key] ?? "")
                                        .bold()
                                }
                            }
                        }
                        
                        if let pdfURL = product.pdfURL {
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
                                    composeEmail(for: product)
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
                        } else {
                            Button {
                                composeEmail(for: product)
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
                            .frame(height: 60)
                            .padding(.top)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(product.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = product.pdfURL {
                    NavigationView {
                        WebView(url: url)
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
}

// MARK: - Preview
struct ProductShowcaseView_Previews: PreviewProvider {
    static var previews: some View {
        ProductShowcaseView()
    }
}
