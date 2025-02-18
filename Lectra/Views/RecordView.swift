//
//  ContentView.swift
//  Lectra
//
//  Created by Kyle-Anthony Hay on 12/19/24.
//

import SwiftUI

/// TODO:
///     - Have Audio Recorder manager store recording in Tuple Object
///     - openAiclient store transcription in said
struct RecordView: View {
    private let audioManager = AudioRecorderManager()
    private let openAIClient = OpenAIClientWrapper()
    @State private var gptResponse: String? = nil // Shared state for notes
    var tupleName: String = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text(tupleName)
                    .font(.largeTitle)
                    .padding()
                LectureRecordCard(audioManager: audioManager)
                GenerateNotesCard(audioManager: audioManager, openAIClient: openAIClient)
                DisplayNotesCard(gptResponse: gptResponse)
            }
            .padding()
        }
    }
}

#Preview {
    RecordView(tupleName: "How to Pray")
}

