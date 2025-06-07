//
//  ContentView.swift
//  Lectra
//
//  Created by Kyle-Anthony Hay on 12/19/24.
//

import SwiftUI

struct RecordView: View {
    private let openAIClient = OpenAIClientWrapper()
    @State private var isTranscribing = false
    @StateObject var transcriptionTuple: TranscriptionTuple
    @StateObject var audioManager: AudioRecorderManager
    let folder: Folder?
    
    @State var tupleName: String
    
    init(tupleName: String, folder: Folder? = nil) {
        self.tupleName = tupleName
        self.folder = folder
        let transcription = TranscriptionTuple(name: tupleName)
        _transcriptionTuple = StateObject(wrappedValue: transcription)
        _audioManager = StateObject(wrappedValue: AudioRecorderManager.shared)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(tupleName)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Record your lecture and generate notes")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    AudioUploadButton(transcriptionTuple: transcriptionTuple, 
                                    folder: folder!,
                                    isGenerating: .constant(false),
                                    isTranscribing: $isTranscribing)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                // Record Card
                LectureRecordCard(audioManager: audioManager, folder: folder!)
                    .padding(.horizontal)
                
                // Generate Notes Card
                GenerateNotesCard(audioManager: audioManager, openAIClient: openAIClient)
                    .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .environmentObject(transcriptionTuple)
        .onAppear {
            // Setup the AudioRecorderManager with the current transcription tuple
            audioManager.setup(with: transcriptionTuple)
            print("RecordView appeared - Setting up AudioRecorderManager with transcriptionTuple")
        }
    }
}

#Preview {
    let previewData = TuplePreviewData()
    RecordView(tupleName: "How to pray", folder: previewData.dummyFolder)
}

