import SwiftUI
import SceneKit

struct ModelView: View {
    var body: some View {
        SceneView(scene: makeScene(), options: [.allowsCameraControl])
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                    WeavePattern()
                }
                .ignoresSafeArea()
            )
    }
    
    private func makeScene() -> SCNScene {
        let scene = SCNScene()
        
        // Create and add a camera
        let camera = SCNNode()
        camera.camera = SCNCamera()
        camera.position = SCNVector3(0, 0, 15)
        scene.rootNode.addChildNode(camera)
        
        // Create and add an ambient light
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.intensity = 1000
        scene.rootNode.addChildNode(ambientLight)
        
        // Create and add a directional light
        let directionalLight = SCNNode()
        directionalLight.light = SCNLight()
        directionalLight.light?.type = .directional
        directionalLight.light?.intensity = 1000
        directionalLight.position = SCNVector3(5, 5, 5)
        scene.rootNode.addChildNode(directionalLight)
        
        // Try to load the model
        if let modelScene = SCNScene(named: "veroflowmodel.usdz") {
            scene.rootNode.addChildNode(modelScene.rootNode)
        }
        
        return scene
    }
}

#Preview {
    ModelView()
}
