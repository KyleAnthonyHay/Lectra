//
//  GenerateNotesCard.swift
//  Lectra
//
//  Created by Kyle-Anthony Hay on 12/20/24.
//

import SwiftUI

struct GenerateNotesCard: View {
    @ObservedObject var audioManager: AudioRecorderManager
    let openAIClient: OpenAIClientWrapper
    @State private var gptResponse: String? = nil
    @State private var isGenerating = false
    @State private var errorMessage: String? = nil
    
    var body: some View {
        // MARK: Generate Notes Card
        PhaseAnimator(CardAnimationPhase.allCases) { phase in
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.background)
                    .frame(width: 363, height: 188)
                    .shadow(radius: 8)
                    .cardAnimation(phase, for: .card)
                
                VStack(alignment: .leading, spacing: 16) {
                    // Header Text
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Generate Notes")
                            .font(.custom("Inter", size: 24).weight(.heavy))
                            .foregroundColor(.textSet)
                            .cardAnimation(phase, for: .header)

                        Text("Transcribe lectures into concise PowerPoints and detailed notes for efficient learning.")
                            .font(.custom("Inter", size: 12))
                            .foregroundColor(.secondary)
                            .cardAnimation(phase, for: .subtext)
                            
                        if let error = errorMessage {
                            Text(error)
                                .font(.custom("Inter", size: 12))
                                .foregroundColor(.red)
                        }
                    }
                    .frame(width: 250)

                    // Generate Button
                    Button(action: generateNotes) {
                        HStack(spacing: 8) {
                            if isGenerating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "sparkles")
                                    .foregroundColor(.white)
                            }
                            Text(isGenerating ? "Generating..." : "Generate")
                                .font(.custom("Inter", size: 18).weight(.medium))
                                .foregroundColor(.white)
                        }
                        .padding()
                        .frame(width: 292, height: 49)
                        .background(isGenerating ? Color.gray : Color.icon)
                        .cornerRadius(9)
                        .shadow(radius: 5)
                    }
                    .disabled(isGenerating || !audioManager.hasRecording)
                    .cardAnimation(phase, for: .button)
                }
            }
            .frame(width: 363, height: 188)
        } animation: { phase in
            phase.animation
        }
        
        // MARK: Display Notes Card
        if let response = gptResponse {
            DisplayNotesCard(gptResponse: response, audioManager: audioManager)
        }
    }

    private func generateNotes() {
        guard audioManager.hasRecording else {
            errorMessage = "No recording found. Please record or import audio first."
            return
        }
        
        isGenerating = true
        errorMessage = nil
        
        Task {
            do {
                print("Starting transcription process...")
                let audioData = try audioManager.getAudioData()
                print("Audio data retrieved, size: \(audioData.count) bytes")
                
                // Get the audio segments
                print("Splitting audio into segments...")
                let audioSegments = try await audioManager.splitAudioIntoTwoMinuteSegments(
                    from: audioData
                )
                print("Created \(audioSegments.count) audio segments")
                
                // Process all segments and get final response
                print("Processing audio segments...")
                let result = try await openAIClient.processAudioSegments(
                    audioSegments: audioSegments,
                    onUpdate: { streamUpdate in
                        Task { @MainActor in
                            print("Received stream update: \(streamUpdate.prefix(100))...")
                            self.gptResponse = streamUpdate
                        }
                    }
                )
                
                await MainActor.run {
                    print("Transcription completed successfully")
                    isGenerating = false
                    gptResponse = result
                }
            } catch {
                await MainActor.run {
                    print("Error during transcription: \(error.localizedDescription)")
                    isGenerating = false
                    errorMessage = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
}

#Preview {
    GenerateNotesCard(
        audioManager: AudioRecorderManager(transcriptionTuple: TuplePreviewData().dummyTuple),
        openAIClient: OpenAIClientWrapper()
    )
}

