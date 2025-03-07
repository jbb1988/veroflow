import Foundation
import Vision
import UIKit
import CoreML
import CoreImage

// MARK: - Detection Types

enum MeterPartType {
    case readingDisplay  // The numeric display showing current reading
    case serialNumber    // Serial number/identification
    case manufacturerInfo // Manufacturer details
    case flowIndicator   // Flow direction indicator
    case unitLabel       // Unit label (gallons, cubic feet, etc.)
    case unknown
}

struct MeterDetectionResult {
    var reading: String?
    var serialNumber: String?
    var manufacturer: String?
    var confidence: Float
    var additionalInfo: [String: String] = [:]
    
    // Raw recognition results before processing
    var rawResults: [VNRecognizedTextObservation] = []
}

// MARK: - Main Manager Class

class MeterDetectionManager {
    static let shared = MeterDetectionManager()
    
    // Configuration parameters
    var confidenceThreshold: Float = 0.4
    private(set) var isProcessing = false
    
    // Store processing metrics for analysis
    private(set) var lastProcessingTime: TimeInterval = 0
    
    // MARK: - Main Detection Methods
    
    /// Process an image to detect meter readings and other information
    /// - Parameters:
    ///   - image: Image containing the water meter
    ///   - completion: Completion handler with detection result
    func detectMeterInfo(from image: UIImage, completion: @escaping (Result<MeterDetectionResult, Error>) -> Void) {
        guard !isProcessing else {
            completion(.failure(DetectionError.alreadyProcessing))
            return
        }
        
        isProcessing = true
        let startTime = Date()
        
        // Process with the Vision framework
        guard let cgImage = image.cgImage else {
            isProcessing = false
            completion(.failure(DetectionError.invalidImage))
            return
        }
        
        // Create a request handler
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        // First pass - detect the meter itself to focus recognition
        detectMeterRegion(in: cgImage) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let meterRegion):
                // Now we have the meter region, perform text recognition on that specific area
                self.recognizeTextInRegion(handler: requestHandler, region: meterRegion) { textResult in
                    switch textResult {
                    case .success(let observations):
                        // Process the recognized text to extract structured information
                        let processedResult = self.processTextObservations(observations)
                        
                        // Complete the operation
                        self.lastProcessingTime = Date().timeIntervalSince(startTime)
                        self.isProcessing = false
                        completion(.success(processedResult))
                        
                    case .failure(let error):
                        self.isProcessing = false
                        completion(.failure(error))
                    }
                }
                
            case .failure(let error):
                // If we couldn't detect the meter region, fall back to whole image recognition
                self.recognizeTextInRegion(handler: requestHandler, region: nil) { textResult in
                    switch textResult {
                    case .success(let observations):
                        // Process the recognized text with whole image heuristics
                        let processedResult = self.processTextObservations(observations)
                        
                        self.lastProcessingTime = Date().timeIntervalSince(startTime)
                        self.isProcessing = false
                        completion(.success(processedResult))
                        
                    case .failure(let error):
                        self.isProcessing = false
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    // MARK: - Meter Region Detection
    
    /// Detect the specific region containing the meter
    private func detectMeterRegion(in image: CGImage, completion: @escaping (Result<CGRect, Error>) -> Void) {
        // For now, we'll use a simplified approach that returns the whole image
        // In a production app, you would implement object detection to isolate the meter
        completion(.success(CGRect(x: 0, y: 0, width: image.width, height: image.height)))
        
        // Future enhancement: Use a CoreML model trained on water meters
        // let objectDetectionRequest = VNCoreMLRequest(model: meterDetectionModel) { request, error in
        //    guard let results = request.results as? [VNRecognizedObjectObservation] else { return }
        //    // Find the meter in detected objects
        // }
    }
    
    // MARK: - Text Recognition
    
    /// Recognize text within a specific region of the image
    private func recognizeTextInRegion(handler: VNImageRequestHandler, region: CGRect?, completion: @escaping (Result<[VNRecognizedTextObservation], Error>) -> Void) {
        // Create a text recognition request
        let textRequest = VNRecognizeTextRequest { request, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(.failure(DetectionError.noTextDetected))
                return
            }
            
            // Filter by confidence threshold
            let filteredObservations = observations.filter { observation in
                observation.topCandidates(1).first?.confidence ?? 0 > self.confidenceThreshold
            }
            
            completion(.success(filteredObservations))
        }
        
        // Configure the text recognition request
        textRequest.recognitionLevel = .accurate
        textRequest.usesLanguageCorrection = false  // Don't correct - we want raw numbers
        
        // Set a region of interest if provided
        if let region = region, region != CGRect(x: 0, y: 0, width: 1, height: 1) {
            textRequest.regionOfInterest = region
        }
        
        // Perform the request
        do {
            try handler.perform([textRequest])
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: - Post-Processing
    
    /// Process the text observations to extract structured meter information
    private func processTextObservations(_ observations: [VNRecognizedTextObservation]) -> MeterDetectionResult {
        var result = MeterDetectionResult(confidence: 0, rawResults: observations)
        var allCandidateTexts: [String] = []
        var highestConfidence: Float = 0
        
        // Extract all candidate texts with their confidence
        for observation in observations {
            if let firstCandidate = observation.topCandidates(1).first {
                allCandidateTexts.append(firstCandidate.string)
                highestConfidence = max(highestConfidence, firstCandidate.confidence)
            }
        }
        
        // Process the recognized text
        let (processedReading, processedSerial, manufacturer) = extractMeterInfoFromText(allCandidateTexts)
        
        result.reading = processedReading
        result.serialNumber = processedSerial
        result.manufacturer = manufacturer
        result.confidence = highestConfidence
        
        return result
    }
    
    /// Extract meter reading, serial number, and manufacturer from text
    private func extractMeterInfoFromText(_ texts: [String]) -> (reading: String?, serialNumber: String?, manufacturer: String?) {
        // This is where the intelligent pattern matching happens
        // We'll implement some heuristics to identify different parts
        
        var potentialReadings: [String] = []
        var potentialSerials: [String] = []
        var potentialManufacturers: [String] = []
        
        // Pattern matching for meter readings and serial numbers
        for text in texts {
            // 1. Look for digit sequences that might be readings
            if let reading = extractMeterReading(from: text) {
                potentialReadings.append(reading)
            }
            
            // 2. Look for alphanumeric patterns that might be serial numbers
            if let serial = extractSerialNumber(from: text) {
                potentialSerials.append(serial)
            }
            
            // 3. Check for known manufacturer names
            if let manufacturer = checkForManufacturer(in: text) {
                potentialManufacturers.append(manufacturer)
            }
        }
        
        // Return the most likely candidates
        return (
            potentialReadings.first,
            potentialSerials.first,
            potentialManufacturers.first
        )
    }
    
    // MARK: - Pattern Extraction Helpers
    
    /// Extract what looks like a meter reading from text
    private func extractMeterReading(from text: String) -> String? {
        // Common meter reading patterns:
        // 1. Sequence of digits (possibly with decimal points)
        // 2. Often has specific length (5-8 digits)
        
        // Remove all non-numeric characters except decimal points and get consecutive digits
        let numericChars = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: "."))
        let numericText = text.components(separatedBy: numericChars.inverted).joined()
        
        // If we have a substantial numeric sequence, it might be a reading
        if numericText.count >= 5 {
            // Further validate the format (e.g., correct number of decimal places)
            if let _ = Double(numericText) {
                return numericText
            }
        }
        
        // Alternative: Look for specific patterns using regex
        let meterReadingPattern = #"(\d{5,9}|\d{1,3}\.\d{1,3})(?!\w)"#
        if let match = text.range(of: meterReadingPattern, options: .regularExpression) {
            return String(text[match])
        }
        
        return nil
    }
    
    /// Extract what looks like a serial number from text
    private func extractSerialNumber(from text: String) -> String? {
        // Common serial number patterns:
        // 1. Mix of letters and numbers
        // 2. Often starts with specific letter sequences
        // 3. Often has specific format (e.g., 2 letters followed by 6-8 digits)
        
        // Check for common serial number patterns using regex
        let serialPatterns = [
            #"[A-Z]{1,3}\d{5,10}"#,          // 1-3 letters followed by 5-10 digits
            #"\d{2,3}-\d{5,7}"#,             // 2-3 digits, hyphen, 5-7 digits
            #"[A-Z]{2}\d{6,8}[A-Z]{0,2}"#    // 2 letters, 6-8 digits, optional 1-2 letters
        ]
        
        for pattern in serialPatterns {
            if let match = text.range(of: pattern, options: .regularExpression) {
                return String(text[match])
            }
        }
        
        // If no patterns matched but text looks like it could be a serial number
        // (mix of letters and numbers with specific length)
        let alphanumeric = text.filter { $0.isLetter || $0.isNumber }
        if alphanumeric.count >= 6 && alphanumeric.count <= 15 {
            // Check if it has both letters and numbers
            let hasLetters = alphanumeric.contains { $0.isLetter }
            let hasNumbers = alphanumeric.contains { $0.isNumber }
            
            if hasLetters && hasNumbers {
                return alphanumeric
            }
        }
        
        return nil
    }
    
    /// Check if text contains known manufacturer names
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
    
    // MARK: - Error Types
    
    enum DetectionError: Error {
        case invalidImage
        case noTextDetected
        case processingFailed
        case alreadyProcessing
    }
}

// MARK: - Extensions for Image Processing

extension UIImage {
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

// MARK: - Usage Examples

extension MeterDetectionManager {
    
    /// Simple function to demonstrate how to use the manager
    static func detectMeterReadingFromImage(image: UIImage, completion: @escaping (String?, String?) -> Void) {
        // First, preprocess the image for better OCR results
        let processedImage = image.prepareForOCR() ?? image
        
        // Then detect meter information
        MeterDetectionManager.shared.detectMeterInfo(from: processedImage) { result in
            switch result {
            case .success(let detectionResult):
                // Return the reading and serial number
                completion(detectionResult.reading, detectionResult.serialNumber)
                
            case .failure(let error):
                print("Meter detection failed: \(error.localizedDescription)")
                completion(nil, nil)
            }
        }
    }
    
    /// Apply detected information directly to a view model
    static func applyDetectionToViewModel(_ viewModel: TestViewModel, from image: UIImage, selectedMeter: TestView.SingleMeterOption, completion: @escaping (Bool) -> Void) {
        detectMeterReadingFromImage(image: image) { reading, serialNumber in
            DispatchQueue.main.async {
                var detectedInfo: [String] = []
                
                // Apply the reading to the START field (per user request)
                if let reading = reading {
                    // Put reading in start field instead of end field
                    if selectedMeter == .small {
                        viewModel.smallMeterStart = reading
                        detectedInfo.append("Detected reading: \(reading)")
                    } else {
                        viewModel.largeMeterStart = reading
                        detectedInfo.append("Detected reading: \(reading)")
                    }
                }
                
                // Apply serial number if detected
                if let serialNumber = serialNumber {
                    // Add to job number field
                    // viewModel.jobNumberText = serialNumber
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
                
                completion(reading != nil || serialNumber != nil)
            }
        }
    }
}