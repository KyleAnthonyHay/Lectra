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
    @EnvironmentObject private var folderManager: FolderManager
    let folder: Folder
    
    @State private var isAnimating = false
    
    private var formattedDuration: String {
        let minutes = Int(audioManager.duration) / 60
        let seconds = Int(audioManager.duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private var formattedCurrentTime: String {
        let minutes = Int(audioManager.currentTime) / 60
        let seconds = Int(audioManager.currentTime) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Waveform Visualization
            HStack(spacing: 3) {
                ForEach(0..<30) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.blue.opacity(0.5))
                        .frame(width: 3, height: audioManager.isRecording ? CGFloat.random(in: 10...40) : 20)
                        .animation(
                            audioManager.isRecording ?
                            Animation.easeInOut(duration: 0.5)
                                .repeatForever()
                                .delay(Double(index) * 0.05) :
                            .default,
                            value: audioManager.isRecording
                        )
                }
            }
            .frame(height: 40)
            .padding(.horizontal)
            
            // Controls
            HStack(spacing: 30) {
                // Record Button
                Button(action: {
                    if audioManager.isRecording {
                        audioManager.stopRecording(modelContext: modelContext, transcriptionTuple: transcriptionTuple)
                        folderManager.add(tuple: transcriptionTuple, to: folder)
                    } else {
                        audioManager.startRecording()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(audioManager.isRecording ? LectraColors.error : LectraColors.brand)
                            .frame(width: 60, height: 60)
                            .shadow(radius: 4)
                        
                        Image(systemName: audioManager.isRecording ? "stop.fill" : "mic.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 24))
                    }
                }
                
                // Play Button (only show if there's a recording)
                if audioManager.hasRecording {
                    Button(action: {
                        if audioManager.isPlaying {
                            audioManager.stopAudio()
                        } else {
                            audioManager.playAudio()
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(LectraColors.background)
                                .frame(width: 50, height: 50)
                                .shadow(radius: 4)
                            
                            Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                                .foregroundColor(LectraColors.brand)
                                .font(.system(size: 22))
                        }
                    }
                }
            }
            
            // Time Display
            if audioManager.hasRecording {
                HStack {
                    Text(formattedCurrentTime)
                        .font(.caption)
                        .foregroundColor(LectraColors.textSecondary)
                    
                    // Progress Bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(LectraColors.brandLight)
                                .frame(height: 4)
                                .cornerRadius(2)
                            
                            Rectangle()
                                .fill(LectraColors.brand)
                                .frame(width: geometry.size.width * (audioManager.currentTime / max(audioManager.duration, 1)))
                                .frame(height: 4)
                                .cornerRadius(2)
                        }
                    }
                    .frame(height: 4)
                    
                    Text(formattedDuration)
                        .font(.caption)
                        .foregroundColor(LectraColors.textSecondary)
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(LectraColors.background)
        .cornerRadius(16)
        .shadow(radius: 8)
    }
}

#Preview {
    let tuple = TuplePreviewData().dummyTuple
    AudioRecorderManager.shared.setup(with: tuple)
    return LectureRecordCard(
        audioManager: AudioRecorderManager.shared,
        folder: TuplePreviewData().dummyFolder
    )
}

