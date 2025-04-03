import SwiftUI
import SceneKit

// Keep SphereComponent enum and SphereInfo struct at top level for accessibility
enum ModelComponent: String {
    case inlet = "Inlet"
    case outlet = "Outlet"
    case threeQuarterRegister = "Three Quarter Register"
    case threeInchRegister = "Three Inch Register"
    case threeInchTurbine = "Three Inch Turbine"
    case pressureGauge = "Pressure Gauge"
    case threeQuarterTurbine = "Three Quarter Turbine"
    
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
        scene.lightingEnvironment.intensity = 2.0
        
        let camera = SCNNode()
        camera.camera = SCNCamera()
        camera.position = SCNVector3(0, 0, 15)
        scene.rootNode.addChildNode(camera)
        
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.intensity = 1000
        scene.rootNode.addChildNode(ambientLight)
        
        return scene
    }
    
    private func createLabel(text: String, at position: SCNVector3) -> SCNNode {
        let textGeometry = SCNText(string: text, extrusionDepth: 0)
        textGeometry.font = UIFont.systemFont(ofSize: 0.3)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.white
        
        let textNode = SCNNode(geometry: textGeometry)
        textNode.position = position
        textNode.constraints = [SCNBillboardConstraint()]
        return textNode
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
            
            // Remove previous label if it exists
            parent.activeLabel?.removeFromParentNode()
            parent.activeLabel = nil
            
            let location = gestureRecognize.location(in: scnView)
            let hitResults = scnView.hitTest(location, options: [:])
            
            if let result = hitResults.first {
                let position = SCNVector3(
                    result.worldCoordinates.x,
                    result.worldCoordinates.y + 0.5, // Offset above the tapped point
                    result.worldCoordinates.z
                )
                
                let description = "Part Description" // Replace with actual part description based on hit test
                let label = createLabel(text: description, at: position)
                scnView.scene?.rootNode.addChildNode(label)
                parent.activeLabel = label
            }
        }
        
        private func createLabel(text: String, at position: SCNVector3) -> SCNNode {
            let textGeometry = SCNText(string: text, extrusionDepth: 0)
            textGeometry.font = UIFont.systemFont(ofSize: 0.3)
            textGeometry.firstMaterial?.diffuse.contents = UIColor.white
            
            let textNode = SCNNode(geometry: textGeometry)
            textNode.position = position
            textNode.constraints = [SCNBillboardConstraint()]
            return textNode
        }
    }
}

struct ModelView_Previews: PreviewProvider {
    static var previews: some View {
        ModelView()
    }
}
