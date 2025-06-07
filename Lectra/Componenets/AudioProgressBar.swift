//
//  AudioProgressBar.swift
//  Lectra
//
//  Created by Kyle-Anthony Hay on 3/19/24.
//

import SwiftUI

struct AudioProgressBar: View {
    @ObservedObject var audioManager: AudioRecorderManager
    var showTimes: Bool = true
    
    private var formattedCurrentTime: String {
        let minutes = Int(audioManager.currentTime) / 60
        let seconds = Int(audioManager.currentTime) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private var formattedDuration: String {
        let minutes = Int(audioManager.duration) / 60
        let seconds = Int(audioManager.duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private var progress: CGFloat {
        let progress = audioManager.currentTime / max(audioManager.duration, 1)
        return min(max(progress, 0), 1) // Ensure progress is between 0 and 1
    }
    
    var body: some View {
        HStack(spacing: 8) {
            if showTimes {
                Text(formattedCurrentTime)
                    .font(.caption)
                    .foregroundColor(LectraColors.textSecondary)
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(LectraColors.brandLight)
                        .frame(height: 4)
                        .cornerRadius(2)
                    
                    Rectangle()
                        .fill(LectraColors.brand)
                        .frame(width: min(geometry.size.width * progress, geometry.size.width))
                        .frame(height: 4)
                        .cornerRadius(2)
                }
            }
            .frame(height: 4)
            
            if showTimes {
                Text(formattedDuration)
                    .font(.caption)
                    .foregroundColor(LectraColors.textSecondary)
            }
        }
    }
}

#Preview {
    let tuple = TuplePreviewData().dummyTuple
    AudioRecorderManager.shared.setup(with: tuple)
    return AudioProgressBar(audioManager: AudioRecorderManager.shared)
} 