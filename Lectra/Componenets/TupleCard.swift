import SwiftUI

struct TupleCard: View {
    let tuple: TranscriptionTuple
    let audioManager: AudioRecorderManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "waveform")
                    .foregroundColor(.blue)
                Text(tuple.name)
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
            }
            
            // Duration and Date
            HStack {
                Text("audioManager.duration")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Text(formatDate(tuple.createdAt))
                    .font(.caption)
                    .foregroundColor(.gray)
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
                        .background(Color.blue)
                        .clipShape(Circle())
                }
                
                if audioManager.isPlaying {
                    // Progress Bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 4)
                            
                            Rectangle()
                                .fill(Color.blue)
                                .frame(width: geometry.size.width * 4, height: 4)
                        }
                    }
                    .frame(height: 4)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
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
