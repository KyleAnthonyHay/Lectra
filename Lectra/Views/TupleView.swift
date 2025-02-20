//
//  TranscriptionView.swift
//  Lectra
//
//  Created by Kyle-Anthony Hay on 2/19/25.
//

import SwiftUI

struct TupleView: View {
    @StateObject var transcriptionTuple: TranscriptionTuple
    @StateObject var audioManager: AudioRecorderManager
    
    init(transcriptionTuple: TranscriptionTuple) {
        _transcriptionTuple = StateObject(wrappedValue: transcriptionTuple)
        _audioManager = StateObject(wrappedValue: AudioRecorderManager(transcriptionTuple: transcriptionTuple))
    }
    
    var body: some View {
        VStack(spacing: 0) {
                    // MARK: Top View
                    VStack {
                        // Title
                        HStack (spacing: 0){
                            Image(systemName: "folder.fill")
                            Text(transcriptionTuple.name)
                                .font(.headline)
                                .padding()
                            
                            Spacer()
                        }
                        // Record Card
                        TVPlaybackCard(audioManager: audioManager)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.2))
                    
                    // MARK: Scrollview
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Getting Started")
                            Text("Quick Note")
                            Text("Personal Home")
                            Text("Task List")
                            Text("Journal")
                            Text("Reading List")
                            Text("LeetCode Reviews")
                        }
                        .padding()
                    }
                }
                .environmentObject(transcriptionTuple)
    }
}

#Preview {
    TupleView(transcriptionTuple: TuplePreviewData().dummyTuple)
}
