import Foundation
import Vision
import UIKit
import CoreImage

class OCRManager {
    // Nested enum for meter types to avoid redeclaration conflicts
    enum MeterType {
        case digital
        case analog
        case unknown
    }
    
    // Define detection result struct for comprehensive return data
    struct MeterDetectionResult {
        var reading: String?
        var serialNumber: String?
        var manufacturer: String?
        var confidence: Float
        var additionalInfo: [String: String] = [:]
        
        // Raw recognition results before processing
        var rawResults: [VNRecognizedTextObservation] = []
    }
    
    // Error handling for OCR operations
    enum OCRError: Error {
        case invalidImage
        case noTextDetected
        case processingFailed
        case alreadyProcessing
    }
    
    static let shared = OCRManager()
    private(set) var isProcessing = false
    var confidenceThreshold: Float = 0.4
    private(set) var lastProcessingTime: TimeInterval = 0
    
    private init() {}
    
    // MARK: - Public API Methods
    
    /// Comprehensive method that detects all meter information
    func detectMeterInfo(from image: UIImage, completion: @escaping (Result<MeterDetectionResult, Error>) -> Void) {
        guard !isProcessing else {
            completion(.failure(OCRError.alreadyProcessing))
            return
        }
        
        isProcessing = true
        let startTime = Date()
        
        // First classify the meter type to determine processing strategy
        let meterType = classifyMeterType(in: image)
        
        // Process the image based on meter type
        let processedImage = preprocessImageForMeterType(image, meterType: meterType)
        
        // Perform OCR on the processed image
        performOCR(on: processedImage) { [weak self] ocrText in
            guard let self = self else { return }
            
            if let text = ocrText {
                // Extract structured information from the OCR text
                let reading = self.extractNumericValue(from: text)
                let serialNumber = self.extractSerialNumber(from: text)
                let manufacturer = self.checkForManufacturer(in: text)
                
                // Create the result object
                var result = MeterDetectionResult(
                    reading: reading,
                    serialNumber: serialNumber, 
                    manufacturer: manufacturer,
                    confidence: 0.8 // Default confidence - could be improved with actual metrics
                )
                
                self.lastProcessingTime = Date().timeIntervalSince(startTime)
                self.isProcessing = false
                completion(.success(result))
            } else {
                self.isProcessing = false
                completion(.failure(OCRError.noTextDetected))
            }
        }
    }
    
    /// Legacy method for simple text recognition (maintained for backward compatibility)
    func recognizeText(in image: UIImage, completion: @escaping (String?) -> Void) {
        let meterType = classifyMeterType(in: image)
        switch meterType {
        case .digital:
            // Digital path: use existing digital preprocessors
            let processedImage1 = image.preprocessForOCR() ?? image
            let processedImage2 = image.preprocessDigitalDisplay() ?? image
            let processedImage3 = image.preprocessEnhancedForOCR() ?? image
            
            // Try all processed versions sequentially
            performOCR(on: processedImage1) { result1 in
                if self.containsLikelyMeterReading(in: result1) {
                    completion(self.postProcessOCRResult(text: result1 ?? ""))
                } else {
                    self.performOCR(on: processedImage2) { result2 in
                        if self.containsLikelyMeterReading(in: result2) && (result1 == nil || !self.containsLikelyMeterReading(in: result1)) {
                            completion(self.postProcessOCRResult(text: result2 ?? ""))
                        } else {
                            self.performOCR(on: processedImage3) { result3 in
                                if self.containsLikelyMeterReading(in: result3) && (result2 == nil || !self.containsLikelyMeterReading(in: result2)) {
                                    completion(self.postProcessOCRResult(text: result3 ?? ""))
                                } else {
                                    // Default to the best available result after post processing
                                    let finalResult = result1 ?? result2 ?? result3
                                    completion(self.postProcessOCRResult(text: finalResult ?? ""))
                                }
                            }
                        }
                    }
                }
            }
        case .analog:
            // Analog path: process with analog-specific preprocessing
            processAnalogMeter(in: image, completion: completion)
        case .unknown:
            // Fall back to default OCR processing if meter type is uncertain
            performOCR(on: image, completion: completion)
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
    
    // MARK: - Meter Type Classification
    
    /// Classify the meter type using a simple heuristic.
    func classifyMeterType(in image: UIImage) -> MeterType {
        // A basic heuristic: if the image aspect ratio is nearly square,
        // assume analog (e.g., circular gauge), else digital (rectangular LCD).
        let ratio = image.size.width / image.size.height
        if ratio > 0.8 && ratio < 1.2 {
            return .analog
        } else if ratio >= 1.2 {
            return .digital
        }
        return .unknown
    }
    
    // MARK: - Image Preprocessing
    
    /// Process analog meter images.
    func processAnalogMeter(in image: UIImage, completion: @escaping (String?) -> Void) {
        // For analog meters, we use the analog preprocessor.
        if let analogImage = image.preprocessAnalogMeter() {
            // Optionally, additional processing can be added here,
            // such as detecting needle angles or extracting digital readouts.
            performOCR(on: analogImage, completion: completion)
        } else {
            completion(nil)
        }
    }
    
    /// Unified preprocessing method based on meter type
    private func preprocessImageForMeterType(_ image: UIImage, meterType: MeterType) -> UIImage {
        switch meterType {
        case .digital:
            return image.preprocessDigitalDisplay() ?? image
        case .analog:
            return image.preprocessAnalogMeter() ?? image
        case .unknown:
            return image.preprocessForOCR() ?? image
        }
    }
    
    // MARK: - OCR Core Implementation
    
    /// Core OCR implementation that processes a single image using Vision
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
    
    // MARK: - Helper Methods
    
    // Helper to check if recognized text likely contains a meter reading
    private func containsLikelyMeterReading(in text: String?) -> Bool {
        guard let text = text else { return false }
        // Updated pattern to allow comma-separated numbers and decimals
        let pattern = "\\b\\d{1,3}(?:,\\d{3})*(?:\\.\\d+)?\\b"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let nsString = text as NSString
        let matches = regex?.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
        // Return true if any match contains either a comma or a decimal point
        return matches?.contains(where: { match in
            let matchedString = nsString.substring(with: match.range)
            return matchedString.contains(",") || matchedString.contains(".")
        }) ?? false
    }
    
    // Post-process OCR result using additional heuristics
    func postProcessOCRResult(text: String) -> String {
        // Additional logic to validate and correct OCR results could be implemented here.
        // For now, we simply return the text unchanged.
        return text
    }
    
    // MARK: - Advanced Text Extraction Methods
    
    /// Advanced method to extract numeric value from OCR results - specialized for water meters
    func extractNumericValue(from text: String) -> String? {
        let nsString = text as NSString
        
        // 1) First, specifically look for a number preceding "gallons" or "gal".
        //    Pattern example: "227.79 gallons" or "12,345.67 gal"
        let precedingGallonsPattern = "(\\d{1,3}(?:,\\d{3})*(?:\\.\\d+)?)(?=\\s*(?:gal|gallons))"
        if let regex = try? NSRegularExpression(pattern: precedingGallonsPattern, options: .caseInsensitive) {
            let results = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
            if let match = results.first {
                let matchString = nsString.substring(with: match.range)
                // Remove commas for standard numeric parsing if needed
                let normalized = matchString.replacingOccurrences(of: ",", with: "")
                print("Found numeric preceding gallons: \(matchString) normalized to \(normalized)")
                return normalized
            }
        }
        
        // 2) Check for numbers with commas (digital meter readings)
        let commaDecimalPattern = "\\b\\d{1,3}(?:,\\d{3})+(?:\\.\\d+)?\\b"
        if let regex = try? NSRegularExpression(pattern: commaDecimalPattern, options: []) {
            let results = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
            if let match = results.first {
                let matchString = nsString.substring(with: match.range)
                // Remove commas so the number can be parsed correctly if needed
                let normalized = matchString.replacingOccurrences(of: ",", with: "")
                print("Found digital meter reading with comma: \(matchString) normalized to \(normalized)")
                return normalized
            }
        }
        
        // 3) Then, try to find a standard decimal number without commas.
        let decimalPattern = "\\b\\d+\\.\\d+\\b"
        if let regex = try? NSRegularExpression(pattern: decimalPattern, options: []) {
            let results = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
            if let match = results.first {
                return nsString.substring(with: match.range)
            }
        }
        
        // 4) Fallback: Look for analog meter readings (sequences of 5-9 digits)
        let analogPattern = "\\b\\d{5,9}\\b"
        if let regex = try? NSRegularExpression(pattern: analogPattern, options: []) {
            let results = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
            if let match = results.first {
                return nsString.substring(with: match.range)
            }
        }
        
        return nil
    }
    
    /// Extract what might be a serial number from the OCR result
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
    
    /// Check for manufacturer names in text
    private func checkForManufacturer(in text: String) -> String? {
        // List of common water meter manufacturers
        let manufacturers = [
            "Neptune", "Sensus", "Badger", "Kamstrup", "Zenner",
            "Mueller", "Arad", "Itron", "Diehl", "Master Meter"
        ]
        
        let lowercaseText = text.lowercased()
        
        for manufacturer in manufacturers {
            if lowercaseText.contains(manufacturer.lowercased()) {
                return manufacturer
            }
        }
        
        return nil
    }
    
    // MARK: - Utility Methods for External Usage
    
    /// Apply detected information directly to a view model
    static func applyDetectionToViewModel(_ viewModel: TestViewModel, from image: UIImage, selectedMeter: TestView.SingleMeterOption, completion: @escaping (Bool) -> Void) {
        let processedImage = image.prepareForOCR() ?? image
        
        OCRManager.shared.detectMeterInfo(from: processedImage) { result in
            switch result {
            case .success(let detectionResult):
                DispatchQueue.main.async {
                    var detectedInfo: [String] = []
                    
                    // Apply the reading to the START field
                    if let reading = detectionResult.reading {
                        if selectedMeter == .small {
                            viewModel.smallMeterStart = reading
                            detectedInfo.append("Detected reading: \(reading)")
                        } else {
                            viewModel.largeMeterStart = reading
                            detectedInfo.append("Detected reading: \(reading)")
                        }
                    }
                    
                    // Add manufacturer info if detected
                    if let manufacturer = detectionResult.manufacturer {
                        detectedInfo.append("Detected manufacturer: \(manufacturer)")
                    }
                    
                    // Apply serial number if detected
                    if let serialNumber = detectionResult.serialNumber {
                        detectedInfo.append("Detected serial number: \(serialNumber)")
                    }
                    
                    // Add detected information to notes field if there's any info
                    if !detectedInfo.isEmpty {
                        let existingNotes = viewModel.notes
                        let newInfo = "--- Auto-Detected Information ---\n" + detectedInfo.joined(separator: "\n")
                        
                        if existingNotes.isEmpty {
                            viewModel.notes = newInfo
                        } else {
                            viewModel.notes = existingNotes + "\n\n" + newInfo
                        }
                    }
                    
                    completion(detectionResult.reading != nil || detectionResult.serialNumber != nil)
                }
                
            case .failure(let error):
                print("Meter detection failed: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
}

// MARK: - UIImage extensions for preprocessing

// UIImage extension for preprocessing methods used by OCRManager
extension UIImage {
    func preprocessAnalogMeter() -> UIImage? {
        // For analog meters, auto rotate and apply grayscale with contrast adjustment
        guard let rotated = OpenCVWrapper.autoRotateImage(self) else { return nil }
        return OpenCVWrapper.convertToGrayscaleAndAdjustContrast(rotated)
    }
    
    func preprocessForOCR() -> UIImage? {
        // For general OCR, convert image to grayscale and adjust contrast
        return OpenCVWrapper.convertToGrayscaleAndAdjustContrast(self)
    }
    
    func preprocessDigitalDisplay() -> UIImage? {
        // For digital displays, invert colors to enhance visibility
        return OpenCVWrapper.invertColors(self)
    }
    
    func preprocessEnhancedForOCR() -> UIImage? {
        // Use adaptive thresholding for enhanced OCR results
        return OpenCVWrapper.adaptiveThresholdImage(self)
    }
    
    /// Prepare an image for optimal OCR detection
    func prepareForOCR() -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        
        // Convert to grayscale for better OCR
        let ciImage = CIImage(cgImage: cgImage)
        let context = CIContext()
        
        // Apply grayscale filter
        let filter = CIFilter(name: "CIColorControls")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(0, forKey: kCIInputSaturationKey) // Desaturate
        filter?.setValue(1.1, forKey: kCIInputContrastKey) // Increase contrast
        
        guard let outputImage = filter?.outputImage,
              let outputCGImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: outputCGImage)
    }
}
