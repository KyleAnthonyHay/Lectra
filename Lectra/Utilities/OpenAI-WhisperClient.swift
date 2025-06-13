//
//  OpenAI-WhisperClient.swift
//  Lectra
//
//  Created by Kyle-Anthony Hay on 12/22/24.
// 

import Foundation
import SwiftOpenAI

class OpenAIClientWrapper {
    private let service: OpenAIService
    private let returnMarkdown: String = """
You are a Christian sermon note-taking assistant. When summarizing transcripts, follow these rules exactly:

1. Always return output in valid Markdown.  
2. Begin with a clear title in H1 format (e.g., "# Sermon Notes: [Sermon Title]").  
3. Capture each point as a direct observation—not prefaced by "the preacher said," but also not overly casual. For example:  
   - "God's grace transforms lives…" instead of "The preacher said that God's grace transforms lives."  
   - "Faith means trusting even when…" rather than "I felt that faith means trusting…."  
4. Organize main ideas as top-level bullets (use "- ").  
5. If the sermon quotes, paraphrases, or alludes to any Scripture passage:  
   - Identify the correct reference (e.g., Hebrews 11:1) even if it's not quoted verbatim.  
   - Create a separate bullet for that reference (e.g., "- **Scripture: Hebrews 11:1**").  
   - Under that bullet, add exactly one sub-bullet (use "  - ") explaining how the verse was used and what it contributes to the sermon's message.  
6. Group related ideas into Categories and, if needed, Subcategories. For example:  
   - **Category: God's Love**  
     - **Subcategory: Demonstrated in Christ**  
       - God's sacrifice shows…  
7. Capture any "fiery one-liners" or memorable phrases (especially alliterations) used in the sermon verbatim, placing them as separate bullets or integrated under relevant points. For example:  
   - "God will prepare you for where He's going to take you."  
8. Maintain a slightly personal tone—write as a Christian genuinely taking notes, without sounding like a generic AI. Avoid "the preacher said" or overly formal academic phrasing. Keep it clear but not stiff.  
9. Do not add extra commentary or reflections that weren't part of the sermon itself.  
10. If the audio happens to not be a sermon just create a general summary.

When given the raw transcript, produce a Markdown document that matches these requirements exactly.
"""
    private(set) var state: AudioProcessingState = .idle
    
    init() {
        print("Initializing OpenAIClientWrapper...")
        
        // Try to get API key from environment first
        var apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"]
        print("Environment API key found: \(apiKey != nil)")
        
        // If not in environment, try Info.plist
        if apiKey == nil {
            if let plistKey = Bundle.main.infoDictionary?["OPENAI_API_KEY"] as? String {
                apiKey = plistKey
                print("Info.plist API key found: \(plistKey)")
            }
        }
        
        guard let finalApiKey = apiKey?.trimmingCharacters(in: CharacterSet(charactersIn: "\"")) else {
            print("❌ Failed to initialize OpenAI client: No API key found")
            fatalError("OpenAI API key not found in environment or Info.plist")
        }
        
        if finalApiKey.isEmpty || finalApiKey.contains("$(OPENAI_API_KEY)") {
            print("❌ Invalid API key: Key is empty or contains placeholder")
            fatalError("Invalid OpenAI API key")
        }
        
        print("✅ Successfully retrieved API key")
        service = OpenAIServiceFactory.service(apiKey: finalApiKey)
    }
    
    func processSpeechTask(audioData: Data) -> Task<String, Error> {
        Task { @MainActor [unowned self] in
            do {
                print("Starting speech processing task...")
                self.state = .processingSpeech
                
                // Create audio transcription parameters
                let audioParameters = AudioTranscriptionParameters(fileName: "audio.m4a", file: audioData, prompt: returnMarkdown)
                print("Created audio parameters, file size: \(audioData.count) bytes")
                
                // Transcribe audio
                print("Sending transcription request to OpenAI...")
                let transcription = try await service.createTranscription(parameters: audioParameters).text
                print("Received transcription response, length: \(transcription.count) characters")
                
                try Task.checkCancellation()
                
                self.state = .idle
                return transcription
            } catch {
                print("❌ Error in processSpeechTask: \(error.localizedDescription)")
                if Task.isCancelled { throw error }
                self.state = .error(error)
                throw error
            }
        }
    }
    
    func processAudioFile(audioData: Data, onUpdate: @escaping (String) -> Void) async throws -> String {
        print("Processing single audio file, size: \(audioData.count) bytes")
        
        do {
            // Process the complete audio file
            print("Processing complete audio file")
            let task = processSpeechTask(audioData: audioData)
            let transcription = try await task.value
            print("✅ Successfully processed audio file")
            
            // Create chat completion parameters
            print("Creating chat completion with transcription...")
            let chatParameters = ChatCompletionParameters(
                messages: [
                    .init(role: .system, content: .text(returnMarkdown)),
                    .init(role: .user, content: .text(transcription))
                ],
                model: .gpt4o
            )
            
            // Start streaming chat completion
            print("Starting chat completion stream...")
            var fullResponse = ""
            let stream = try await service.startStreamedChat(parameters: chatParameters)
            
            for try await result in stream {
                if let content = result.choices.first?.delta.content {
                    fullResponse += content
                    onUpdate(fullResponse)
                }
            }
            
            print("✅ Successfully completed chat completion")
            return fullResponse
        } catch {
            print("❌ Error processing audio file: \(error.localizedDescription)")
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
