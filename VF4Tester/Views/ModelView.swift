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

    // CHANGE: Update descriptions to exact requested strings
    var description: String {
        switch self {
        case .inlet:
            return "Inlet" // Keep original node name for others, or update as needed
        case .outlet:
            return "Outlet" // Keep original node name for others, or update as needed
        case .threeQuarterRegister:
            return "3/4\" Register" // Updated exact name
        case .threeInchRegister:
            return "Three Inch Register" // Keep original node name for others, or update as needed
        case .threeInchTurbine:
            return "Three Inch Turbine" // Keep original node name for others, or update as needed
        case .pressureGauge:
            return "Pressure Gauge" // Keep original node name for others, or update as needed
        case .threeQuarterTurbine:
            return "3/4\" Turbine" // Updated exact name
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
                        result.worldCoordinates.y + 0.3, // Adjust Y offset as needed
                        result.worldCoordinates.z
                    )

                    // CHANGE: Use the component's description property for the label text
                    let labelText = component.description // Use the updated description here
                    let label = createLabel(text: labelText, at: position)
                    scnView.scene?.rootNode.addChildNode(label)
                    parent.activeLabel = label
                } else {
                    print("--- DEBUG: Tapped node '\(detectedNodeName ?? "nil")' does not correspond to a ModelComponent enum raw value. ---")
                    // Optional: If you want to show labels for non-matching nodes too, replace underscores here as well
                    // if let nodeName = detectedNodeName {
                    //     let position = SCNVector3(result.worldCoordinates.x, result.worldCoordinates.y + 0.3, result.worldCoordinates.z)
                    //     let labelText = nodeName.replacingOccurrences(of: "_", with: " ") // Keep original logic for non-enum nodes if needed
                    //     let label = createLabel(text: labelText, at: position)
                    //     scnView.scene?.rootNode.addChildNode(label)
                    //     parent.activeLabel = label
                    // }
                }
            } else {
                 print("--- DEBUG: Tap did not hit any node. ---")
            }
        }

        private func createLabel(text: String, at position: SCNVector3) -> SCNNode {
             // --- Text Node Setup ---
            let textGeometry = SCNText(string: text, extrusionDepth: 0.01)
            textGeometry.font = UIFont(name: "HelveticaNeue-Medium", size: 0.15) ?? UIFont.systemFont(ofSize: 0.15, weight: .medium) // Fallback to system font
            textGeometry.alignmentMode = CATextLayerAlignmentMode.center.rawValue
            textGeometry.isWrapped = false

            let textMaterial = SCNMaterial()
            textMaterial.diffuse.contents = UIColor.white
            textGeometry.materials = [textMaterial]

            let textNode = SCNNode(geometry: textGeometry)
            let (minText, maxText) = textNode.boundingBox
            let textWidth = CGFloat(maxText.x - minText.x)
            let textHeight = CGFloat(maxText.y - minText.y)

            let textCenterX = minText.x + 0.5 * (maxText.x - minText.x)
            let textCenterY = minText.y + 0.5 * (maxText.y - minText.y)
            textNode.pivot = SCNMatrix4MakeTranslation(textCenterX, textCenterY, 0)
            textNode.position.z = 0.02

            // --- Background Plane Setup ---
            let padding: CGFloat = 0.1
            let planeWidth = textWidth + 2 * padding
            let planeHeight = textHeight + 2 * padding
            let cornerRadius = planeHeight * 0.3

            let backgroundPlane = SCNPlane(width: planeWidth, height: planeHeight)
            let backgroundMaterial = SCNMaterial()
            backgroundMaterial.lightingModel = .constant
            backgroundMaterial.isDoubleSided = true

            let layer = CALayer()
            layer.frame = CGRect(x: 0, y: 0, width: planeWidth * 100, height: planeHeight * 100)
            layer.backgroundColor = UIColor.black.withAlphaComponent(0.7).cgColor
            layer.cornerRadius = cornerRadius * 100
            UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, 0) // Use options for scale
            if let context = UIGraphicsGetCurrentContext() {
                layer.render(in: context)
                let image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                backgroundMaterial.diffuse.contents = image
            } else {
                UIGraphicsEndImageContext() // Ensure context is ended even if it fails
                backgroundMaterial.diffuse.contents = UIColor.black.withAlphaComponent(0.7)
            }

            backgroundPlane.materials = [backgroundMaterial]
            let backgroundNode = SCNNode(geometry: backgroundPlane)
            backgroundNode.position.z = 0

            // --- Parent Node Setup ---
            let parentNode = SCNNode()
            parentNode.addChildNode(backgroundNode)
            parentNode.addChildNode(textNode)

            parentNode.position = position
            parentNode.constraints = [SCNBillboardConstraint()]
            parentNode.renderingOrder = 100

            return parentNode
        }
    }
}

struct ModelView_Previews: PreviewProvider {
    static var previews: some View {
        ModelView()
    }
}
