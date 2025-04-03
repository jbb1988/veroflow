import SwiftUI
import SceneKit

// Keep SphereComponent enum and SphereInfo struct at top level for accessibility
enum ModelComponent: String {
    case inlet = "Inlet"
    case outlet = "Outlet"
    case threeQuarterRegister = "Three_Quarter_Inch_Register" 
    case threeInchRegister = "Three_Inch_Register"
    case threeInchTurbine = "Three_Inch_Turbine"
    case pressureGauge = "Pressure_Gauge"
    case threeQuarterTurbine = "Three_Quarter_Inch_Turbine"   

    var description: String {
        switch self {
        case .inlet:
            return "Water inlet connection point"
        case .outlet:
            return "Water outlet connection point"
        case .threeQuarterRegister:
            return "Three Quarter inch register for flow measurement"
        case .threeInchRegister:
            return "Three inch register for flow measurement"
        case .threeInchTurbine:
            return "Three inch turbine flow meter"
        case .pressureGauge:
            return "Pressure measurement gauge"
        case .threeQuarterTurbine:
            return "Three Quarter inch turbine flow meter"
        }
    }
}

struct ModelView: View {
    @State private var activeLabel: SCNNode?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                let darkBlue = Color(red: 0.0, green: 0.094, blue: 0.188)
                let darkerBlue = Color(red: 0.0, green: 0.047, blue: 0.094)
                
                LinearGradient(gradient: Gradient(colors: [darkBlue, darkerBlue]),
                             startPoint: .topLeading,
                             endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                WeavePattern()
                    .opacity(0.15)
                    .ignoresSafeArea()
                
                VStack {
                    BasicSceneView(scene: makeScene(), activeLabel: $activeLabel)
                        .frame(width: geometry.size.width, height: geometry.size.height * 0.9)
                    
                    VStack(spacing: 4) {
                        Text("Pinch to Zoom In and Out")
                            .foregroundColor(.white)
                            .font(.caption)
                        Text("One-Finger to Rotate")
                            .foregroundColor(.white)
                            .font(.caption)
                        Text("Use Two-Fingers to Move Model")
                            .foregroundColor(.white)
                            .font(.caption)
                    }
                    .padding(.bottom, 20)
                }
                .edgesIgnoringSafeArea(.all)
            }
        }
    }
    
    private func makeScene() -> SCNScene {
        guard let scene = SCNScene(named: "veroflowmodel.usdz") else {
            print("DEBUG: Failed to load model file")
            return SCNScene()
        }
        
        scene.background.contents = UIColor.clear
        scene.lightingEnvironment.contents = UIColor.white
        scene.lightingEnvironment.intensity = 1.5
        
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.intensity = 800
        scene.rootNode.addChildNode(ambientLight)
        
        let directionalLight = SCNNode()
        directionalLight.light = SCNLight()
        directionalLight.light?.type = .directional
        directionalLight.light?.intensity = 500
        directionalLight.position = SCNVector3(x: 10, y: 10, z: 10)
        directionalLight.look(at: SCNVector3Zero)
        scene.rootNode.addChildNode(directionalLight)
        
        return scene
    }
}

struct BasicSceneView: UIViewRepresentable {
    let scene: SCNScene
    @Binding var activeLabel: SCNNode?
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView(frame: .zero)
        scnView.scene = scene
        scnView.backgroundColor = .clear
        scnView.isOpaque = false
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = false
        scnView.antialiasingMode = .multisampling4X
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        return scnView
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {}
    
    class Coordinator: NSObject {
        var parent: BasicSceneView
        
        init(_ parent: BasicSceneView) {
            self.parent = parent
        }
        
        @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
            guard let scnView = gestureRecognize.view as? SCNView else { return }

            parent.activeLabel?.removeFromParentNode()
            parent.activeLabel = nil

            let location = gestureRecognize.location(in: scnView)
            let hitResults = scnView.hitTest(location, options: [SCNHitTestOption.searchMode: SCNHitTestSearchMode.all.rawValue])

            if let result = hitResults.first {
                let detectedNodeName = result.node.name
                print("--- DEBUG: Tapped Node Name: \(detectedNodeName ?? "nil") ---")

                if let nodeName = detectedNodeName,
                   let component = ModelComponent(rawValue: nodeName) {

                    print("--- DEBUG: Matched Component: \(component) ---")

                    let position = SCNVector3(
                        result.worldCoordinates.x,
                        result.worldCoordinates.y + 0.3,
                        result.worldCoordinates.z
                    )

                    let labelText = nodeName 
                    let label = createLabel(text: labelText, at: position)
                    scnView.scene?.rootNode.addChildNode(label)
                    parent.activeLabel = label
                } else {
                    print("--- DEBUG: Tapped node '\(detectedNodeName ?? "nil")' does not correspond to a ModelComponent enum raw value. ---")
                }
            } else {
                 print("--- DEBUG: Tap did not hit any node. ---")
            }
        }

        private func createLabel(text: String, at position: SCNVector3) -> SCNNode {
            // --- Text Node Setup ---
            let textGeometry = SCNText(string: text, extrusionDepth: 0.01) // Keep slight extrusion
            // Consider a more modern font if available system-wide or bundled
            textGeometry.font = UIFont.systemFont(ofSize: 0.15, weight: .medium)
            textGeometry.alignmentMode = CATextLayerAlignmentMode.center.rawValue
            // Remove fixed container frame to let text determine its size
            // textGeometry.containerFrame = CGRect(origin: .zero, size: CGSize(width: 5, height: 0.5))
            textGeometry.isWrapped = false // Adjust if wrapping is needed for very long names

            let textMaterial = SCNMaterial()
            textMaterial.diffuse.contents = UIColor.white // Text color
            textGeometry.materials = [textMaterial]

            let textNode = SCNNode(geometry: textGeometry)
            // Calculate text size for background plane sizing
            let (minText, maxText) = textNode.boundingBox
            let textWidth = CGFloat(maxText.x - minText.x)
            let textHeight = CGFloat(maxText.y - minText.y)

            // Center the pivot of the text node itself
            let textCenterX = minText.x + 0.5 * (maxText.x - minText.x)
            let textCenterY = minText.y + 0.5 * (maxText.y - minText.y)
            textNode.pivot = SCNMatrix4MakeTranslation(textCenterX, textCenterY, 0)
             // Position text slightly in front of the background
            textNode.position.z = 0.02

            // --- Background Plane Setup ---
            let padding: CGFloat = 0.1 // Padding around the text
            let planeWidth = textWidth + 2 * padding
            let planeHeight = textHeight + 2 * padding
            let cornerRadius = planeHeight * 0.3 // Adjust for desired roundness

            let backgroundPlane = SCNPlane(width: planeWidth, height: planeHeight)
            let backgroundMaterial = SCNMaterial()
            // Use a semi-transparent dark color for the background
            backgroundMaterial.diffuse.contents = UIColor.black.withAlphaComponent(0.7)
            backgroundMaterial.lightingModel = .constant // Make it unlit
            backgroundMaterial.isDoubleSided = true // Visible from both sides
            // Use CALayer to generate a rounded rectangle image for the material contents
            let layer = CALayer()
            layer.frame = CGRect(x: 0, y: 0, width: planeWidth * 100, height: planeHeight * 100) // Increase resolution for sharpness
            layer.backgroundColor = UIColor.black.withAlphaComponent(0.7).cgColor
            layer.cornerRadius = cornerRadius * 100
            UIGraphicsBeginImageContext(layer.frame.size)
            if let context = UIGraphicsGetCurrentContext() {
                layer.render(in: context)
                let image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                backgroundMaterial.diffuse.contents = image
            } else {
                // Fallback to simple color if context fails
                 backgroundMaterial.diffuse.contents = UIColor.black.withAlphaComponent(0.7)
            }


            backgroundPlane.materials = [backgroundMaterial]

            let backgroundNode = SCNNode(geometry: backgroundPlane)
             // Place background slightly behind the text (at z=0 relative to parent)
            backgroundNode.position.z = 0

            // --- Parent Node Setup ---
            let parentNode = SCNNode()
            parentNode.addChildNode(backgroundNode)
            parentNode.addChildNode(textNode)

            // Apply position and constraints to the parent node
            parentNode.position = position
            parentNode.constraints = [SCNBillboardConstraint()] // Makes the whole group face the camera
            parentNode.renderingOrder = 100 // Render label group on top

            return parentNode
        }
    }
}

struct ModelView_Previews: PreviewProvider {
    static var previews: some View {
        ModelView()
    }
}
