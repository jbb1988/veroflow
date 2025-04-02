import SwiftUI
import MessageUI
import WebKit

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

struct ShopView: View {
    @State private var showingDetail = false
    @State private var showingStrainerDetail = false
    @State private var showingValveKeyDetail = false
    @State private var showingRCMDetail = false
    @State private var showingDrillTapsDetail = false
    @State private var showingZincCapsDetail = false
    @State private var showingThrustBusterDetail = false
    
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
                        .fixedSize(horizontal: false, vertical: true)

                    Text("From our NSF-61 Certified Test Port Spools and Strainers to our valve keys, zinc caps, drill taps and beyond—MARS offers a comprehensive range of water infrastructure solutions designed with industry expertise and manufactured to the highest standards.")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(24)
                .cardStyle(color: .blue)
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
                            FeatureItem(text: "NSF61 Certified")
                            FeatureItem(text: "Custom Sizes")
                            FeatureItem(text: "150 PSI Rated")
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
                
                // Strainer Card
                VStack(spacing: 0) {
                    // Update image section
                    ZStack {
                        HStack(spacing: 20) {
                            Image("zstrainer")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 160)
                            
                            Image("nsf")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                            
                            Image("nlstrainer")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 160)
                        }
                        .padding(.top)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Z-Plate & No-Lead Strainers")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("NSF61 Certified strainers designed for optimal flow performance")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .lineLimit(2)
                        
                        HStack(spacing: 24) {
                            FeatureItem(text: "NSF61 Certified")
                            FeatureItem(text: "Optimized Flow")
                            FeatureItem(text: "AWWA Standards")
                        }
                        .padding(.top, 8)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(
                    ZStack {
                        Color(red: 21/255, green: 21/255, blue: 21/255)
                        
                        // Blue glow behind images
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 200, height: 200)
                            .blur(radius: 60)
                            .offset(y: -30)
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .onTapGesture {
                    showingStrainerDetail = true
                }
                .shadow(color: .blue.opacity(0.3), radius: 20, x: 0, y: 10)
                .padding(.horizontal)
                
                // Valve Key Card
                VStack(spacing: 0) {
                    ZStack {
                        Image("key")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .padding(.top)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Super Tuff Adjustable Valve Keys")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Adjustable valve keys designed for operational efficiency")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .lineLimit(2)
                        
                        HStack(spacing: 24) {
                            FeatureItem(text: "2-3 way Keys")
                            FeatureItem(text: "18\" Adjustable")
                            FeatureItem(text: "Curb Stop Key")
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
                    showingValveKeyDetail = true
                }
                .shadow(color: .blue.opacity(0.3), radius: 20, x: 0, y: 10)
                .padding(.horizontal)
                
                // RCM Card
                VStack(spacing: 0) {
                    ZStack(alignment: .center) {
                        Image("rcm")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .padding(.top)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Remote Counter Module")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Universal remote display for smart meter reading")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .lineLimit(2)
                        
                        HStack(spacing: 24) {
                            FeatureItem(text: "CA Certified")
                            FeatureItem(text: "LCD Display")
                        }
                        .padding(.top, 8)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(
                    ZStack {
                        Color(red: 21/255, green: 21/255, blue: 21/255)
                        
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 200, height: 200)
                            .blur(radius: 60)
                            .offset(y: -30)
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .onTapGesture {
                    showingRCMDetail = true
                }
                .shadow(color: .blue.opacity(0.3), radius: 20, x: 0, y: 10)
                .padding(.horizontal)
                
                // Drill Taps Card
                VStack(spacing: 0) {
                    // Remove NSF image, keep just the drill taps image
                    ZStack(alignment: .center) {
                        Image("taps")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .padding(.top)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Super Tuff Drill Taps")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Experience smoother drilling operations with MARS Super Tuff Drill Taps")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .lineLimit(2)
                        
                        // Simplify to just two feature items
                        HStack(spacing: 24) {
                            FeatureItem(text: "30% Less Drag")
                            FeatureItem(text: "High Grade Steel")
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
                    showingDrillTapsDetail = true
                }
                .shadow(color: .blue.opacity(0.3), radius: 20, x: 0, y: 10)
                .padding(.horizontal)
                
                // Zinc Caps Card
                VStack(spacing: 0) {
                    ZStack(alignment: .center) {
                        Image("caps")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .padding(.top)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Zinc Anode Caps")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("MARS Zinc Anode Caps provide essential corrosion protection for buried and submerged pipeline fittings. Using advanced electrochemical technology, these caps act as sacrificial anodes, effectively preserving your water infrastructure investments and preventing costly repairs.")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .lineLimit(2)
                        
                        HStack(spacing: 24) {
                            FeatureItem(text: "High Electrical Potential Protection")
                            FeatureItem(text: "5,000-Hour Salt Water Testing")
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
                    showingZincCapsDetail = true
                }
                .shadow(color: .blue.opacity(0.3), radius: 20, x: 0, y: 10)
                .padding(.horizontal)
                
                // ThrustBuster Card
                VStack(spacing: 0) {
                    ZStack(alignment: .center) {
                        Image("thrust")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .padding(.top)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("ThrustBuster Diffuser")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("The MARS ThrustBuster hose diffuser stands out as a critical safety tool for water meter field testers. Designed to mitigate the dangers associated with high-pressure discharge of water, it effectively eliminates hazardous thrust of loose hoses while protecting both operators and property.")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .lineLimit(2)
                        
                        HStack(spacing: 24) {
                            FeatureItem(text: "Dual Port Safety Design")
                            FeatureItem(text: "Injury Prevention System")
                            FeatureItem(text: "Erosion Control Technology")
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
                    showingThrustBusterDetail = true
                }
                .shadow(color: .blue.opacity(0.3), radius: 20, x: 0, y: 10)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.vertical)
        }
        .background(
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "001830"),
                        Color(hex: "000C18")
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .overlay(WeavePattern()) // Using centralized WeavePattern
                .ignoresSafeArea()
            }
        )
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingDetail) {
            TestPortSpoolsDetailView()
        }
        .sheet(isPresented: $showingStrainerDetail) {
            StrainerDetailView()
        }
        .sheet(isPresented: $showingValveKeyDetail) {
            ValveKeyDetailView()
        }
        .sheet(isPresented: $showingRCMDetail) {
            RCMDetailView()
        }
        .sheet(isPresented: $showingDrillTapsDetail) {
            DrillTapsDetailView()
        }
        .sheet(isPresented: $showingZincCapsDetail) {
            ZincCapsDetailView()
        }
        .sheet(isPresented: $showingThrustBusterDetail) {
            ThrustBusterDetailView()
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
                        Color.clear.frame(height: 8) // CHANGE: Reduced from default/arbitrary value to 8
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
                                    icon: { Image(systemName: "checkmark.circle.fill").foregroundColor(.green) }
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
                    WebView(url: URL(string: "https://www.marswater.com/?wpdmdl=986")!)
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

struct StrainerDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false
    
    func composeEmail() {
        let subject = "Request For Quote - Z-Plate & No-Lead Strainers"
        let body = "Hello,\n\nI'm interested in getting a quote for Z-Plate & No-Lead Strainers.\n\nMy name is {name} from {company} and my number is {phone}."
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
                VStack(spacing: 20) {
                    // Hero section
                    ZStack {
                        LinearGradient(
                            colors: [.blue, .blue.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(height: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                        HStack(spacing: 20) {
                            Image("zstrainer")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 180)
                            
                            Image("nlstrainer")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 180)
                        }
                        .shadow(radius: 10)
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Safeguarding water infrastructure with advanced strainer technology, our NSF61 Certified Z-Plate and No-Lead Bronze Strainers ensure optimal flow performance while protecting valuable water meters from debris and foreign matter.")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        // Features section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Key Features")
                                .font(.headline)
                            
                            ForEach([
                                "Optimized Flow Performance",
                                "Minimal Pressure Loss",
                                "Easy In-Line Service",
                                "AWWA Standards Compliant",
                                "Multiple Size Options"
                            ], id: \.self) { feature in
                                Label(
                                    title: { Text(feature) },
                                    icon: { Image(systemName: "checkmark.circle.fill").foregroundColor(.green) }
                                )
                                .foregroundColor(.secondary)
                            }
                        }
                        
                        // Specifications section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Specifications")
                                .font(.headline)
                            
                            let specs = [
                                "Material": "Epoxy-coated steel; No-Lead Bronze",
                                "Operating Pressure": "Up to 150 PSI",
                                "Temperature": "Up to 120°F (Bronze: 300°F)",
                                "Screen": "304 Stainless Steel",
                                "Sizes Available": "Steel: 1.5-30 inches, Bronze: 1.5-6 inches"
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
            .navigationTitle("Z-Plate & No-Lead Strainers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                NavigationView {
                    WebView(url: URL(string: "https://www.marswater.com/?wpdmdl=1003")!)
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

struct ValveKeyDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false
    
    func composeEmail() {
        let subject = "Request For Quote - Super Tuff Adjustable Valve Keys"
        let body = "Hello,\n\nI'm interested in getting a quote for Super Tuff Adjustable Valve Keys.\n\nMy name is {name} from {company} and my number is {phone}."
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
                    // Hero section
                    ZStack {
                        LinearGradient(
                            colors: [.blue, .blue.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(height: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                        Image("key")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .shadow(radius: 10)
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("The MARS 'Super Tuff' Valve Keys redefine operational efficiency with their fully adjustable design in 18\" increments. Field crews benefit from unparalleled versatility, eliminating the need to transport multiple keys and reducing the risk of mismatched sizes for tasks.")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        // Features section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Key Features")
                                .font(.headline)
                            
                            ForEach([
                                "2-way and 3-way Configurations",
                                "Adjustable in 18\" Increments",
                                "Built-in Curb Stop Key",
                                "Compact Storage Design",
                                "High-yield Steel Construction"
                            ], id: \.self) { feature in
                                Label(
                                    title: { Text(feature) },
                                    icon: { Image(systemName: "checkmark.circle.fill").foregroundColor(.green) }
                                )
                                .foregroundColor(.secondary)
                            }
                        }
                        
                        // Specifications section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Specifications")
                                .font(.headline)
                            
                            let specs = [
                                "Material": "High-yield cold rolled steel",
                                "2-way Key Range": "3.5' to 6.5' or 5.0' to 9.5'",
                                "3-way Key Range": "3.5' to 6.5' or 5.0' to 9.5'",
                                "T-Handle Range": "5.0' to 9.5'",
                                "Operating Nut": "Standard 2-inch"
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
            .navigationTitle("Super Tuff Valve Keys")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                NavigationView {
                    WebView(url: URL(string: "https://www.marswater.com/?wpdmdl=988")!)
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

struct DrillTapsDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false
    
    func composeEmail() {
        let subject = "Request For Quote - Super Tuff Drill Taps"
        let body = "Hello,\n\nI'm interested in getting a quote for Super Tuff Drill Taps.\n\nMy name is {name} from {company} and my number is {phone}."
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
                    // Hero section
                    ZStack {
                        LinearGradient(
                            colors: [.blue, .blue.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(height: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                        Image("taps")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .shadow(radius: 10)
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Experience smoother drilling operations with MARS 'Super Tuff' Drill Taps")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        // Features section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Key Features")
                                .font(.headline)
                            
                            ForEach([
                                "30% Less Drilling Resistance",
                                "High-Quality Forged Steel",
                                "Nitride Finish Protection",
                                "Five Threading Flutes",
                                "Easy Resharpening Design"
                            ], id: \.self) { feature in
                                Label(
                                    title: { Text(feature) },
                                    icon: { Image(systemName: "checkmark.circle.fill").foregroundColor(.green) }
                                )
                                .foregroundColor(.secondary)
                            }
                        }
                        
                        // Specifications section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Specifications")
                                .font(.headline)
                            
                            let specs = [
                                "Material": "High-speed forged steel",
                                "Finish": "Nitride coating",
                                "Handle": "Ergonomic polypropylene",
                                "Threading": "Five-flute design",
                                "Available Sizes": "3/4\", 1.0\", 1.5\", 2.0\""
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
            .navigationTitle("Super Tuff Drill Taps")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                NavigationView {
                    WebView(url: URL(string: "https://www.marswater.com/?wpdmdl=984")!)
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

struct RCMDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false
    
    func composeEmail() {
        let subject = "Request For Quote - RCM-150 Remote Counter Module"
        let body = "Hello,\n\nI'm interested in getting a quote for the RCM-150 Remote Counter Module.\n\nMy name is {name} from {company} and my number is {phone}."
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
                    ZStack {
                        LinearGradient(
                            colors: [.blue, .blue.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(height: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                        Image("rcm")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .shadow(radius: 10)
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("The RCM-150 is a cutting-edge remote primary display designed to interface with all pulse metering devices. Available in both single and dual register configurations, it supports monitoring for both hot (red) and cold (blue) water usage, and Natural Gas (green) ensuring versatility across different utilities. The RCM-100 is California State certified for water and natural gas applications, adhering to rigorous standards.")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Key Features")
                                .font(.headline)
                            
                            ForEach([
                                "Universal Meter Compatibility",
                                "8-digit LCD Display",
                                "California State Certified",
                                "AMR System Ready with Pulse Output",
                                "Security-sealed Setup Connector",
                                "Field-replaceable Battery",
                                "Tamper Detection Indicators"
                            ], id: \.self) { feature in
                                Label(
                                    title: { Text(feature) },
                                    icon: { Image(systemName: "checkmark.circle.fill").foregroundColor(.green) }
                                )
                                .foregroundColor(.secondary)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Construction")
                                .font(.headline)
                            
                            let specs = [
                                "Mounting": "Water-resistant wall mount",
                                "Material": "Clear poly-carbonate cover",
                                "Protection": "Conformal coated circuit board",
                                "Connectivity": "Spring terminal blocks",
                                "Size": "2.5\" x 4.5\" x 1.5\"",
                                "Weight": "7.5oz"
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
            .navigationTitle("RCM-150 Remote Counter Module")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                NavigationView {
                    WebView(url: URL(string: "https://www.marswater.com/?wpdmdl=1011")!)
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

struct ZincCapsDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false
    
    func composeEmail() {
        let subject = "Request For Quote - Zinc Anode Caps"
        let body = "Hello,\n\nI'm interested in getting a quote for Zinc Anode Caps.\n\nMy name is {name} from {company} and my number is {phone}."
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
                    // Hero section
                    ZStack {
                        LinearGradient(
                            colors: [.blue, .blue.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(height: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                        Image("caps")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .shadow(radius: 10)
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("MARS Zinc Anode Caps provide essential corrosion protection for buried and submerged pipeline fittings. Using advanced electrochemical technology, these caps act as sacrificial anodes, effectively preserving your water infrastructure investments and preventing costly repairs.")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Key Features")
                                .font(.headline)
                            
                            ForEach([
                                "High Electrical Potential Protection",
                                "5,000-Hour Salt Water Testing",
                                "Multiple Size Configurations",
                                "Easy Installation",
                                "Long-Term Cost Savings"
                            ], id: \.self) { feature in
                                Label(
                                    title: { Text(feature) },
                                    icon: { Image(systemName: "checkmark.circle.fill").foregroundColor(.green) }
                                )
                                .foregroundColor(.secondary)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Available Sizes")
                                .font(.headline)
                            
                            let specs = [
                                "2.5 oz Hex": "1/2\", 3/8\", 5/8\", 3/4\"",
                                "2.5 oz Tapered": "5/16\", 3/8\", 1/2\", 7/16\"",
                                "6 oz Hexagon": "1/2\", 5/8\", 3/4\", 7/8\", 1\", 1 1/8\"",
                                "14 oz Hexagon": "1 1/8\", 1 1/4\", 1 1/2\", 1 3/4\""
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
            .navigationTitle("Zinc Anode Caps")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                NavigationView {
                    WebView(url: URL(string: "https://www.marswater.com/?wpdmdl=995")!)
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

struct ThrustBusterDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false
    
    func composeEmail() {
        let subject = "Request For Quote - ThrustBuster Diffuser"
        let body = "Hello,\n\nI'm interested in getting a quote for the ThrustBuster Diffuser.\n\nMy name is {name} from {company} and my number is {phone}."
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
                    ZStack {
                        LinearGradient(
                            colors: [.blue, .blue.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(height: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                        Image("thrust")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .shadow(radius: 10)
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("The MARS ThrustBuster hose diffuser stands out as a critical safety tool for water meter field testers. Designed to mitigate the dangers associated with high-pressure discharge of water, it effectively eliminates hazardous thrust of loose hoses while protecting both operators and property.")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Key Features")
                                .font(.headline)
                            
                            ForEach([
                                "Dual Port Design",
                                "VF-4 Compatible",
                                "Erosion Control"
                            ], id: \.self) { feature in
                                Label(
                                    title: { Text(feature) },
                                    icon: { Image(systemName: "checkmark.circle.fill").foregroundColor(.green) }
                                )
                                .foregroundColor(.secondary)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Specifications")
                                .font(.headline)
                            
                            let specs = [
                                "Material": "Schedule 40 Steel",
                                "Connection": "2.5° NST Bronze Female",
                                "Coating": "Type II Fusion Nylon",
                                "Weight": "21 lbs",
                                "Design": "30° Hydraulic Model"
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
            .navigationTitle("ThrustBuster Diffuser")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                NavigationView {
                    WebView(url: URL(string: "https://www.marswater.com/?wpdmdl=987")!)
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
