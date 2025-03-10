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
    
    // Use a dispatch queue for thread-safe processing
    private let processingQueue = DispatchQueue(label: "com.ocrmanager.processingQueue")
    private var _isProcessing: Bool = false
    private(set) var isProcessing: Bool {
        get {
            return processingQueue.sync { _isProcessing }
        }
        set {
            processingQueue.sync { _isProcessing = newValue }
        }
    }
    
    var confidenceThreshold: Float = 0.4
    private(set) var lastProcessingTime: TimeInterval = 0
    
    private init() {}
    
    // MARK: - Public API Methods
    
    /// Comprehensive method that detects all meter information
    func detectMeterInfo(from image: UIImage, completion: @escaping (Result<MeterDetectionResult, Error>) -> Void) {
        // Ensure thread-safe check of processing status
        if isProcessing {
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
        performOCR(on: processedImage) { [weak self] (ocrText, observations) in
            guard let self = self else { return }
            if let text = ocrText, !text.isEmpty {
                // Extract structured information from the OCR text
                let reading = self.extractNumericValue(from: text)
                let serialNumber = self.extractSerialNumber(from: text)
                let manufacturer = self.checkForManufacturer(in: text)
                
                // Compute average confidence from observations
                let avgConfidence = observations?.compactMap { $0.topCandidates(1).first?.confidence }.reduce(0, +) ?? 0
                let confidence = observations != nil && !observations!.isEmpty ? avgConfidence / Float(observations!.count) : 0.8
                
                // Create the result object
                var result = MeterDetectionResult(
                    reading: reading,
                    serialNumber: serialNumber,
                    manufacturer: manufacturer,
                    confidence: confidence,
                    rawResults: observations ?? []
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
            // Digital path: try an array of preprocessors sequentially
            let preprocessors: [(UIImage) -> UIImage?] = [
                { $0.preprocessDigitalDisplay() },
                { $0.prepareForOCR() },
                { $0.preprocessEnhancedForOCR() }
            ]
            tryPreprocessors(preprocessors, on: image, completion: completion)
        case .analog:
            // Analog path: process with analog-specific preprocessing
            processAnalogMeter(in: image, completion: completion)
        case .unknown:
            // Fallback to default OCR processing if meter type is uncertain
            performOCR(on: image) { result, _ in
                completion(self.postProcessOCRResult(text: result ?? ""))
            }
        }
    }
    
    /// Helper method to iterate through preprocessors for digital meter
    private func tryPreprocessors(_ preprocessors: [(UIImage) -> UIImage?], on image: UIImage, completion: @escaping (String?) -> Void) {
        var index = 0
        func attempt() {
            if index >= preprocessors.count {
                completion(nil)
                return
            }
            if let processedImage = preprocessors[index](image) {
                performOCR(on: processedImage) { result, _ in
                    if self.containsLikelyMeterReading(in: result) {
                        completion(self.postProcessOCRResult(text: result ?? ""))
                    } else {
                        index += 1
                        attempt()
                    }
                }
            } else {
                index += 1
                attempt()
            }
        }
        attempt()
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
    
    /// Classify the meter type using a heuristic based on aspect ratio and average brightness.
    func classifyMeterType(in image: UIImage) -> MeterType {
        let ratio = image.size.width / image.size.height
        // Compute average brightness (simple approximation)
        let brightness = image.averageBrightness() ?? 0.5
        // Heuristic: if nearly square and darker (analog gauges tend to be darker), assume analog
        if ratio > 0.8 && ratio < 1.2 && brightness < 0.6 {
            return .analog
        } else if ratio >= 1.2 {
            return .digital
        }
        return .unknown
    }
    
    // MARK: - Image Preprocessing
    
    /// Process analog meter images.
    func processAnalogMeter(in image: UIImage, completion: @escaping (String?) -> Void) {
        if let analogImage = image.preprocessAnalogMeter() {
            // Wrap the completion to match expected parameters of performOCR
            performOCR(on: analogImage) { result, _ in
                completion(result)
            }
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
            return image.prepareForOCR() ?? image
        }
    }
    
    // MARK: - OCR Core Implementation
    
    /// Core OCR implementation that processes a single image using Vision
    private func performOCR(on image: UIImage, completion: @escaping (String?, [VNRecognizedTextObservation]?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil, nil)
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                print("OCR Error: \(error.localizedDescription)")
                completion(nil, nil)
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(nil, nil)
                return
            }
            
            var recognizedStrings: [String] = []
            
            // Process each observation and get up to 5 candidates
            for observation in observations {
                let candidates = observation.topCandidates(5)
                var foundText: String?
                // Use prioritized regex patterns
                if let text = self.extractTextFromCandidates(candidates, withPattern: Self.decimalPattern) {
                    foundText = text
                } else if let text = self.extractTextFromCandidates(candidates, withPattern: Self.integerPattern) {
                    foundText = text
                } else if let topCandidate = candidates.first {
                    foundText = topCandidate.string
                }
                if let textFound = foundText {
                    recognizedStrings.append(textFound)
                }
            }
            
            // Group observations by Y position for line reconstruction
            var lines: [String] = []
            var currentLine: [String] = []
            var lastY: CGFloat = -1
            
            for (index, observation) in observations.enumerated() {
                if index < recognizedStrings.count {
                    let boundingBox = observation.boundingBox
                    let centerY = boundingBox.origin.y + boundingBox.height / 2
                    // If within 3% of the last line's center, assume same line
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
                lines.append(currentLine.joined(separator: "\n"))
            }
            
            let text = lines.joined(separator: "\n")
            completion(text, observations)
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
            completion(nil, nil)
        }
    }
    
    // MARK: - Helper Methods
    
    private static let decimalPattern = "\\b\\d+\\.\\d+\\b"
    private static let integerPattern = "\\b\\d{4,}\\b"
    
    /// Extract text from candidates using a regex pattern
    private func extractTextFromCandidates(_ candidates: [VNRecognizedText], withPattern pattern: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return nil }
        for candidate in candidates {
            let string = candidate.string
            let nsString = string as NSString
            if regex.firstMatch(in: string, options: [], range: NSRange(location: 0, length: nsString.length)) != nil {
                return string
            }
        }
        return nil
    }
    
    /// Helper to check if recognized text likely contains a meter reading
    private func containsLikelyMeterReading(in text: String?) -> Bool {
        guard let text = text else { return false }
        let pattern = "\\b\\d{1,3}(?:,\\d{3})*(?:\\.\\d+)?\\b"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return false }
        let nsString = text as NSString
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
        return matches.contains { match in
            let matchedString = nsString.substring(with: match.range)
            return matchedString.contains(",") || matchedString.contains(".")
        }
    }
    
    // Post-process OCR result using additional heuristics
    func postProcessOCRResult(text: String) -> String {
        return text
    }
    
    // MARK: - Advanced Text Extraction Methods
    
    /// Advanced method to extract numeric value from OCR results - specialized for water meters
    func extractNumericValue(from text: String) -> String? {
        let nsString = text as NSString
        
        // 1) Look for a number preceding "gallons"/"gal"/"gallon" (case-insensitive).
        //    This pattern handles singular/plural and any digits or decimals.
        //    Example: "000227279 gallons" or "12345.67 gal"
        //    We also allow newlines/whitespace with \s*.
        let precedingGallonsPattern = "(\\d+(?:,\\d{3})*(?:\\.\\d+)?)(?=\\s*(?:gal(?:lon)?s?))"
        if let regex = try? NSRegularExpression(pattern: precedingGallonsPattern, options: .caseInsensitive) {
            let results = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
            if let match = results.first {
                let matchString = nsString.substring(with: match.range)
                let normalized = matchString.replacingOccurrences(of: ",", with: "")
                print("Found numeric preceding 'gal/gallon/gallons': \(matchString) normalized to \(normalized)")
                return normalized
            }
        }
        
        // 2) Check for numbers with commas (digital meter readings)
        let commaDecimalPattern = "\\b\\d{1,3}(?:,\\d{3})+(?:\\.\\d+)?\\b"
        if let regex = try? NSRegularExpression(pattern: commaDecimalPattern, options: []) {
            let results = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
            if let match = results.first {
                let matchString = nsString.substring(with: match.range)
                let normalized = matchString.replacingOccurrences(of: ",", with: "")
                print("Found digital meter reading with comma: \(matchString) normalized to \(normalized)")
                return normalized
            }
        }
        
        // 3) Try to find a standard decimal number without commas.
        if let regex = try? NSRegularExpression(pattern: "\\b\\d+\\.\\d+\\b", options: []) {
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
        guard let regex = try? NSRegularExpression(pattern: serialPattern, options: [.caseInsensitive]) else { return nil }
        let nsString = text as NSString
        let results = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
        
        for match in results {
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
    func checkForManufacturer(in text: String) -> String? {
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
    static func applyDetectionToViewModel(_ viewModel: TestViewModel,
                                          from image: UIImage,
                                          selectedMeter: TestView.SingleMeterOption,
                                          completion: @escaping (Bool) -> Void)
    {
        let processedImage = image.prepareForOCR() ?? image
        
        OCRManager.shared.detectMeterInfo(from: processedImage) { result in
            switch result {
            case .success(let detectionResult):
                DispatchQueue.main.async {
                    var detectedInfo: [String] = []
                    
                    // Apply the reading to the appropriate meter field
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
                    
                    // Retrieve the entire recognized text (non-optional)
                    let allText = detectionResult.rawResults
                        .flatMap { $0.topCandidates(1).map { $0.string } }
                        .joined(separator: "\n")
                    
                    var recognizedTextBlock = ""
                    if !allText.isEmpty {
                        recognizedTextBlock = "\nDetected Text:\n\(allText)"
                    }
                    
                    // Build the new info block
                    var newInfoBlock = "--- Auto-Detected Information (\(Date())) ---\n"
                    if !detectedInfo.isEmpty {
                        newInfoBlock += detectedInfo.joined(separator: "\n")
                    }
                    if !recognizedTextBlock.isEmpty {
                        newInfoBlock += recognizedTextBlock
                    }
                    
                    // Append only if this block is not already in existing notes
                    let existingNotes = viewModel.notes
                    if !newInfoBlock.isEmpty, !existingNotes.contains(newInfoBlock) {
                        if existingNotes.isEmpty {
                            viewModel.notes = newInfoBlock
                        } else {
                            viewModel.notes = existingNotes + "\n\n" + newInfoBlock
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
    
    func preprocessForSerialNumber() -> UIImage? {
        // Simplified implementation: apply standard OCR preprocessing
        return self.preprocessForOCR()
    }
    
    func perspectiveCorrection() -> UIImage? {
        guard let ciImage = CIImage(image: self) else { return self }
        let filter = CIFilter(name: "CIPerspectiveCorrection")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        // Use image corners as default for basic correction
        filter?.setValue(CIVector(x: 0, y: 0), forKey: "inputTopLeft")
        filter?.setValue(CIVector(x: ciImage.extent.width, y: 0), forKey: "inputTopRight")
        filter?.setValue(CIVector(x: 0, y: ciImage.extent.height), forKey: "inputBottomLeft")
        filter?.setValue(CIVector(x: ciImage.extent.width, y: ciImage.extent.height), forKey: "inputBottomRight")
        
        let context = CIContext()
        if let outputImage = filter?.outputImage,
           let outputCGImage = context.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: outputCGImage)
        }
        return self
    }
    
    /// Prepare an image for optimal OCR detection by converting to grayscale and adjusting contrast.
    func prepareForOCR() -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        let context = CIContext()
        
        let filter = CIFilter(name: "CIColorControls")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(0, forKey: kCIInputSaturationKey) // Desaturate
        filter?.setValue(1.1, forKey: kCIInputContrastKey)   // Increase contrast
        
        guard let outputImage = filter?.outputImage,
              let outputCGImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    /// Calculate average brightness of an image (simple approximation)
    func averageBrightness() -> CGFloat? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extent = inputImage.extent
        let filter = CIFilter(name: "CIAreaAverage",
                              parameters: [kCIInputImageKey: inputImage,
                                           kCIInputExtentKey: CIVector(cgRect: extent)])
        guard let outputImage = filter?.outputImage else { return nil }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: NSNull()])
        context.render(outputImage,
                       toBitmap: &bitmap,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: nil)
        
        let brightness = CGFloat(bitmap[0]) / 255.0
        return brightness
    }
}