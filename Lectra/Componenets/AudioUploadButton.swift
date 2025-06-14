import SwiftUI

struct AudioUploadButton: View {
    @State private var showingDocumentPicker = false
    @State private var isUploading = false
    @StateObject private var audioRecorder: AudioRecorderManager
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var folderManager: FolderManager
    @State private var gptResponse: String? = nil
    @Binding var isGenerating: Bool
    @Binding var isTranscribing: Bool
    @EnvironmentObject private var openAIClient: OpenAIClientWrapper
    @EnvironmentObject private var assemblyAIClient: AssemblyAIClient
    
    let transcriptionTuple: TranscriptionTuple
    let folder: Folder
    
    init(transcriptionTuple: TranscriptionTuple, folder: Folder, isGenerating: Binding<Bool>, isTranscribing: Binding<Bool>) {
        self.transcriptionTuple = transcriptionTuple
        self.folder = folder
        _isGenerating = isGenerating
        _isTranscribing = isTranscribing
        _audioRecorder = StateObject(wrappedValue: AudioRecorderManager.shared)
    }
    
    var body: some View {
        Menu {
            Button(action: {
                showingDocumentPicker = true
            }) {
                Label("Upload Audio", systemImage: "square.and.arrow.up")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .font(.title2)
                .foregroundColor(.primary)
        }
        .sheet(isPresented: $showingDocumentPicker) {
            DocumentPickerView { url in
                Task {
                    await handleFileUpload(from: url)
                }
            }
        }
    }
    
    private func handleFileUpload(from url: URL) async {
        isUploading = true
        await MainActor.run {
            audioRecorder.isTranscribing = true  // Start transcribing state
        }
        
        do {
            // Create a local copy of the file in the app's temporary directory
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(url.lastPathComponent)
            
            // Start accessing the security-scoped resource
            guard url.startAccessingSecurityScopedResource() else {
                throw NSError(domain: "com.lectra", code: 1, userInfo: [NSLocalizedDescriptionKey: "Permission denied to access file"])
            }
            
            defer {
                url.stopAccessingSecurityScopedResource()
            }
            
            // Copy the file to our temporary location
            try FileManager.default.copyItem(at: url, to: tempURL)
            
            // Now read the data from our temporary copy
            let audioData = try Data(contentsOf: tempURL)
            
            // Clean up the temporary file
            try? FileManager.default.removeItem(at: tempURL)
            
            let audioFile = AudioFile(name: transcriptionTuple.name, audioData: audioData)
            transcriptionTuple.audioFile = audioFile
            try modelContext.save()
            
            // Add the tuple to the folder
            folderManager.add(tuple: transcriptionTuple, to: folder)
            
            // Setup AudioRecorderManager with the audio data
            await MainActor.run {
                audioRecorder.setupWithAudioData(tuple: transcriptionTuple, audioData: audioData)
            }
            
            // Process audio file directly using AssemblyAI for transcription
            
            // First handle transcription with AssemblyAI
            print("Starting transcription with AssemblyAI...")
            let transcriptionResult = try await assemblyAIClient.processAudioFile(
                audioData: audioData,
                onUpdate: { updateStatus in
                    Task { @MainActor in
                        // Save status updates during transcription process
                        let statusMessage = "Transcription in progress: \(updateStatus)"
                        audioRecorder.saveTranscription(
                            modelContext: modelContext,
                            tuple: transcriptionTuple,
                            transcription: statusMessage
                        )
                    }
                }
            )
            
            print("Transcription completed! AssemblyAI result:")
            print("--------- TRANSCRIPTION START ---------")
            print(transcriptionResult)
            print("--------- TRANSCRIPTION END ---------")
            print("Sending to OpenAI for summarization...")
            
            // Save the raw transcription before summarizing
            await MainActor.run {
                audioRecorder.saveTranscription(
                    modelContext: modelContext,
                    tuple: transcriptionTuple,
                    transcription: "Raw Transcription:\n\n\(transcriptionResult)"
                )
            }
            
            // Then send the transcription to OpenAI for summarization
            let result = try await openAIClient.processChatCompletion(
                transcription: transcriptionResult,
                onUpdate: { streamUpdate in
                    Task { @MainActor in
                        gptResponse = streamUpdate
                        // Save the summary as it's being generated
                        audioRecorder.saveTranscription(
                            modelContext: modelContext,
                            tuple: transcriptionTuple,
                            transcription: streamUpdate
                        )
                    }
                }
            )
            
            await MainActor.run {
                // Final save of the complete transcription
                audioRecorder.saveTranscription(
                    modelContext: modelContext,
                    tuple: transcriptionTuple,
                    transcription: result
                )
                audioRecorder.isTranscribing = false  // End transcribing state
                isTranscribing = false
                isGenerating = true  // Start generating state
                
                // Note generation would happen here...
                
                isUploading = false
                isGenerating = false  // End generating state
            }
        } catch {
            print("Error handling file upload: \(error)")
            await MainActor.run {
                isUploading = false
                audioRecorder.isTranscribing = false
                isTranscribing = false
                isGenerating = false
            }
        }
    }
}

private struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
            VStack {
                ProgressView()
                    .tint(.white)
                Text("Uploading...")
                    .foregroundColor(.white)
                    .padding(.top)
            }
        }
        .ignoresSafeArea()
    }
}

private struct SuccessOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
            VStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.green)
                Text("Upload Complete!")
                    .foregroundColor(.white)
                    .padding(.top)
            }
        }
        .ignoresSafeArea()
    }
} 
