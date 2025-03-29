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
        subtitle: "Precision Calibration & Rapid Turnaround",
        description: "MARS VEROflow Calibration delivers expert calibration services designed to enhance measurement accuracy and extend equipment life for your VF-1 and VF-4 field test units. Our comprehensive service includes a 16-point calibration linearization, detailed equipment assessments, and necessary battery replacement & repair—all executed by expert technicians using NIST-traceable procedures for minimal downtime and rapid turnaround. Also, companion app included for VF-4 units.",
        features: [
            "16-Point Calibration",
            "Expert Technicians",
            "Customer-Centric Service",
            "NIST Traceable",
            "Battery Replacement & Repair",
            "Rapid Turnaround"
        ],
        specifications: [
            "Service Type": "Full Calibration & Maintenance",
            "Supported Models": "VF-1 and VF-4",
            "Turnaround": "Rapid",
            "Calibration Standard": "NIST Traceable",
            "Additional Repairs": "Quoted Separately"
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
            "±1.5% Accuracy",
            "Locate Pressure",
            "Solve Complaints",
            "Precision Microprocessor Test Unit",
            "Lightweight & Portable Field Testing"
        ],
        specifications: [
            "Flow Range": "3 to 25 GPM",
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
            "Touchscreen UI",
            "Precision Flow",
            "Companion App",
            "Automatic Flow Rate Detection",
            "Temperature Compensation",
            "NEMA 4X Water Resistant"
        ],
        specifications: [
            "Flow Range": "0.75 to 650 GPM",
            "Accuracy": "±0.5%",
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
            "2\"-10\" Meters",
            "22-Pt Linearization",
            "0.1% Accuracy",
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
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "001830"),
                    Color(hex: "000C18")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay(WeavePattern())
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    Spacer()
                        .frame(height: 40)
                    // Header
                    Text("")
                        .font(.system(size: 28, weight: .bold))
                        .padding(.top, 8)
                    
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
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(product.features.prefix(3), id: \.self) { feature in
                        Label(
                            title: { Text(feature) },
                            icon: { Image(systemName: "checkmark.circle.fill").foregroundColor(.blue) }
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
                                    icon: { Image(systemName: "checkmark.circle.fill").foregroundColor(.green) }
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
