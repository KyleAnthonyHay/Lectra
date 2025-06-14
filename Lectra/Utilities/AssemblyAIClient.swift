//
//  AxsemblyAIClient.swift
//  Lectra
//
//  Created by Cascade AI on 6/13/25.
//

import Foundation
import SwiftUI

class AssemblyAIClient: ObservableObject {
    // Singleton instance
    static let shared = AssemblyAIClient()
    
    private let apiKey: String
    private let uploadEndpoint = "https://api.assemblyai.com/v2/upload"
    private let transcriptEndpoint = "https://api.assemblyai.com/v2/transcript"
    private(set) var state: AudioProcessingState = .idle
    
    private init() {
        print("Initializing AssemblyAIClient...")
        
        // Try to get API key from environment first
        var apiKey = ProcessInfo.processInfo.environment["ASSEMBLY_AI_API_KEY"]
        print("Environment API key found: \(apiKey != nil)")
        
        // If not in environment, try Info.plist
        if apiKey == nil {
            if let plistKey = Bundle.main.infoDictionary?["ASSEMBLY_AI_API_KEY"] as? String {
                apiKey = plistKey
                print("Info.plist API key found: \(plistKey)")
            }
        }
        
        guard let finalApiKey = apiKey?.trimmingCharacters(in: CharacterSet(charactersIn: "\"")) else {
            print("❌ Failed to initialize AssemblyAI client: No API key found")
            fatalError("AssemblyAI API key not found in environment or Info.plist")
        }
        
        if finalApiKey.isEmpty {
            print("❌ Invalid API key: Key is empty")
            fatalError("Invalid AssemblyAI API key")
        }
        
        print("✅ Successfully retrieved AssemblyAI API key")
        self.apiKey = finalApiKey
    }
    
    /// Uploads an audio file to AssemblyAI
    /// - Parameter audioData: The audio data to upload
    /// - Returns: URL of the uploaded audio file
    func uploadAudio(audioData: Data) async throws -> String {
        print("Uploading audio to AssemblyAI, size: \(audioData.count) bytes")
        
        // Create upload request
        var request = URLRequest(url: URL(string: uploadEndpoint)!)
        request.httpMethod = "POST"
        request.addValue(apiKey, forHTTPHeaderField: "authorization")
        request.addValue("application/octet-stream", forHTTPHeaderField: "content-type")
        request.httpBody = audioData
        
        // Perform the request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Check response
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ Error uploading audio: \(errorMessage)")
            throw NSError(domain: "AssemblyAIClient", code: (response as? HTTPURLResponse)?.statusCode ?? -1, userInfo: [NSLocalizedDescriptionKey: "Failed to upload audio: \(errorMessage)"])
        }
        
        // Parse response
        guard let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let uploadUrl = jsonResponse["upload_url"] as? String else {
            print("❌ Failed to parse upload response")
            throw NSError(domain: "AssemblyAIClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse upload response"])
        }
        
        print("✅ Successfully uploaded audio to AssemblyAI")
        return uploadUrl
    }
    
    /// Submits a transcription request to AssemblyAI
    /// - Parameter audioUrl: URL of the audio file to transcribe
    /// - Returns: ID of the submitted transcription job
    func submitTranscription(audioUrl: String) async throws -> String {
        print("Submitting transcription request to AssemblyAI")
        
        // Create transcription request
        var request = URLRequest(url: URL(string: transcriptEndpoint)!)
        request.httpMethod = "POST"
        request.addValue(apiKey, forHTTPHeaderField: "authorization")
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        
        // Create request body
        let body: [String: Any] = [
            "audio_url": audioUrl
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        // Perform the request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Check response
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ Error submitting transcription: \(errorMessage)")
            throw NSError(domain: "AssemblyAIClient", code: (response as? HTTPURLResponse)?.statusCode ?? -1, userInfo: [NSLocalizedDescriptionKey: "Failed to submit transcription: \(errorMessage)"])
        }
        
        // Parse response
        guard let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let transcriptionId = jsonResponse["id"] as? String else {
            print("❌ Failed to parse transcription submission response")
            throw NSError(domain: "AssemblyAIClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse transcription submission response"])
        }
        
        print("✅ Successfully submitted transcription request, ID: \(transcriptionId)")
        return transcriptionId
    }
    
    /// Polls for the result of a transcription job
    /// - Parameters:
    ///   - transcriptionId: ID of the transcription job
    ///   - pollingInterval: Interval in seconds between polling attempts (default: 2)
    ///   - maxAttempts: Maximum number of polling attempts (default: 30)
    /// - Returns: The transcribed text
    func getTranscriptionResult(transcriptionId: String, pollingInterval: Double = 2, maxAttempts: Int = 30) async throws -> String {
        print("Polling for transcription result, ID: \(transcriptionId)")
        
        // Create URL for getting the transcription result
        let resultEndpoint = "\(transcriptEndpoint)/\(transcriptionId)"
        
        // Poll for the result
        for attempt in 1...maxAttempts {
            print("Polling attempt \(attempt) of \(maxAttempts)")
            
            // Create request
            var request = URLRequest(url: URL(string: resultEndpoint)!)
            request.httpMethod = "GET"
            request.addValue(apiKey, forHTTPHeaderField: "authorization")
            
            // Perform the request
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Check response
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                print("❌ Error polling transcription: \(errorMessage)")
                throw NSError(domain: "AssemblyAIClient", code: (response as? HTTPURLResponse)?.statusCode ?? -1, userInfo: [NSLocalizedDescriptionKey: "Failed to poll transcription: \(errorMessage)"])
            }
            
            // Parse response
            guard let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let status = jsonResponse["status"] as? String else {
                print("❌ Failed to parse polling response")
                throw NSError(domain: "AssemblyAIClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse polling response"])
            }
            
            // Check if completed
            if status == "completed" {
                guard let text = jsonResponse["text"] as? String else {
                    print("❌ No text found in completed transcription")
                    throw NSError(domain: "AssemblyAIClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "No text found in completed transcription"])
                }
                
                print("✅ Transcription completed successfully")
                return text
            }
            
            // Check for error status
            if status == "error" {
                let errorMessage = jsonResponse["error"] as? String ?? "Unknown error"
                print("❌ Transcription error: \(errorMessage)")
                throw NSError(domain: "AssemblyAIClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "Transcription error: \(errorMessage)"])
            }
            
            // Wait before the next attempt
            if attempt < maxAttempts {
                try await Task.sleep(nanoseconds: UInt64(pollingInterval * 1_000_000_000))
            }
        }
        
        print("❌ Transcription timed out after \(maxAttempts) attempts")
        throw NSError(domain: "AssemblyAIClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "Transcription timed out after \(maxAttempts) attempts"])
    }
    
    /// Processes an audio file using AssemblyAI's Speech-to-Text API
    /// - Parameters:
    ///   - audioData: The audio data to process
    ///   - onUpdate: Optional callback for progress updates
    /// - Returns: The transcribed text
    func processAudioFile(audioData: Data, onUpdate: ((String) -> Void)? = nil) async throws -> String {
        print("Processing audio file with AssemblyAI, size: \(audioData.count) bytes")
        state = .processingSpeech
        
        do {
            // Step 1: Upload the audio file
            onUpdate?("Uploading audio file...")
            let audioUrl = try await uploadAudio(audioData: audioData)
            
            // Step 2: Submit transcription request
            onUpdate?("Submitting transcription request...")
            let transcriptionId = try await submitTranscription(audioUrl: audioUrl)
            
            // Step 3: Poll for the result
            onUpdate?("Processing audio...")
            let transcribedText = try await getTranscriptionResult(transcriptionId: transcriptionId)
            
            state = .idle
            print("✅ Successfully processed audio with AssemblyAI")
            onUpdate?("Transcription complete!")
            
            return transcribedText
        } catch {
            state = .error(error)
            print("❌ Error processing audio with AssemblyAI: \(error.localizedDescription)")
            throw error
        }
    }
    
    func cancelProcessingTask() {
        print("Cancelling processing task...")
        state = .idle
    }
    
    enum AudioProcessingState {
        case idle
        case recordingSpeech
        case processingSpeech
        case playingSpeech
        case error(Error)
    }
}
