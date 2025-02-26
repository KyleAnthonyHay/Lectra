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
    let folder: Folder?
//    let foldermanager: FolderManager
    
    @State var tupleName: String
    
    // Custom initializer
    init(tupleName: String, folder: Folder? = nil) {
        self.tupleName = tupleName
        self.folder = folder
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
                LectureRecordCard(audioManager: audioManager, folder: folder!)
                GenerateNotesCard(audioManager: audioManager, openAIClient: openAIClient)
                DisplayNotesCard(gptResponse: gptResponse, audioManager: audioManager)
            }
            .padding()
        }.environmentObject(transcriptionTuple)
        
    }
}

#Preview {
    let previewData = TuplePreviewData()
    
    RecordView(tupleName: "How to pray", folder: previewData.dummyFolder)
}

