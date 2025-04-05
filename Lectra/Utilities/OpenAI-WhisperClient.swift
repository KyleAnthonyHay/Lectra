//
//  OpenAI-WhisperClient.swift
//  Lectra
//
//  Created by Kyle-Anthony Hay on 12/22/24.
// 

import Foundation
import XCAOpenAIClient

class OpenAIClientWrapper {
    private let client: OpenAIClient

    init() {
        // MARK: Access API key from Info.plist or environment variables
        guard let rawApiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ??
                           Bundle.main.infoDictionary?["OPENAI_API_KEY"] as? String else {
            fatalError("Error Creating apiKey Variable")
        }
        let cleanedApiKey = rawApiKey.trimmingCharacters(in: CharacterSet(charactersIn: "\""))  // removes the quotes("")
//        print("Cleaned API Key: \(cleanedApiKey)")  // Debugging statement
        client = OpenAIClient(apiKey: cleanedApiKey)
    }
    
    let returnMarkdown: String = "Make well organized notes of audio in markdown format. Inculde a short title for the notes as well as Categories and Subcategories where necessary."
    

    
    private(set) var state: AudioProcessingState = .idle // Default state
    
    var processingSpeechTask: Task<Void, Never>?
    
    func processSpeechTask(audioData: Data) -> Task<String, Error> {
        Task { @MainActor [unowned self] in
            do {
                self.state = .processingSpeech
                // Transcribe Audio
                let transcription = try await client.generateAudioTransciptions(audioData: audioData)
                
                try Task.checkCancellation()
                
                // Generate the markdown response
                let responseText = try await client.promptChatGPT(prompt: transcription, assistantPrompt: returnMarkdown)
                
                self.state = .idle // Reset state to idle after success
                return responseText
            } catch {
                if Task.isCancelled { throw error }
                self.state = .error(error)
                throw error // Propagate error for handling
            }
        }
    }

    
    func cancelProcessingTask() {
        processingSpeechTask?.cancel()
        processingSpeechTask = nil
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

extension OpenAIClientWrapper {
    func processAudioSegments(audioSegments: [Data]) async throws -> String {
        var allTranscriptions: [String] = []
        
        for (index, segmentData) in audioSegments.enumerated() {
            do {
                let task = processSpeechTask(audioData: segmentData)
                let transcription = try await task.value
                allTranscriptions.append(transcription)
                print("Processed segment \(index + 1) of \(audioSegments.count)")
            } catch {
                print("Error processing segment \(index + 1): \(error.localizedDescription)")
                allTranscriptions.append("Error transcribing segment \(index + 1)")
            }
        }
        
        // Combine all transcriptions
        let combinedTranscription = allTranscriptions.joined(separator: "\n\n")
        
        // Generate the final markdown response
        let responseText = try await client.promptChatGPT(
            prompt: combinedTranscription,
            assistantPrompt: returnMarkdown
        )
        
        return responseText
    }
}

