import SwiftUI

struct AudioUploadButton: View {
    @State private var showingDocumentPicker = false
    @State private var isUploading = false
    @ObservedObject var audioRecorder: AudioRecorderManager
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var folderManager: FolderManager
    @State private var gptResponse: String? = nil
    @Binding var isGenerating: Bool
    @Binding var isTranscribing: Bool
    private let openAIClient = OpenAIClientWrapper()
    
    let transcriptionTuple: TranscriptionTuple
    let folder: Folder
    
    init(transcriptionTuple: TranscriptionTuple, folder: Folder, audioRecorder: AudioRecorderManager, isGenerating: Binding<Bool>, isTranscribing: Binding<Bool>) {
        self.transcriptionTuple = transcriptionTuple
        self.folder = folder
        self.audioRecorder = audioRecorder
        _isGenerating = isGenerating
        _isTranscribing = isTranscribing
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
        isTranscribing = true  // Start transcribing state
        
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
            
            // Save to both file system and SwiftData
            try audioRecorder.saveUploadedAudio(data: audioData, modelContext: modelContext, transcriptionTuple: transcriptionTuple)
            
            // Clean up the temporary file
            try? FileManager.default.removeItem(at: tempURL)
            
            // Add the tuple to the folder
            folderManager.add(tuple: transcriptionTuple, to: folder)
            
            // Process audio segments and generate notes
            let audioSegments = try await audioRecorder.splitAudioIntoTwoMinuteSegments(from: audioData)
            
            // First handle transcription
            let result = try await openAIClient.processAudioSegments(
                audioSegments: audioSegments,
                onUpdate: { streamUpdate in
                    Task { @MainActor in
                        gptResponse = streamUpdate
                        // Create and save transcription as it's being generated
                        if transcriptionTuple.transcription == nil {
                            let newTranscription = Transcription(associatedAudioFile: transcriptionTuple.audioFile!, text: streamUpdate)
                            transcriptionTuple.transcription = newTranscription
                            try? modelContext.save()
                        } else {
                            transcriptionTuple.transcription?.text = streamUpdate
                            try? modelContext.save()
                        }
                    }
                }
            )
            
            await MainActor.run {
                // Final save of the complete transcription
                if transcriptionTuple.transcription == nil {
                    let newTranscription = Transcription(associatedAudioFile: transcriptionTuple.audioFile!, text: result)
                    transcriptionTuple.transcription = newTranscription
                } else {
                    transcriptionTuple.transcription?.text = result
                }
                try? modelContext.save()
                
                // Reset all state variables
                isTranscribing = false
                isGenerating = false
                isUploading = false
                
                // Important: Do NOT clear the audio file here since we need it for generating notes
            }
        } catch {
            print("Error handling file upload: \(error)")
            await MainActor.run {
                // Reset all state variables on error
                isUploading = false
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