//
//  TranscriptionView.swift
//  Lectra
//
//  Created by Kyle-Anthony Hay on 2/19/25.
//

import SwiftUI
import MarkdownUI

struct TupleView: View {
    @StateObject var transcriptionTuple: TranscriptionTuple
    @StateObject var audioManager: AudioRecorderManager
    @State private var defaultResponse: String = "# Transcription Variable empty"
//    var folderManager: FolderManager
    
//    @Environment(\.modelContext) private var modelContext
//    let rootDirectory: RootDirectory
  
    
    init(transcriptionTuple: TranscriptionTuple) {
        _transcriptionTuple = StateObject(wrappedValue: transcriptionTuple)
        _audioManager = StateObject(wrappedValue: AudioRecorderManager.shared)

    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LectraColors.background.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header Section
                        HStack {
                            VStack(alignment: .leading) {
                                Text(transcriptionTuple.name)
                                    .font(.title2)
                                    .bold()
                                Text(formatDate(transcriptionTuple.createdAt))
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Button(action: {}) {
                                Image(systemName: "ellipsis")
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        
                        // Main Content
                        VStack(alignment: .leading, spacing: 16) {
                            // Audio Player Section
                            TupleCard(tuple: transcriptionTuple, audioManager: audioManager)
                                .padding(.horizontal, 20)
                            
                            // Transcription Section
                            if let transcription = transcriptionTuple.transcription?.text {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Transcription")
                                        .font(.headline)
                                        .foregroundColor(.gray)
                                    
                                    Markdown(transcription)
                                        .markdownTheme(.lectraClearBackground)
                                        .textSelection(.enabled)
                                        .padding(20)
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .environmentObject(transcriptionTuple)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}

#Preview {
    TupleView(transcriptionTuple: TuplePreviewData().dummyTuple)
}
