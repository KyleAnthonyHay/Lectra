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
        // MARK: Debugging: Check if the API key is loaded correctly
//        if let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] {
//            print("API Key has been accessed from environment/schema: \(apiKey)")
//        } else if let apiKey = Bundle.main.infoDictionary?["OPENAI_API_KEY"] as? String {
//            print("API Key has been accesed from Info.plist: \(apiKey)")
//        } else {
//            print("API Key not found in either environment or Info.plist.")
//        }

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

