//
//  ContentView.swift
//  Lectra
//
//  Created by Kyle-Anthony Hay on 12/19/24.
//

import SwiftUI

struct RecordView: View {
    private let openAIClient = OpenAIClientWrapper()
    @State private var gptResponse: String? = nil
    @State private var isGenerating = false
    @State private var isTranscribing = false
    @State private var errorMessage: String? = nil
    @StateObject var transcriptionTuple: TranscriptionTuple
    @StateObject var audioManager: AudioRecorderManager
    let folder: Folder?
    
    @State var tupleName: String
    
    init(tupleName: String, folder: Folder? = nil) {
        self.tupleName = tupleName
        self.folder = folder
        let transcription = TranscriptionTuple(name: tupleName)
        _transcriptionTuple = StateObject(wrappedValue: transcription)
        _audioManager = StateObject(wrappedValue: AudioRecorderManager(transcriptionTuple: transcription))
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
                                    isGenerating: $isGenerating,
                                    isTranscribing: $isTranscribing)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                // Record Card
                LectureRecordCard(audioManager: audioManager, folder: folder!)
                    .padding(.horizontal)
                
                // Generate Card
                VStack(alignment: .leading, spacing: 16) {
                    Text("Generate Notes")
                        .font(.headline)
                    
                    Text("Transform your recording into organized notes using AI")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Button(action: generateNotes) {
                        HStack {
                            if isGenerating || isTranscribing {
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
                        .background(isGenerating || isTranscribing ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .animation(.easeInOut, value: isGenerating)
                        .animation(.easeInOut, value: isTranscribing)
                    }
                    .disabled(isGenerating || isTranscribing || !audioManager.hasRecording)
                    
                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.top, 4)
                    }
                }
                .padding()
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Display Notes
                if let response = gptResponse {
                    DisplayNotesCard(gptResponse: response, audioManager: audioManager)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .environmentObject(transcriptionTuple)
    }
    
    private var buttonText: String {
        if isTranscribing {
            return "Transcribing..."
        } else if isGenerating {
            return "Generating..."
        } else {
            return "Generate Notes"
        }
    }
    
    private func generateNotes() {
        isGenerating = true
        errorMessage = nil
        
        Task {
            do {
                let audioData = try audioManager.getAudioData()
                let audioSegments = try await audioManager.splitAudioIntoTwoMinuteSegments(from: audioData)
                let result = try await openAIClient.processAudioSegments(
                                    audioSegments: audioSegments,
                                    onUpdate: { streamUpdate in
                                        Task { @MainActor in
                                            self.gptResponse = streamUpdate
                                        }
                                    }
                                )
                
                await MainActor.run {
                    gptResponse = result
                    isGenerating = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Error: \(error.localizedDescription)"
                    isGenerating = false
                }
            }
        }
    }
}

#Preview {
    let previewData = TuplePreviewData()
    RecordView(tupleName: "How to pray", folder: previewData.dummyFolder)
}

