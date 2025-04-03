import SwiftUI
import SceneKit

// ADD: SCNVector3 extension for normalization
extension SCNVector3 {
    /// Calculates the length (magnitude) of the vector.
    func length() -> Float {
        return sqrt(x*x + y*y + z*z)
    }

    /// Returns a normalized version of the vector (unit vector).
    /// Returns a zero vector if the original vector's length is zero.
    func normalized() -> SCNVector3 {
        let len = length()
        if len == 0 {
            return SCNVector3(0, 0, 0) // Or handle as appropriate, e.g., return self
        }
        return SCNVector3(x / len, y / len, z / len)
    }

    // Helper for subtraction (if needed, though SceneKit often uses simd types for math)
    static func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3Make(left.x - right.x, left.y - right.y, left.z - right.z)
    }

     // Helper for addition (if needed)
    static func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
    }

    // Helper for scalar multiplication (if needed)
    static func * (vector: SCNVector3, scalar: Float) -> SCNVector3 {
        return SCNVector3Make(vector.x * scalar, vector.y * scalar, vector.z * scalar)
    }
}

// Keep ModelComponent enum and SphereInfo struct at top level for accessibility
enum ModelComponent: String {
    case inlet = "Inlet"
    case outlet = "Outlet"
    case threeQuarterRegister = "Three_Quarter_Inch_Register"
    case threeInchRegister = "Three_Inch_Register"
    case threeInchTurbine = "Three_Inch_Turbine"
    case pressureGauge = "Pressure_Gauge"
    case threeQuarterTurbine = "Three_Quarter_Inch_Turbine"

    // description property remains the same...
    var description: String {
        switch self {
        case .inlet:
            return "Inlet"
        case .outlet:
            return "Outlet"
        case .threeQuarterRegister:
            return "3/4\" Register"
        case .threeInchRegister:
            return "Three Inch Register"
        case .threeInchTurbine:
            return "Three Inch Turbine"
        case .pressureGauge:
            return "Pressure Gauge"
        case .threeQuarterTurbine:
            return "3/4\" Turbine"
        }
    }
}

struct ModelView: View {
    @State private var activeLabel: SCNNode?
    @State private var resetCameraTrigger = UUID() // Keep this

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background setup remains the same...
                LinearGradient(gradient: Gradient(colors: [Color(red: 0.0, green: 0.094, blue: 0.188), Color(red: 0.0, green: 0.047, blue: 0.094)]),
                             startPoint: .topLeading,
                             endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                WeavePattern()
                    .opacity(0.15)
                    .ignoresSafeArea()

                // Main Content VStack (including SceneView and Instructions)
                VStack {
                    BasicSceneView(scene: makeScene(), activeLabel: $activeLabel, resetCameraTrigger: $resetCameraTrigger)
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
                    .padding(.bottom, 20) // Keep padding for instructions
                }

                // CHANGE: Reset Button styling to match app theme
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            resetCameraTrigger = UUID()
                        } label: {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 16))
                                Text("Reset")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(red: 0.0, green: 0.094, blue: 0.188))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
                .padding(.bottom, geometry.safeAreaInsets.bottom)
                .ignoresSafeArea(.keyboard)

            }
            // ADD: Ignore safe area for the entire ZStack if needed, so background fills edges
             .edgesIgnoringSafeArea(.all)
        }
    }

    // makeScene() function remains the same...
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

// BasicSceneView and its Coordinator remain the same as the previous correct version...
struct BasicSceneView: UIViewRepresentable {
    let scene: SCNScene
    @Binding var activeLabel: SCNNode?
    @Binding var resetCameraTrigger: UUID

    @State private var lastResetTriggerId: UUID? = nil // Initialize explicitly

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView(frame: .zero)
        scnView.scene = scene
        scnView.backgroundColor = .clear
        scnView.isOpaque = false
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = false // Keep false as we add lights manually
        scnView.antialiasingMode = .multisampling4X

        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)

        context.coordinator.scnView = scnView

        // Use DispatchQueue to ensure view is ready for camera state capture
        DispatchQueue.main.async {
            context.coordinator.captureInitialCameraState()
            // Initialize lastResetTriggerId here after coordinator is setup
             if self.lastResetTriggerId == nil { // Ensure it's only set once initially
                 self.lastResetTriggerId = self.resetCameraTrigger
             }
        }

        return scnView
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self) // Pass self to init
    }

     func updateUIView(_ uiView: SCNView, context: Context) {
         // Use optional binding and check for actual change
         if let currentTriggerId = lastResetTriggerId, resetCameraTrigger != currentTriggerId {
             print("--- DEBUG: Reset trigger detected in updateUIView. Old: \(currentTriggerId), New: \(resetCameraTrigger) ---")
             context.coordinator.resetCamera()
             // Update the last known ID immediately after processing
             // Use DispatchQueue to avoid modifying state during view update cycle
             DispatchQueue.main.async {
                 self.lastResetTriggerId = self.resetCameraTrigger
             }
         }
         // If lastResetTriggerId is still nil after makeUIView's async block,
         // it means the view might be updating before the initial capture finishes.
         // We rely on the initial value being set in makeUIView.
     }


    class Coordinator: NSObject {
        var parent: BasicSceneView
        weak var scnView: SCNView?
        var initialCameraState: (position: SCNVector3, orientation: SCNQuaternion)?

        // Correct initializer
        init(parent: BasicSceneView) {
             self.parent = parent
             super.init() // Call super.init()
         }


        func captureInitialCameraState() {
            guard initialCameraState == nil else { return } // Capture only once
            guard let view = scnView, let pov = view.pointOfView else {
                print("--- DEBUG: Could not capture initial camera state (view or pov missing), retrying... ---")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                    self?.captureInitialCameraState()
                }
                return
            }
            print("--- DEBUG: Capturing initial camera state - Pos: \(pov.position), Orient: \(pov.orientation) ---")
            initialCameraState = (position: pov.position, orientation: pov.orientation)

             // Ensure the parent's state reflecting the initial trigger ID is set
             // Needs to be dispatched to avoid modifying state during view updates if called from updateUIView path initially
             DispatchQueue.main.async {
                 if self.parent.lastResetTriggerId == nil {
                    self.parent.lastResetTriggerId = self.parent.resetCameraTrigger
                    print("--- DEBUG: Initial lastResetTriggerId set to: \(self.parent.lastResetTriggerId!)")
                 }
             }
        }

        func resetCamera() {
             guard let view = scnView, let pov = view.pointOfView, let initialState = initialCameraState else {
                print("--- DEBUG: Cannot reset camera - view, pov, or initial state missing ---")
                return
             }
            print("--- DEBUG: Resetting camera to - Pos: \(initialState.position), Orient: \(initialState.orientation) ---")

             // Animate the camera reset for a smoother transition
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.4 // Adjust duration as needed
            pov.position = initialState.position
            pov.orientation = initialState.orientation
            SCNTransaction.commit()
        }

        @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
             guard let scnView = gestureRecognize.view as? SCNView else { return }

             // Remove previous label
             parent.activeLabel?.removeFromParentNode()
             parent.activeLabel = nil

             let location = gestureRecognize.location(in: scnView)
             // Increase tap area slightly if needed, but usually default is fine
             let hitTestOptions: [SCNHitTestOption: Any] = [
                 .searchMode: SCNHitTestSearchMode.all.rawValue,
             ]
             let hitResults = scnView.hitTest(location, options: hitTestOptions)


            if let result = hitResults.first {
                let detectedNode = result.node // Work with the actual node
                let detectedNodeName = detectedNode.name // Get its name

                // Traverse up the hierarchy to find a named ancestor if the tapped node itself is unnamed
                var targetNode: SCNNode? = detectedNode
                var componentName: String? = detectedNodeName
                while componentName == nil, let parentNode = targetNode?.parent {
                    componentName = parentNode.name
                    targetNode = parentNode
                    if componentName != nil {
                         print("--- DEBUG: Found named ancestor: \(componentName!) ---")
                        break // Found a named node
                    }
                }


                print("--- DEBUG: Tapped Node Name (Effective): \(componentName ?? "nil") ---")

                if let nodeName = componentName, // Use the effective name
                   let component = ModelComponent(rawValue: nodeName) {

                    print("--- DEBUG: Matched Component: \(component) ---")

                     // Use the hit result's world coordinates for accurate positioning near the surface
                    let worldHitPoint = result.worldCoordinates
                    if let pov = scnView.pointOfView {
                        let cameraPosition = pov.worldPosition
                        // USE: Subtraction helper from extension
                        let directionToHit = worldHitPoint - cameraPosition
                         // CHANGE: Use the new normalized() method from the extension
                         let normDirection = directionToHit.normalized()
                         let offsetDistance: Float = 0.15
                         // USE: Addition and multiplication helpers from extension
                         let labelPosition = worldHitPoint + (normDirection * offsetDistance) + SCNVector3(0, 0.05, 0) // Simplified Y lift addition


                        let labelText = component.description
                        let label = createLabel(text: labelText, at: labelPosition) // Use adjusted position
                        scnView.scene?.rootNode.addChildNode(label)
                        parent.activeLabel = label
                    } else {
                         print("--- DEBUG: Could not get point of view for label offset calculation. ---")
                         // Fallback positioning if camera isn't available
                         let position = SCNVector3(
                            result.worldCoordinates.x,
                            result.worldCoordinates.y + 0.3, // Original Y offset fallback
                            result.worldCoordinates.z
                         )
                        let labelText = component.description
                        let label = createLabel(text: labelText, at: position)
                        scnView.scene?.rootNode.addChildNode(label)
                        parent.activeLabel = label
                    }
                } else {
                    print("--- DEBUG: Tapped node '\(componentName ?? "nil")' or its ancestors do not correspond to a ModelComponent enum raw value. ---")
                }
            } else {
                 print("--- DEBUG: Tap did not hit any node. ---")
            }
        }


        private func createLabel(text: String, at position: SCNVector3) -> SCNNode {
             // --- Text Node Setup ---
            let textGeometry = SCNText(string: text, extrusionDepth: 0.005)
            textGeometry.font = UIFont(name: "HelveticaNeue-Medium", size: 0.1) ?? UIFont.systemFont(ofSize: 0.1, weight: .medium)
            textGeometry.alignmentMode = CATextLayerAlignmentMode.center.rawValue
            textGeometry.isWrapped = false // Keep text on one line

            // CHANGE: Enhanced text material settings for maximum brightness
            let textMaterial = SCNMaterial()
            textMaterial.diffuse.contents = UIColor(white: 1.0, alpha: 1.0) // Pure white with full opacity
            textMaterial.emission.contents = UIColor.white // Add emission to make it glow
            textMaterial.lightingModel = .constant // Ignore scene lighting
            textMaterial.readsFromDepthBuffer = false
            textMaterial.writesToDepthBuffer = false // Prevent depth writing
            textGeometry.materials = [textMaterial]

            let textNode = SCNNode(geometry: textGeometry)
            // ADD: Ensure text renders at full brightness
            textNode.renderingOrder = 101 // Higher than background to ensure it renders on top

            let (minText, maxText) = textNode.boundingBox
            let textWidth = CGFloat(maxText.x - minText.x)
            let textHeight = CGFloat(maxText.y - minText.y)

            let textCenterX = minText.x + 0.5 * (maxText.x - minText.x)
            let textCenterY = minText.y + 0.5 * (maxText.y - minText.y)
            textNode.pivot = SCNMatrix4MakeTranslation(textCenterX, textCenterY, 0)
            textNode.position.z = 0.02

            // Background setup remains mostly the same, but ensure it doesn't interfere with text visibility
            let padding: CGFloat = 0.05
            let planeWidth = textWidth + 2 * padding
            let planeHeight = textHeight + 2 * padding
            let cornerRadius = planeHeight * 0.4

            let backgroundPlane = SCNPlane(width: planeWidth, height: planeHeight)
            let backgroundMaterial = SCNMaterial()
            backgroundMaterial.lightingModel = .constant
            backgroundMaterial.isDoubleSided = true
            backgroundMaterial.readsFromDepthBuffer = false
            backgroundMaterial.writesToDepthBuffer = false

            let layer = CALayer()
            let scaleFactor: CGFloat = 150
            layer.frame = CGRect(x: 0, y: 0, width: planeWidth * scaleFactor, height: planeHeight * scaleFactor)
            layer.backgroundColor = UIColor.black.withAlphaComponent(0.75).cgColor
            layer.cornerRadius = cornerRadius * scaleFactor
            UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, 0)
            if let context = UIGraphicsGetCurrentContext() {
                layer.render(in: context)
                let image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                backgroundMaterial.diffuse.contents = image
            } else {
                UIGraphicsEndImageContext()
                backgroundMaterial.diffuse.contents = UIColor.black.withAlphaComponent(0.75)
            }

            backgroundPlane.materials = [backgroundMaterial]
            let backgroundNode = SCNNode(geometry: backgroundPlane)
            backgroundNode.position.z = 0
            backgroundNode.renderingOrder = 100

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
