//
//  ContentView.swift
//  Lectra
//
//  Created by Kyle-Anthony Hay on 12/19/24.
//

import SwiftUI

struct ContentView: View {
    private let audioManager = AudioRecorderManager()
    private let openAIClient = OpenAIClientWrapper()
    @State private var gptResponse: String? = nil // Shared state for notes

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Pass audioManager to LectureRecordCard
                LectureRecordCard(audioManager: audioManager)

                // GenerateNotesCard with gptResponse state
                GenerateNotesCard(
                    audioManager: audioManager,
                    openAIClient: openAIClient
                )

                // DisplayNotesCard with optional gptResponse
                DisplayNotesCard(gptResponse: gptResponse)
            }
            .padding()
        }
    }
}



#Preview {
    ContentView()
}
