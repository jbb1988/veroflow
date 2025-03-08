import Foundation
import Vision
import UIKit
import CoreImage

class OCRManager {
    static let shared = OCRManager()
    
    private init() {}
    
    // Advanced recognizeText using multiple preprocessing approaches
    func recognizeText(in image: UIImage, completion: @escaping (String?) -> Void) {
        // Try multiple preprocessing approaches for best results with meter readings
        let processedImage1 = image.preprocessForOCR() ?? image
        let processedImage2 = image.preprocessDigitalDisplay() ?? image
        
        // Try both processed versions sequentially
        performOCR(on: processedImage1) { result1 in
            if self.containsLikelyMeterReading(in: result1) {
                // If the first processing method yields good meter readings, use it
                completion(result1)
            } else {
                // Otherwise try the alternative preprocessing
                self.performOCR(on: processedImage2) { result2 in
                    // Determine which result seems better for meter readings
                    if self.containsLikelyMeterReading(in: result2) && (result1 == nil || !self.containsLikelyMeterReading(in: result1)) {
                        completion(result2)
                    } else {
                        // Default to the first result if both or neither have meter readings
                        completion(result1 ?? result2)
                    }
                }
            }
        }
    }
    
    // Barcode detection method from the original version
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
    
    // Helper to check if recognized text likely contains a meter reading (i.e., decimal numbers)
    private func containsLikelyMeterReading(in text: String?) -> Bool {
        guard let text = text else { return false }
        
        let decimalPattern = "\\b\\d+\\.\\d+\\b"
        let regex = try? NSRegularExpression(pattern: decimalPattern, options: [])
        let nsString = text as NSString
        let matches = regex?.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
        return (matches?.count ?? 0) > 0
    }
    
    // Core OCR implementation that processes a single image using Vision
    private func performOCR(on image: UIImage, completion: @escaping (String?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                print("OCR Error: \(error)")
                completion(nil)
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(nil)
                return
            }
            
            var recognizedStrings: [String] = []
            
            // Process each observation and get up to 5 candidates
            for observation in observations {
                let candidates = observation.topCandidates(5)
                let decimalPattern = "\\b\\d+\\.\\d+\\b"  // Highest priority: decimals
                let integerPattern = "\\b\\d{4,}\\b"       // Next: large integer sequences
                
                let decimalRegex = try? NSRegularExpression(pattern: decimalPattern, options: [])
                let integerRegex = try? NSRegularExpression(pattern: integerPattern, options: [])
                
                var foundPrioritizedText = false
                
                // First priority: exact decimal numbers
                for candidate in candidates where !foundPrioritizedText {
                    let string = candidate.string
                    let nsStringCandidate = string as NSString
                    if let regex = decimalRegex,
                       regex.firstMatch(in: string, options: [], range: NSRange(location: 0, length: nsStringCandidate.length)) != nil {
                        recognizedStrings.append(string)
                        foundPrioritizedText = true
                        break
                    }
                }
                
                // Second priority: large integer sequences
                if !foundPrioritizedText {
                    for candidate in candidates {
                        let string = candidate.string
                        let nsStringCandidate = string as NSString
                        if let regex = integerRegex,
                           regex.firstMatch(in: string, options: [], range: NSRange(location: 0, length: nsStringCandidate.length)) != nil {
                            recognizedStrings.append(string)
                            foundPrioritizedText = true
                            break
                        }
                    }
                }
                
                // If no specific pattern matched, use the top candidate
                if !foundPrioritizedText, let topCandidate = candidates.first {
                    recognizedStrings.append(topCandidate.string)
                }
            }
            
            // Reconstruct lines by grouping observations based on their Y position
            var lines: [String] = []
            var currentLine: [String] = []
            var lastY: CGFloat = -1
            
            for (index, observation) in observations.enumerated() {
                if index < recognizedStrings.count {
                    let boundingBox = observation.boundingBox
                    let centerY = boundingBox.origin.y + boundingBox.height / 2
                    if lastY == -1 || abs(centerY - lastY) < 0.03 {
                        currentLine.append(recognizedStrings[index])
                    } else {
                        lines.append(currentLine.joined(separator: " "))
                        currentLine = [recognizedStrings[index]]
                    }
                    lastY = centerY
                }
            }
            
            if !currentLine.isEmpty {
                lines.append(currentLine.joined(separator: " "))
            }
            
            let text = lines.joined(separator: "\n")
            completion(text)
        }
        
        // Configure request settings optimal for digit recognition
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        request.recognitionLanguages = ["en-US"]
        request.customWords = ["gal", "gallons", "cu", "ft", "cubic", "meter", "neptune", "badger", "sensus"]
        
        do {
            try requestHandler.perform([request])
        } catch {
            print("OCR Request failed: \(error)")
            completion(nil)
        }
    }
    
    // Advanced method to extract numeric value from OCR results - specialized for water meters
    func extractNumericValue(from text: String) -> String? {
        let decimalPattern = "\\b\\d+\\.\\d+\\b"
        if let regex = try? NSRegularExpression(pattern: decimalPattern, options: []) {
            let nsString = text as NSString
            let results = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
            for match in results {
                let matchRange = match.range
                let matchString = nsString.substring(with: matchRange)
                let startIdx = max(0, matchRange.location - 1)
                let endIdx = min(nsString.length, matchRange.location + matchRange.length + 1)
                let surroundingCharsRange = NSRange(location: startIdx, length: endIdx - startIdx)
                let surroundingText = nsString.substring(with: surroundingCharsRange)
                let specialChars = CharacterSet(charactersIn: "#@$%^&*=<>{}[]|\\:;")
                if surroundingText.rangeOfCharacter(from: specialChars) == nil {
                    print("Found meter reading with decimal: \(matchString)")
                    return matchString
                }
            }
        }
        
        let analogPattern = "\\b\\d{5,9}\\b"
        if let regex = try? NSRegularExpression(pattern: analogPattern, options: []) {
            let nsString = text as NSString
            let results = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
            for match in results {
                let matchRange = match.range
                let matchString = nsString.substring(with: matchRange)
                let startIdx = max(0, matchRange.location - 1)
                let endIdx = min(nsString.length, matchRange.location + matchRange.length + 1)
                let surroundingCharsRange = NSRange(location: startIdx, length: endIdx - startIdx)
                let surroundingText = nsString.substring(with: surroundingCharsRange)
                let specialChars = CharacterSet(charactersIn: "#@$%^&*=<>{}[]|\\:;")
                if surroundingText.rangeOfCharacter(from: specialChars) == nil {
                    print("Found analog meter reading: \(matchString)")
                    return matchString
                }
            }
        }
        
        let potentialDecimalPattern = "\\b(\\d+)\\s+(\\d{1,3})\\b"
        if let regex = try? NSRegularExpression(pattern: potentialDecimalPattern, options: []) {
            let nsString = text as NSString
            let results = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
            for match in results {
                if match.numberOfRanges >= 3 {
                    let wholeNumber = nsString.substring(with: match.range(at: 1))
                    let fraction = nsString.substring(with: match.range(at: 2))
                    if fraction.count <= 3 {
                        let reading = "\(wholeNumber).\(fraction)"
                        print("Reconstructed decimal meter reading: \(reading)")
                        return reading
                    }
                }
            }
        }
        
        let generalNumericPattern = "\\d+(\\.\\d+)?"
        if let regex = try? NSRegularExpression(pattern: generalNumericPattern, options: []) {
            let nsString = text as NSString
            let results = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
            if let match = results.first {
                return nsString.substring(with: match.range)
            }
        }
        
        return nil
    }
    
    // Extract what might be a serial number from the OCR result
    func extractSerialNumber(from text: String) -> String? {
        let specialChars = CharacterSet(charactersIn: "#@$%^&*=<>{}[]|\\:;/")
        if text.rangeOfCharacter(from: specialChars) != nil {
            print("Rejected text with special characters for serial number: \(text)")
            return nil
        }
        
        let serialPattern = "\\b[A-Z0-9]{5,15}\\b"
        let regex = try? NSRegularExpression(pattern: serialPattern, options: [.caseInsensitive])
        let nsString = text as NSString
        let results = regex?.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
        
        for match in results ?? [] {
            let matchRange = match.range
            let matchString = nsString.substring(with: matchRange)
            let contextStart = max(0, matchRange.location - 1)
            let contextEnd = min(nsString.length, matchRange.location + matchRange.length + 1)
            let contextLength = contextEnd - contextStart
            let contextRange = NSRange(location: contextStart, length: contextLength)
            let contextString = nsString.substring(with: contextRange)
            if contextString.rangeOfCharacter(from: specialChars) != nil {
                print("Rejected serial number due to adjacent special characters: \(contextString)")
                continue
            }
            
            let hasLetters = matchString.rangeOfCharacter(from: .letters) != nil
            let hasDigits = matchString.rangeOfCharacter(from: .decimalDigits) != nil
            
            if (hasLetters && hasDigits) || (matchString.count >= 5 && !matchString.contains(".")) {
                print("Found clean serial number: \(matchString)")
                return matchString
            }
        }
        
        return nil
    }
}

// MARK: - UIImage Extensions for OCR Preprocessing

extension UIImage {
    // Preprocess image by converting to grayscale, enhancing contrast, applying unsharp mask and noise reduction
    func preprocessForOCR() -> UIImage? {
        guard let ciImage = CIImage(image: self) else { return self }
        let context = CIContext(options: nil)
        
        let grayscaleFilter = CIFilter(name: "CIColorControls")
        grayscaleFilter?.setValue(ciImage, forKey: kCIInputImageKey)
        grayscaleFilter?.setValue(0.0, forKey: kCIInputSaturationKey)
        guard let grayscaleImage = grayscaleFilter?.outputImage else { return self }
        
        let contrastFilter = CIFilter(name: "CIColorControls")
        contrastFilter?.setValue(grayscaleImage, forKey: kCIInputImageKey)
        contrastFilter?.setValue(1.5, forKey: kCIInputContrastKey)
        contrastFilter?.setValue(0.05, forKey: kCIInputBrightnessKey)
        guard let contrastedImage = contrastFilter?.outputImage else { return self }
        
        let unsharpFilter = CIFilter(name: "CIUnsharpMask")
        unsharpFilter?.setValue(contrastedImage, forKey: kCIInputImageKey)
        unsharpFilter?.setValue(1.5, forKey: kCIInputRadiusKey)
        unsharpFilter?.setValue(1.0, forKey: kCIInputIntensityKey)
        
        let noiseReductionFilter = CIFilter(name: "CINoiseReduction")
        noiseReductionFilter?.setValue(unsharpFilter?.outputImage ?? contrastedImage, forKey: kCIInputImageKey)
        noiseReductionFilter?.setValue(0.02, forKey: "inputNoiseLevel")
        noiseReductionFilter?.setValue(0.40, forKey: "inputSharpness")
        
        let outputImage = noiseReductionFilter?.outputImage ?? unsharpFilter?.outputImage ?? contrastedImage
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return self }
        
        return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
    }
    
    // Preprocess image specifically for digital meter displays (LCD/LED)
    func preprocessDigitalDisplay() -> UIImage? {
        guard let ciImage = CIImage(image: self) else { return self }
        let context = CIContext(options: nil)
        
        let colorFilter = CIFilter(name: "CIColorControls")
        colorFilter?.setValue(ciImage, forKey: kCIInputImageKey)
        colorFilter?.setValue(0.0, forKey: kCIInputSaturationKey)
        colorFilter?.setValue(1.8, forKey: kCIInputContrastKey)
        colorFilter?.setValue(0.05, forKey: kCIInputBrightnessKey)
        guard let bwImage = colorFilter?.outputImage else { return self }
        
        let unsharpFilter = CIFilter(name: "CIUnsharpMask")
        unsharpFilter?.setValue(bwImage, forKey: kCIInputImageKey)
        unsharpFilter?.setValue(1.0, forKey: kCIInputRadiusKey)
        unsharpFilter?.setValue(2.0, forKey: kCIInputIntensityKey)
        guard let sharpenedImage = unsharpFilter?.outputImage else { return self }
        
        let noiseReductionFilter = CIFilter(name: "CINoiseReduction")
        noiseReductionFilter?.setValue(sharpenedImage, forKey: kCIInputImageKey)
        noiseReductionFilter?.setValue(0.02, forKey: "inputNoiseLevel")
        noiseReductionFilter?.setValue(0.40, forKey: "inputSharpness")
        
        let outputImage = noiseReductionFilter?.outputImage ?? sharpenedImage
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return self }
        
        return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
    }
    
    // Preprocess image for analog water meters with odometer-style dials
    func preprocessAnalogMeter() -> UIImage? {
        guard let ciImage = CIImage(image: self) else { return self }
        let context = CIContext(options: nil)
        
        let grayscaleFilter = CIFilter(name: "CIColorControls")
        grayscaleFilter?.setValue(ciImage, forKey: kCIInputImageKey)
        grayscaleFilter?.setValue(0.0, forKey: kCIInputSaturationKey)
        grayscaleFilter?.setValue(1.3, forKey: kCIInputContrastKey)
        guard let grayscaleImage = grayscaleFilter?.outputImage else { return self }
        
        let gammaFilter = CIFilter(name: "CIGammaAdjust")
        gammaFilter?.setValue(grayscaleImage, forKey: kCIInputImageKey)
        gammaFilter?.setValue(1.2, forKey: "inputPower")
        guard let enhancedImage = gammaFilter?.outputImage else { return self }
        
        let unsharpFilter = CIFilter(name: "CIUnsharpMask")
        unsharpFilter?.setValue(enhancedImage, forKey: kCIInputImageKey)
        unsharpFilter?.setValue(1.5, forKey: kCIInputRadiusKey)
        unsharpFilter?.setValue(0.8, forKey: kCIInputIntensityKey)
        
        let outputImage = unsharpFilter?.outputImage ?? enhancedImage
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return self }
        
        return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
    }
}