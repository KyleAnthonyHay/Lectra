//
//  TVPlaybackCard.swift
//  Lectra
//
//  Created by Kyle-Anthony Hay on 2/19/25.
//

import SwiftUI
import AVFoundation
import SwiftData

struct TVPlaybackCard: View {
    @EnvironmentObject var transcriptionTuple: TranscriptionTuple
    @ObservedObject var audioManager: AudioRecorderManager
    
    
    var body: some View {
        HStack {
            // MARK: Playback Button
            Button(action: {
                audioManager.isPlaying ? audioManager.stopAudio() : audioManager.playSwiftDataAudio(tuple: transcriptionTuple)
            }) {
                Image(systemName: audioManager.isPlaying ? "stop.fill" : "play.fill")
                    .resizable()
                    .foregroundColor(audioManager.isPlaying ? .icon : .icon)
                    .frame(width: 28, height: 28)
            }
            .padding(.leading, 25)
            Spacer()
        }
        .frame(width: 328, height: 68)
        .background(Color.background)
        .cornerRadius(16)
        .shadow(radius: 12)
    }
}

#Preview {
    let tuple = TuplePreviewData().dummyTuple
    AudioRecorderManager.shared.setup(with: tuple)
    return TVPlaybackCard(audioManager: AudioRecorderManager.shared)
}
