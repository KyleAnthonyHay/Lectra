//
//  ContentView.swift
//  Lectra
//
//  Created by Kyle-Anthony Hay on 12/19/24.
//

import SwiftUI

struct RecordView: View {
    private let openAIClient = OpenAIClientWrapper()
    @State private var gptResponse: String? = nil // Shared state for notes
    @StateObject var transcriptionTuple: TranscriptionTuple
    @StateObject var audioManager: AudioRecorderManager
    var tupleName: String = ""
    
    // Custom initializer
    init(tupleName: String) {
        self.tupleName = tupleName
        let transcription = TranscriptionTuple(name: tupleName)
        _transcriptionTuple = StateObject(wrappedValue: transcription)
        _audioManager = StateObject(wrappedValue: AudioRecorderManager(transcriptionTuple: transcription))
    }
    
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
        }.environmentObject(transcriptionTuple)
    }
}

#Preview {
    RecordView(tupleName: "How to pray")
}

