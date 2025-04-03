import SwiftUI
import AVFoundation

struct CameraPermissionTestView: View {
    @State private var cameraAuthorizationStatus: AVAuthorizationStatus = .notDetermined
    @State private var showCamera = false
    @State private var capturedImage: UIImage?
    @State private var errorMessage: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Camera Permission Test")
                .font(.title)
                .bold()

            Text("Status: \(authorizationStatusText)")
                .font(.body)
                .foregroundColor(authorizationStatusColor)

            Button(action: checkCameraPermission) {
                Text("Check Camera Permission")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .disabled(cameraAuthorizationStatus == .authorized)

            if cameraAuthorizationStatus == .authorized {
                Button(action: {
                    showCamera = true
                }) {
                    Text("Open Camera")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                }
            }

            if let image = capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
            }
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.body)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
        .sheet(isPresented: $showCamera) {
            CameraView(isShowing: $showCamera, onImageCaptured: { image in
                print("Image captured successfully")
                capturedImage = image
            }, onError: { error in
                errorMessage = error.localizedDescription
            })
        }
        .onAppear {
            checkCameraPermission()
        }
    }

    private var authorizationStatusText: String {
        switch cameraAuthorizationStatus {
        case .notDetermined: return "Not Determined"
        case .restricted: return "Restricted"
        case .denied: return "Denied"
        case .authorized: return "Authorized"
        @unknown default: return "Unknown"
        }
    }

    private var authorizationStatusColor: Color {
        switch cameraAuthorizationStatus {
        case .authorized: return .green
        case .denied, .restricted: return .red
        case .notDetermined: return .orange
        @unknown default: return .gray
        }
    }

    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    cameraAuthorizationStatus = granted ? .authorized : .denied
                }
            }
        case .restricted, .denied:
            cameraAuthorizationStatus = .denied
        case .authorized:
            cameraAuthorizationStatus = .authorized
        @unknown default:
            cameraAuthorizationStatus = .denied
        }
    }
}

struct CameraPermissionTestView_Previews: PreviewProvider {
    static var previews: some View {
        CameraPermissionTestView()
    }
}
