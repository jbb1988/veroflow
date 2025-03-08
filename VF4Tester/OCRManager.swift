import Vision
import UIKit

class OCRManager {
    static let shared = OCRManager()
    
    private init() {}
    
    func recognizeText(in image: UIImage, completion: @escaping (String?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        let request = VNRecognizeTextRequest { (request: VNRequest, error: Error?) in
            guard let observations = request.results as? [VNRecognizedTextObservation],
                  error == nil else {
                completion(nil)
                return
            }
            
            let recognizedText = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }.joined(separator: " ")
            
            completion(recognizedText)
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        do {
            try requestHandler.perform([request])
        } catch {
            completion(nil)
        }
    }
    
    func detectBarcodes(in image: UIImage, completion: @escaping ([VNBarcodeObservation]?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        
        let barcodeRequest = VNDetectBarcodesRequest { request, error in
            if let observations = request.results as? [VNBarcodeObservation] {
                completion(observations)
            } else {
                completion(nil)
            }
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try requestHandler.perform([barcodeRequest])
        } catch {
            completion(nil)
        }
    }
}