import Foundation
import Vision
import UIKit

class OCRManager {
    static let shared = OCRManager()
    
    func recognizeText(in image: UIImage, completion: @escaping (String?) -> Void) {
        // Try multiple preprocessing approaches for best results with meter readings
        let processedImage1 = image.preprocessForOCR() ?? image
        let processedImage2 = image.preprocessDigitalDisplay() ?? image
        
        // We'll try both processed versions sequentially
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
    
    /// Helper method to check if text likely contains meter readings (has numbers with decimals)
    private func containsLikelyMeterReading(in text: String?) -> Bool {
        guard let text = text else { return false }
        
        // Look for decimal number pattern which is very common in meter readings
        let decimalPattern = "\\b\\d+\\.\\d+\\b"
        let regex = try? NSRegularExpression(pattern: decimalPattern, options: [])
        let nsString = text as NSString
        let matches = regex?.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
        
        return (matches?.count ?? 0) > 0
    }
    
    /// Core OCR implementation that processes a single image
    private func performOCR(on image: UIImage, completion: @escaping (String?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        
        // Create a request handler
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        // Create a text recognition request
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
            
            // Process the recognized text - get multiple candidates for better accuracy with numbers
            var recognizedStrings: [String] = []
            
            for observation in observations {
                // Get up to 5 candidates for each text region to maximize chances of getting good readings
                let candidates = observation.topCandidates(5)
                
                // Patterns for various elements that might appear on a meter
                let decimalPattern = "\\b\\d+\\.\\d+\\b"  // Decimal numbers (highest priority)
                let integerPattern = "\\b\\d{4,}\\b"      // Integer sequences (medium priority)
                let serialPattern = "\\b[A-Za-z0-9]{5,}\\b" // Alphanumeric sequences (lower priority)
                
                let decimalRegex = try? NSRegularExpression(pattern: decimalPattern, options: [])
                let integerRegex = try? NSRegularExpression(pattern: integerPattern, options: [])
                let serialRegex = try? NSRegularExpression(pattern: serialPattern, options: [])
                
                // Try to find the candidates in priority order
                var foundPrioritizedText = false
                
                // First priority: exact decimal numbers (these are most likely meter readings)
                for candidate in candidates where !foundPrioritizedText {
                    let string = candidate.string
                    let nsString = string as NSString
                    
                    if let regex = decimalRegex,
                       regex.firstMatch(in: string, options: [], range: NSRange(location: 0, length: nsString.length)) != nil {
                        recognizedStrings.append(string)
                        foundPrioritizedText = true
                        break
                    }
                }
                
                // Second priority: large integer sequences
                if !foundPrioritizedText {
                    for candidate in candidates {
                        let string = candidate.string
                        let nsString = string as NSString
                        
                        if let regex = integerRegex,
                           regex.firstMatch(in: string, options: [], range: NSRange(location: 0, length: nsString.length)) != nil {
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
            
            // Combine all recognized text with spaces and newlines for better structure
            var lines: [String] = []
            var currentLine: [String] = []
            var lastY: CGFloat = -1
            
            // Group observations by approximate Y position to reconstruct lines
            for (index, observation) in observations.enumerated() {
                if index < recognizedStrings.count {
                    let boundingBox = observation.boundingBox
                    let centerY = boundingBox.origin.y + boundingBox.height/2
                    
                    if lastY == -1 || abs(centerY - lastY) < 0.03 { // Threshold for same line
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
        
        // Configure for optimal digit recognition
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false // Critical for meter readings
        request.recognitionLanguages = ["en-US"]
        
        // Customize for technical content
        request.customWords = ["gal", "gallons", "cu", "ft", "cubic", "meter", "neptune", "badger", "sensus"]
        
        // Perform the request
        do {
            try requestHandler.perform([request])
        } catch {
            print("OCR Request failed: \(error)")
            completion(nil)
        }
    }
    
    // Advanced method to extract numeric value from OCR results - specialized for water meters
    func extractNumericValue(from text: String) -> String? {
        // 1. First priority: Look for clear decimal numbers (digital meters)
        let decimalPattern = "\\b\\d+\\.\\d+\\b"
        if let regex = try? NSRegularExpression(pattern: decimalPattern, options: []) {
            let nsString = text as NSString
            let results = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
            
            // Find decimal numbers not adjacent to special characters
            for match in results {
                let matchRange = match.range
                let matchString = nsString.substring(with: matchRange)
                
                // Check surrounding characters to ensure this isn't part of something else
                let startIdx = max(0, matchRange.location - 1)
                let endIdx = min(nsString.length, matchRange.location + matchRange.length + 1)
                let surroundingCharsRange = NSRange(location: startIdx, length: endIdx - startIdx)
                let surroundingText = nsString.substring(with: surroundingCharsRange)
                
                // If no special characters are adjacent to the number
                let specialChars = CharacterSet(charactersIn: "#@$%^&*=<>{}[]|\\:;")
                if surroundingText.rangeOfCharacter(from: specialChars) == nil {
                    // This is likely a meter reading with a decimal
                    print("Found meter reading with decimal: \(matchString)")
                    return matchString
                }
            }
        }
        
        // 2. Second priority: Look for odometer-style readings (sequences of 5+ digits)
        // Common for analog meters with multiple digit wheels
        let analogPattern = "\\b\\d{5,9}\\b"
        if let regex = try? NSRegularExpression(pattern: analogPattern, options: []) {
            let nsString = text as NSString
            let results = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
            
            for match in results {
                let matchRange = match.range
                let matchString = nsString.substring(with: matchRange)
                
                // Check that it's not adjacent to special characters
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
        
        // 3. Check for potential "digit space digit" patterns which could be misrecognized decimal points
        // This handles cases where OCR mistakes a decimal point for a space
        let potentialDecimalPattern = "\\b(\\d+)\\s+(\\d{1,3})\\b"
        if let regex = try? NSRegularExpression(pattern: potentialDecimalPattern, options: []) {
            let nsString = text as NSString
            let results = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
            
            for match in results {
                if match.numberOfRanges >= 3 {
                    let wholeNumber = nsString.substring(with: match.range(at: 1))
                    let fraction = nsString.substring(with: match.range(at: 2))
                    
                    // Only consider if the second part is 1-3 digits (typical for decimals)
                    if fraction.count <= 3 {
                        let reading = "\(wholeNumber).\(fraction)"
                        print("Reconstructed decimal meter reading: \(reading)")
                        return reading
                    }
                }
            }
        }
        
        // 4. Fallback: If nothing else matches, look for any sequence of numbers
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
    
    // Extract what might be a serial number (alphanumeric pattern)
    func extractSerialNumber(from text: String) -> String? {
        // First check if the text contains special characters - if so, reject it immediately
        let specialChars = CharacterSet(charactersIn: "#@$%^&*=<>{}[]|\\:;/")
        if text.rangeOfCharacter(from: specialChars) != nil {
            print("Rejected text with special characters for serial number: \(text)")
            return nil
        }
        
        // Common serial number patterns often include letters followed by numbers
        // Looking for standalone alphanumeric patterns not adjacent to special characters
        let serialPattern = "\\b[A-Z0-9]{5,15}\\b"
        let regex = try? NSRegularExpression(pattern: serialPattern, options: [.caseInsensitive])
        let nsString = text as NSString
        let results = regex?.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
        
        // Check each match for special character adjacency
        for match in results ?? [] {
            let matchRange = match.range
            let matchString = nsString.substring(with: matchRange)
            
            // Examine the context by looking at a slightly wider range
            let contextStart = max(0, matchRange.location - 1)
            let contextEnd = min(nsString.length, matchRange.location + matchRange.length + 1)
            let contextLength = contextEnd - contextStart
            let contextRange = NSRange(location: contextStart, length: contextLength)
            let contextString = nsString.substring(with: contextRange)
            
            // If the wider context has special characters, reject this match
            if contextString.rangeOfCharacter(from: specialChars) != nil {
                print("Rejected serial number due to adjacent special characters: \(contextString)")
                continue
            }
            
            // Check if the match looks like a plausible serial number
            let hasLetters = matchString.rangeOfCharacter(from: .letters) != nil
            let hasDigits = matchString.rangeOfCharacter(from: .decimalDigits) != nil
            
            // It's a good serial number candidate if it has both letters and numbers
            // or if it's all numeric but in a format unlike meter readings
            if (hasLetters && hasDigits) ||
               (matchString.count >= 5 && !matchString.contains(".")) {
                print("Found clean serial number: \(matchString)")
                return matchString
            }
        }
        
        return nil
    }
}

// Extension to UIImage for preprocessing before OCR - optimized for meter readings
extension UIImage {
    func preprocessForOCR() -> UIImage? {
        // Create a CIImage for applying filters
        guard let ciImage = CIImage(image: self) else { return self }
        let context = CIContext(options: nil)
        
        // Step 1: Convert to grayscale first - better for reading digits
        let grayscaleFilter = CIFilter(name: "CIColorControls")
        grayscaleFilter?.setValue(ciImage, forKey: kCIInputImageKey)
        grayscaleFilter?.setValue(0.0, forKey: kCIInputSaturationKey) // Remove all color
        
        guard let grayscaleImage = grayscaleFilter?.outputImage else { return self }
        
        // Step 2: Apply adaptive contrast enhancement - specifically tuned for meter displays
        let contrastFilter = CIFilter(name: "CIColorControls")
        contrastFilter?.setValue(grayscaleImage, forKey: kCIInputImageKey)
        contrastFilter?.setValue(1.5, forKey: kCIInputContrastKey) // Higher contrast for digital displays
        contrastFilter?.setValue(0.05, forKey: kCIInputBrightnessKey) // Slight brightness boost
        
        guard let contrastedImage = contrastFilter?.outputImage else { return self }
        
        // Step 3: Apply unsharp mask to enhance edges (critical for disambiguating digits like 8/3/5)
        let unsharpFilter = CIFilter(name: "CIUnsharpMask")
        unsharpFilter?.setValue(contrastedImage, forKey: kCIInputImageKey)
        unsharpFilter?.setValue(1.5, forKey: kCIInputRadiusKey) // Slightly reduced radius for finer details
        unsharpFilter?.setValue(1.0, forKey: kCIInputIntensityKey) // Increased intensity for crisper edges
        
        // Step 4: Apply noise reduction to clean up digital artifacts while preserving digits
        let noiseReductionFilter = CIFilter(name: "CINoiseReduction")
        noiseReductionFilter?.setValue(unsharpFilter?.outputImage ?? contrastedImage, forKey: kCIInputImageKey)
        noiseReductionFilter?.setValue(0.02, forKey: kCIInputNoiseLevel) // Very subtle noise reduction
        noiseReductionFilter?.setValue(0.40, forKey: kCIInputSharpness) // Maintain sharpness of meaningful details
        
        // Create final processed image
        guard let outputImage = noiseReductionFilter?.outputImage ?? unsharpFilter?.outputImage ?? contrastedImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return self
        }
        
        // Return the enhanced image with digit-optimized processing
        return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
    }
    
    // Specialized method for digital water meter displays (LCD/LED)
    func preprocessDigitalDisplay() -> UIImage? {
        // Create a CIImage for applying filters
        guard let ciImage = CIImage(image: self) else { return self }
        let context = CIContext(options: nil)
        
        // Step 1: High contrast black and white conversion - optimal for LCD digits
        let colorFilter = CIFilter(name: "CIColorControls")
        colorFilter?.setValue(ciImage, forKey: kCIInputImageKey)
        colorFilter?.setValue(0.0, forKey: kCIInputSaturationKey) // Remove all color
        colorFilter?.setValue(1.8, forKey: kCIInputContrastKey) // Higher contrast for digital displays
        colorFilter?.setValue(0.05, forKey: kCIInputBrightnessKey) // Slight brightness boost
        
        guard let bwImage = colorFilter?.outputImage else { return self }
        
        // Step 2: Apply unsharp mask to enhance digit edges
        let unsharpFilter = CIFilter(name: "CIUnsharpMask")
        unsharpFilter?.setValue(bwImage, forKey: kCIInputImageKey)
        unsharpFilter?.setValue(1.0, forKey: kCIInputRadiusKey) // Moderate radius for digital displays
        unsharpFilter?.setValue(2.0, forKey: kCIInputIntensityKey) // Strong intensity for clear digits
        
        guard let sharpenedImage = unsharpFilter?.outputImage else { return self }
        
        // Step 3: Apply noise reduction to clean up digital artifacts
        let noiseReductionFilter = CIFilter(name: "CINoiseReduction")
        noiseReductionFilter?.setValue(sharpenedImage, forKey: kCIInputImageKey)
        noiseReductionFilter?.setValue(0.02, forKey: kCIInputNoiseLevel) // Very light noise reduction
        noiseReductionFilter?.setValue(0.40, forKey: kCIInputSharpness) // Maintain sharpness
        
        // Create final processed image
        guard let outputImage = noiseReductionFilter?.outputImage ?? sharpenedImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return self
        }
        
        return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
    }
    
    // Specialized method for analog water meters with odometer-style dials
    func preprocessAnalogMeter() -> UIImage? {
        // Create a CIImage for applying filters
        guard let ciImage = CIImage(image: self) else { return self }
        let context = CIContext(options: nil)
        
        // Step 1: Convert to grayscale with enhanced contrast for printed digits
        let grayscaleFilter = CIFilter(name: "CIColorControls")
        grayscaleFilter?.setValue(ciImage, forKey: kCIInputImageKey)
        grayscaleFilter?.setValue(0.0, forKey: kCIInputSaturationKey) // Remove all color
        grayscaleFilter?.setValue(1.3, forKey: kCIInputContrastKey) // Moderate contrast - not too high
        
        guard let grayscaleImage = grayscaleFilter?.outputImage else { return self }
        
        // Step 2: Apply adaptive histogram equalization for better detail in shadows/highlights
        // Since CIFilter doesn't have direct histogram equalization, we'll use alternatives
        
        // Apply gamma adjustment to enhance midtones where digits usually are
        let gammaFilter = CIFilter(name: "CIGammaAdjust")
        gammaFilter?.setValue(grayscaleImage, forKey: kCIInputImageKey)
        gammaFilter?.setValue(1.2, forKey: "inputPower") // Slight gamma boost
        
        guard let enhancedImage = gammaFilter?.outputImage else { return self }
        
        // Step 3: Apply moderate sharpening - less aggressive than for digital displays
        let unsharpFilter = CIFilter(name: "CIUnsharpMask")
        unsharpFilter?.setValue(enhancedImage, forKey: kCIInputImageKey)
        unsharpFilter?.setValue(1.5, forKey: kCIInputRadiusKey) // Wider radius for analog dials
        unsharpFilter?.setValue(0.8, forKey: kCIInputIntensityKey) // More subtle sharpening
        
        // Create final processed image
        guard let outputImage = unsharpFilter?.outputImage ?? enhancedImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return self
        }
        
        return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
    }
}