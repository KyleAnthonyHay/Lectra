//
//  GenerateNotesCard.swift
//  Lectra
//
//  Created by Kyle-Anthony Hay on 12/20/24.
//

import SwiftUI

struct GenerateNotesCard: View {
    @EnvironmentObject var audioManager: AudioRecorderManager
    @EnvironmentObject var openAIClient: OpenAIClientWrapper
    @State private var isGenerating = false
    @State private var errorMessage: String? = nil
    @State private var isVisible = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header Text
            Text("Generate Notes")
                .font(.headline)
                .onAppear {
                    print("GenerateNotesCard - Header appeared")
                }
            
            Text("Transform your recording into organized notes using AI")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            // Generate Button
            Button(action: generateNotes) {
                HStack {
                    if isGenerating || audioManager.isTranscribing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "sparkles")
                    }
                    Text(buttonText)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isGenerating || audioManager.isTranscribing ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .animation(.easeInOut, value: isGenerating)
                .animation(.easeInOut, value: audioManager.isTranscribing)
            }
            .disabled(isGenerating || audioManager.isTranscribing || !audioManager.hasRecording)
            
            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.top, 4)
            }
            
            // MARK: Display Notes Card
            if isGenerating || !audioManager.streamedTranscription.isEmpty {
                DisplayNotesCard(gptResponse: nil, audioManager: audioManager)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 5)
        .opacity(isVisible ? 1 : 0)
        .animation(.easeIn(duration: 0.5), value: isVisible)
        .onAppear {
            print("GenerateNotesCard - View appeared")
            isVisible = true
        }
    }

    private func generateNotes() {
        print("GenerateNotesCard: Generate button pressed")
        
        // Verify AudioRecorderManager setup
        print("GenerateNotesCard: Verifying setup - hasRecording: \(audioManager.hasRecording), transcriptionTuple: \(String(describing: audioManager.transcriptionTuple != nil))")
        
        guard audioManager.hasRecording else {
            errorMessage = "No recording found. Please record or import audio first."
            print("GenerateNotesCard: No recording found")
            return
        }
        
        print("GenerateNotesCard: Starting generation, hasRecording: \(audioManager.hasRecording)")
        isGenerating = true
        errorMessage = nil
        audioManager.streamedTranscription = "" // Reset the transcription
        
        Task {
            do {
                print("GenerateNotesCard: Calling processAudioWithStreaming")
                try await audioManager.processAudioWithStreaming()
                
                await MainActor.run {
                    print("GenerateNotesCard: Transcription completed successfully")
                    isGenerating = false
                }
            } catch {
                await MainActor.run {
                    print("GenerateNotesCard: Error during transcription: \(error.localizedDescription)")
                    isGenerating = false
                    errorMessage = "Error: \(error.localizedDescription)"
                }
            }
        }
    }

    // Add computed property for button text
    private var buttonText: String {
        if audioManager.isTranscribing {
            return "Transcribing..."
        } else if isGenerating {
            return "Generating..."
        } else {
            return "Generate Notes"
        }
    }
}

#Preview {
    GenerateNotesCard()
}

