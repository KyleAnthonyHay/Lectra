//
//  ContentView.swift
//  Lectra
//
//  Created by Kyle-Anthony Hay on 12/19/24.
//

import SwiftUI

struct BottomBlurModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content
            
            // Gradient blur effect with increasing intensity
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color.clear, location: 0),
                    .init(color: Color(.systemBackground).opacity(0.2), location: 0.3),
                    .init(color: Color(.systemBackground).opacity(0.4), location: 0.5),
                    .init(color: Color(.systemBackground).opacity(0.6), location: 0.7),
                    .init(color: Color(.systemBackground).opacity(0.9), location: 1.0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 120)
            .padding(.bottom, -30)
            .blur(radius: 12)
            .allowsHitTesting(false) // Ensures touches pass through to content below
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .edgesIgnoringSafeArea(.bottom)
    }
}

extension View {
    func bottomBlur() -> some View {
        self.modifier(BottomBlurModifier())
    }
}

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
        .bottomBlur()
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

