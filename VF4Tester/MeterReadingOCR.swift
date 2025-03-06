import Vision
import UIKit

class MeterReadingOCR {
    private static let numericPattern = "^[0-9]+([.,][0-9]+)?$"
    
    static func extractText(from image: UIImage, completion: @escaping (String?) -> Void) {
        guard let processedImage = preprocessImage(image),
              let cgImage = processedImage.cgImage else {
            completion(nil)
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation],
                  error == nil else {
                completion(nil)
                return
            }
            
            let possibleReadings = observations.compactMap { observation -> String? in
                guard let candidate = observation.topCandidates(1).first?.string,
                      let processed = processReading(candidate) else {
                    return nil
                }
                return processed
            }
            
            let bestReading = findBestReading(from: possibleReadings)
            completion(bestReading)
        }
        
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en-US"]
        request.customWords = ["gal", "ccf", "cf", "gallons"]
        
        do {
            try requestHandler.perform([request])
        } catch {
            print("Failed to perform OCR: \(error)")
            completion(nil)
        }
    }
    
    private static func preprocessImage(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        let ciImage = CIImage(cgImage: cgImage)
        let context = CIContext()
        
        let filters: [(CIImage) -> CIImage?] = [
            { image in
                let parameters = [kCIInputImageKey: image,
                                kCIInputContrastKey: NSNumber(value: 1.1)]
                return CIFilter(name: "CIColorControls", parameters: parameters)?.outputImage
            },
            { image in
                let parameters = [kCIInputImageKey: image,
                                kCIInputRadiusKey: NSNumber(value: 0)]
                return CIFilter(name: "CIUnsharpMask", parameters: parameters)?.outputImage
            }
        ]
        
        var processedImage = ciImage
        for filter in filters {
            if let filtered = filter(processedImage) {
                processedImage = filtered
            }
        }
        
        guard let outputCGImage = context.createCGImage(processedImage, from: processedImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    private static func processReading(_ text: String) -> String? {
        let cleanText = text.replacingOccurrences(of: " ", with: "")
                           .replacingOccurrences(of: ",", with: ".")
        
        let regex = try? NSRegularExpression(pattern: numericPattern)
        let range = NSRange(cleanText.startIndex..., in: cleanText)
        
        guard regex?.firstMatch(in: cleanText, range: range) != nil else {
            return nil
        }
        
        return cleanText
    }
    
    private static func findBestReading(from readings: [String]) -> String? {
        let filtered = readings.filter { reading -> Bool in
            guard let value = Double(reading) else { return false }
            return value >= 0 && value < 1000000
        }
        
        return filtered.first
    }
}
