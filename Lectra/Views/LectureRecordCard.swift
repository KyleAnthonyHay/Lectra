//
//  LectureRecordCard.swift
//  Lectra
//
//  Created by Kyle-Anthony Hay on 12/20/24.
//

import SwiftUI
import AVFoundation
import SwiftData

struct LectureRecordCard: View {
    @ObservedObject var audioManager: AudioRecorderManager
    @EnvironmentObject var transcriptionTuple: TranscriptionTuple
    @Environment(\.modelContext) private var modelContext

    
    var body: some View {
        HStack(spacing: 25) {
            // MARK: Record/Stop Button
            Button(action: {
                audioManager.isRecording ? audioManager.stopRecording(modelContext: modelContext, transcriptionTuple: transcriptionTuple) : audioManager.startRecording()
            }) {
                Image(systemName: audioManager.isRecording ? "stop.circle.fill" : "record.circle.fill")
                    .resizable()
                    .foregroundColor(audioManager.isRecording ? .red : .icon)
                    .frame(width: 50, height: 50)
            }
            .padding(.leading, 16)

            // MARK: Playback Button
            Button(action: {
                audioManager.isPlaying ? audioManager.stopAudio() : audioManager.playAudio()
            }) {
                Image(systemName: audioManager.isPlaying ? "stop.fill" : "play.fill")
                    .resizable()
                    .foregroundColor(audioManager.isPlaying ? .icon : .icon)
                    .frame(width: 40, height: 40)
            }
            .padding(.trailing, 25)
            Spacer()
        }
        .frame(width: 360, height: 110)
        .background(Color.background)
        .cornerRadius(16)
        .shadow(radius: 12)
    }
}


#Preview {
    LectureRecordCard(audioManager: AudioRecorderManager(transcriptionTuple: TuplePreviewData().dummyTuple))
}

