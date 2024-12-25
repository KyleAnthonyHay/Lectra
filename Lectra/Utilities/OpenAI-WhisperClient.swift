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
        // Debugging: Check if the API key is loaded correctly
        if let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] {
            print("API Key from environment: \(apiKey)")
        } else if let apiKey = Bundle.main.infoDictionary?["OPENAI_API_KEY"] as? String {
            print("API Key from Info.plist: \(apiKey)")
        } else {
            print("API Key not found in either environment or Info.plist.")
        }

        // Access API key from Info.plist or environment variables
        guard let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ??
                           Bundle.main.infoDictionary?["OPENAI_API_KEY"] as? String else {
            fatalError("Error")
        }
        print("Loaded API Key: \(apiKey)")
        client = OpenAIClient(apiKey: apiKey)
    }
    
    let returnMarkdown: String = "Make well organized notes about this lecture in markdown format. Also inculde a title for the notes. Include Categories and Subcategories where necessary."
    
    enum AudioProcessingState {
        case idle
        case recordingSpeech
        case processingSpeech
        case playingSpeech
        case error(Error)
    }
    
    private(set) var state: AudioProcessingState = .idle // Default state
    
    var processingSpeechTask: Task<Void, Never>?
    
    func processSpeechTask(audioData: Data) -> Task<String, Error> {
        Task { @MainActor [unowned self] in
            do {
                self.state = .processingSpeech
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
}

