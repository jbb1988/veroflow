import SwiftUI

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
        imageName: "vf1-product", // You'll need to add this image to assets
        gradient: LinearGradient(
            colors: [Color.blue, Color.blue.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        pdfURL: URL(string: "https://marswater.com/vf1-sheet.pdf") // Replace with actual URL
    ),
    VEROflowProduct(
        name: "VEROflow-4 Touch",
        subtitle: "Mobile Meter Testing System",
        description: "The VEROflow-4 Touch introduces a breakthrough in field meter testing with advanced features and a user-friendly touchscreen interface for unmatched accuracy.",
        features: [
            "Accurate To +/- 0.5%",
            "16-Point Calibration Linearization",
            "+/- 0.1% Repeatable Accuracy",
            "Only NIST Traceable Field Test Unit",
            "Test Meters up to 8\"",
            "NEMA 4X Explosion Proof Enclosure"
        ],
        specifications: [
            "Weight": "65 lbs",
            "Min Flow": "0.75 GPM",
            "Max Flow": "650 GPM",
            "Temperature Range": "32° F To 120° F",
            "Max Pressure": "300 PSI"
        ],
        imageName: "vf4-product", // You'll need to add this image to assets
        gradient: LinearGradient(
            colors: [Color.red, Color.blue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        pdfURL: URL(string: "https://marswater.com/vf4-sheet.pdf") // Replace with actual URL
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
        imageName: "vf10-product", // You'll need to add this image to assets
        gradient: LinearGradient(
            colors: [Color.purple, Color.blue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        pdfURL: URL(string: "https://marswater.com/vf10-sheet.pdf") // Replace with actual URL
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
                Text("VEROflow Product Line")
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
            // Product Image
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
            
            // Key Features Preview
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
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
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
                            Button {
                                showShareSheet = true
                            } label: {
                                Label("Download Product Sheet", systemImage: "arrow.down.doc")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .tint(.blue)
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
                    ShareSheet(activityItems: [url])
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
