//
//  ContentView.swift
//  Lectra
//
//  Created by Kyle-Anthony Hay on 12/19/24.
//

import SwiftUI

struct RecordView: View {
    private let audioManager = AudioRecorderManager()
    private let openAIClient = OpenAIClientWrapper()
    @State private var gptResponse: String? = nil // Shared state for notes

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                LectureRecordCard(audioManager: audioManager)
                GenerateNotesCard(audioManager: audioManager, openAIClient: openAIClient)
                DisplayNotesCard(gptResponse: gptResponse)
            }
            .padding()
        }
    }
}

#Preview {
    RecordView()
}

