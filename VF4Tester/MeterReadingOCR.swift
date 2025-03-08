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
        
        // Convert to grayscale using CIPhotoEffectMono filter
        let grayscale = ciImage.applyingFilter("CIPhotoEffectMono")
        
        // Adjust contrast to enhance text regions
        let contrastAdjusted = grayscale.applyingFilter("CIColorControls", parameters: [kCIInputContrastKey: 1.2])
        
        // Apply unsharp mask to sharpen the image
        let sharpened = contrastAdjusted.applyingFilter("CIUnsharpMask", parameters: [kCIInputRadiusKey: 2.5, kCIInputIntensityKey: 0.8])
        
        // (Optional) You can implement adaptive thresholding here if needed by using a custom filter or third-party solution.
        
        guard let outputCGImage = context.createCGImage(sharpened, from: sharpened.extent) else {
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
    
    // Prefer readings that already contain a decimal
    if let readingWithDecimal = filtered.first(where: { $0.contains(".") }) {
        return readingWithDecimal
    }
    
    // If no decimal is found, attempt to insert one if the candidate length matches expected format.
    if let candidate = filtered.first {
        // Assume typical meter readings have 5 or 6 digits and require one decimal place.
        if candidate.count == 5 {
            // Insert decimal before the last digit (e.g., "12345" -> "1234.5")
            let index = candidate.index(candidate.endIndex, offsetBy: -1)
            let newReading = candidate[..<index] + "." + candidate[index...]
            return String(newReading)
        } else if candidate.count == 6 {
            // Insert decimal before the last two digits (e.g., "123456" -> "1234.56")
            let index = candidate.index(candidate.endIndex, offsetBy: -2)
            let newReading = candidate[..<index] + "." + candidate[index...]
            return String(newReading)
        }
        return candidate
    }
    return nil
}
}