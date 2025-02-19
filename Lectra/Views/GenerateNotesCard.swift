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
    @State private var gptResponse: String? = nil // Optional to store GPT response

    var body: some View {
        // MARK: Generate Notes Card
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.background)
                .frame(width: 363, height: 188)
                .shadow(radius: 8)
            
            VStack(alignment: .leading, spacing: 16) {
                // Header Text
                VStack(alignment: .leading, spacing: 8) {
                    Text("Generate Notes")
                        .font(.custom("Inter", size: 24).weight(.heavy))
                        .foregroundColor(.textSet)

                    Text("Transcribe lectures into concise PowerPoints and detailed notes for efficient learning.")
                        .font(.custom("Inter", size: 12))
                        .foregroundColor(.secondary)
                }
                .frame(width: 250)

                // Generate Button
                Button(action: generateNotes) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .foregroundColor(.white)
                        Text("Generate")
                            .font(.custom("Inter", size: 18).weight(.medium))
                            .foregroundColor(.white)
                    }
                    .padding()
                    .frame(width: 292, height: 49)
                    .background(.icon)
                    .cornerRadius(9)
                    .shadow(radius: 5)
                }

                
            }
        }
        .frame(width: 363, height: 188)
        // MARK: Display Notes Card
        if let response = gptResponse {
            DisplayNotesCard(gptResponse: response)
        }
    }

    private func generateNotes() {
        print("Generate Button Pressed")
        do {
            let audioData = try audioManager.getAudioData() // Fetch audio data
            let task = openAIClient.processSpeechTask(audioData: audioData)

            Task {
                do {
                    let result = try await task.value
                    print("Transcription Result: \(result)")
                    gptResponse = result // Update the state to show DisplayNotesCard
                } catch {
                    print("Error processing speech: \(error.localizedDescription)")
                }
            }
        } catch {
            print("Failed to load audio data: \(error.localizedDescription)")
        }
    }
}



#Preview {
    GenerateNotesCard(
        audioManager: AudioRecorderManager(transcriptionTuple: TuplePreviewData().dummyTuple),
        openAIClient: OpenAIClientWrapper()
    )
}

