import SwiftUI
import ARKit

struct ARMeterOverlayView: UIViewRepresentable {
    // Array of bounding boxes from OCR, each with text, bounding box, and confidence
    var boundingBoxes: [(text: String, boundingBox: CGRect, confidence: Float)]
    
    func makeUIView(context: Context) -> ARSCNView {
        let sceneView = ARSCNView()
        sceneView.delegate = context.coordinator
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
        return sceneView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        // Update to clear out old nodes first
        uiView.scene.rootNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
        
        // Add new overlay nodes based on boundingBoxes data
        for box in boundingBoxes {
            let overlayNode = createOverlayNode(for: box, in: uiView)
            uiView.scene.rootNode.addChildNode(overlayNode)
        }
        
        // Force a render update
        uiView.setNeedsDisplay()
    }
    
    private func createOverlayNode(for box: (text: String, boundingBox: CGRect, confidence: Float), in view: ARSCNView) -> SCNNode {
        let node = SCNNode()
        node.name = "OCROverlay"
        // Create a plane geometry to represent the bounding box (using the bounding box dimensions)
        let plane = SCNPlane(width: box.boundingBox.width, height: box.boundingBox.height)
        plane.firstMaterial?.diffuse.contents = UIColor.red.withAlphaComponent(0.3)
        node.geometry = plane
        
        // Convert 2D bounding box center to a 3D world coordinate via a hit test (placeholder conversion)
        let midX = box.boundingBox.midX
        let midY = box.boundingBox.midY
        let screenPoint = CGPoint(x: midX * view.bounds.width, y: midY * view.bounds.height)
        let hitTestResults = view.hitTest(screenPoint, types: [.featurePoint])
        if let result = hitTestResults.first {
            let worldTransform = result.worldTransform
            node.position = SCNVector3(worldTransform.columns.3.x,
                                       worldTransform.columns.3.y,
                                       worldTransform.columns.3.z)
        } else {
            node.position = SCNVector3(0, 0, -1) // Default fallback position
        }
        
        return node
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, ARSCNViewDelegate {
        var parent: ARMeterOverlayView
        init(_ parent: ARMeterOverlayView) {
            self.parent = parent
        }
    }
}

struct ARMeterOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        ARMeterOverlayView(boundingBoxes: [
            (text: "123.45", boundingBox: CGRect(x: 0.3, y: 0.3, width: 0.2, height: 0.1), confidence: 0.95)
        ])
        .edgesIgnoringSafeArea(.all)
    }
}
