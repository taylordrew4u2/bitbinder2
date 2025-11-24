//
//  TextRecognitionManager.swift
//  bitbinder
//
//  Created by taylor drew on 11/22/25.
//

import UIKit
import Vision

/// Manager for extracting text from images using Apple's Vision framework
@MainActor
final class TextRecognitionManager: ObservableObject {
    @Published var isProcessing = false
    @Published var error: TextRecognitionError?
    
    enum TextRecognitionError: LocalizedError {
        case noTextFound
        case processingFailed(String)
        
        var errorDescription: String? {
            switch self {
            case .noTextFound:
                return "No text was found in the image. Please try again with a clearer photo."
            case .processingFailed(let message):
                return "Failed to process image: \(message)"
            }
        }
    }
    
    /// Extract text from an image
    func extractText(from image: UIImage) async throws -> String {
        isProcessing = true
        defer { isProcessing = false }
        
        guard let cgImage = image.cgImage else {
            throw TextRecognitionError.processingFailed("Could not process image")
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: TextRecognitionError.processingFailed(error.localizedDescription))
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(throwing: TextRecognitionError.noTextFound)
                    return
                }
                
                // Sort observations by vertical position (top to bottom)
                let sortedObservations = observations.sorted { obs1, obs2 in
                    obs1.boundingBox.origin.y > obs2.boundingBox.origin.y
                }
                
                // Extract text from observations
                let recognizedStrings = sortedObservations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }
                
                if recognizedStrings.isEmpty {
                    continuation.resume(throwing: TextRecognitionError.noTextFound)
                } else {
                    let fullText = recognizedStrings.joined(separator: "\n")
                    continuation.resume(returning: fullText)
                }
            }
            
            // Configure for accurate text recognition
            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["en-US"]
            request.usesLanguageCorrection = true
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: TextRecognitionError.processingFailed(error.localizedDescription))
            }
        }
    }
    
    /// Parse extracted text into individual jokes
    /// Attempts to split text intelligently based on common patterns in joke books
    func parseJokes(from text: String) -> [ParsedJoke] {
        var jokes: [ParsedJoke] = []
        
        // Split by double newlines first (common paragraph separator)
        let paragraphs = text.components(separatedBy: "\n\n")
        
        for paragraph in paragraphs {
            let trimmed = paragraph.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Skip empty paragraphs or very short ones (likely noise)
            guard !trimmed.isEmpty, trimmed.count > 10 else { continue }
            
            // Try to detect if this looks like a numbered joke
            let numberedPattern = #"^(\d+[\.\)]\s*)"#
            if let regex = try? NSRegularExpression(pattern: numberedPattern),
               let match = regex.firstMatch(in: trimmed, range: NSRange(trimmed.startIndex..., in: trimmed)) {
                // Remove the number prefix
                let jokeText = (trimmed as NSString).replacingCharacters(in: match.range, with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                if !jokeText.isEmpty {
                    jokes.append(createParsedJoke(from: jokeText))
                }
            } else {
                // Not numbered, treat entire paragraph as a joke
                jokes.append(createParsedJoke(from: trimmed))
            }
        }
        
        // If we didn't find any paragraph breaks, try splitting by single newlines
        if jokes.isEmpty {
            let lines = text.components(separatedBy: "\n")
            for line in lines {
                let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty, trimmed.count > 10 else { continue }
                jokes.append(createParsedJoke(from: trimmed))
            }
        }
        
        return jokes
    }
    
    private func createParsedJoke(from text: String) -> ParsedJoke {
        // Try to extract a title from the first line or first sentence
        let lines = text.components(separatedBy: .newlines)
        let firstLine = lines.first ?? ""
        
        var title = ""
        var body = text
        
        if lines.count > 1 && firstLine.count < 100 {
            // Use first line as title if it's reasonably short
            title = firstLine
            body = lines.dropFirst().joined(separator: "\n")
        } else {
            // Extract first sentence as title
            let sentences = text.components(separatedBy: ". ")
            if let firstSentence = sentences.first, firstSentence.count < 100 {
                title = firstSentence
                if sentences.count > 1 {
                    body = sentences.dropFirst().joined(separator: ". ")
                }
            } else {
                // Just use first 50 characters as title
                let endIndex = text.index(text.startIndex, offsetBy: min(50, text.count))
                title = String(text[..<endIndex]) + "..."
            }
        }
        
        return ParsedJoke(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            body: body.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }
}

/// Represents a joke parsed from scanned text, before being saved as a Joke model
struct ParsedJoke: Identifiable {
    let id = UUID()
    var title: String
    var body: String
    var isSelected: Bool = true
}
