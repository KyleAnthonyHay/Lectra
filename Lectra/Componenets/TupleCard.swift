import SwiftUI

struct TupleCard: View {
    let tuple: TranscriptionTuple
    let audioManager: AudioRecorderManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "waveform")
                    .foregroundColor(LectraColors.brand)
                Text(tuple.name)
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
            }
            
            // Duration and Date
            HStack {
                Text("audioManager.duration")
                    .font(.caption)
                    .foregroundColor(LectraColors.textSecondary)
                Spacer()
                Text(formatDate(tuple.createdAt))
                    .font(.caption)
                    .foregroundColor(LectraColors.textSecondary)
            }
            
            // Playback Controls
            HStack(spacing: 20) {
                Button(action: {
                    if audioManager.isPlaying {
                        audioManager.stopAudio()
                    } else {
                        audioManager.playSwiftDataAudio(tuple: tuple)
                    }
                }) {
                    Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(LectraColors.brand)
                        .clipShape(Circle())
                }
                
                if audioManager.isPlaying {
                    // Progress Bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(LectraColors.brandLight)
                                .frame(height: 4)
                            
                            Rectangle()
                                .fill(LectraColors.brand)
                                .frame(width: geometry.size.width * 0.4, height: 4)
                        }
                    }
                    .frame(height: 4)
                }
            }
        }
        .padding()
        .background(LectraColors.secondaryBackground)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
} 
