import SwiftUI
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    @Binding var isShowing: Bool
    var onImageCaptured: (UIImage) -> Void
    var onError: (Error) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        print("Creating UIImagePickerController...")
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.allowsEditing = false
        
        // Check camera availability
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            onError(NSError(domain: "CameraError", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Camera is not available"]))
            isShowing = false
        }
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraView
        var capturedImage: UIImage?
        var previewController: UIViewController?
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                 didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            print("Image picker finished with info")
            
            if let image = info[.originalImage] as? UIImage {
                self.capturedImage = image
                
                // Create and present preview controller
                let previewVC = UIViewController()
                previewVC.view.backgroundColor = .black
                
                // Add image view
                let imageView = UIImageView(frame: previewVC.view.bounds)
                imageView.contentMode = .scaleAspectFit
                imageView.image = image
                imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                previewVC.view.addSubview(imageView)
                
                // Add buttons container
                let buttonsView = UIView(frame: CGRect(x: 0, y: previewVC.view.bounds.height - 100,
                                                    width: previewVC.view.bounds.width, height: 80))
                buttonsView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
                
                // Use Photo button
                let useButton = UIButton(frame: CGRect(x: buttonsView.bounds.width/2 - 130,
                                                     y: 20, width: 120, height: 40))
                useButton.setTitle("Use Photo", for: .normal)
                useButton.backgroundColor = .systemBlue
                useButton.layer.cornerRadius = 8
                useButton.addTarget(self, action: #selector(usePhotoTapped), for: .touchUpInside)
                
                // Retake button
                let retakeButton = UIButton(frame: CGRect(x: buttonsView.bounds.width/2 + 10,
                                                       y: 20, width: 120, height: 40))
                retakeButton.setTitle("Retake", for: .normal)
                retakeButton.backgroundColor = .systemRed
                retakeButton.layer.cornerRadius = 8
                retakeButton.addTarget(self, action: #selector(retakePhotoTapped), for: .touchUpInside)
                
                buttonsView.addSubview(useButton)
                buttonsView.addSubview(retakeButton)
                previewVC.view.addSubview(buttonsView)
                
                // Present preview
                previewVC.modalPresentationStyle = .fullScreen
                picker.present(previewVC, animated: true)
                self.previewController = previewVC
            }
        }
        
        @objc func usePhotoTapped() {
            if let image = capturedImage {
                parent.onImageCaptured(image)
                previewController?.dismiss(animated: true) {
                    self.parent.isShowing = false
                }
            }
        }
        
        @objc func retakePhotoTapped() {
            capturedImage = nil
            previewController?.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isShowing = false
        }
    }
}
