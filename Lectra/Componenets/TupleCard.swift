import SwiftUI

struct TupleCard: View {
    let tuple: TranscriptionTuple
    @StateObject private var audioManager: AudioRecorderManager
    
    init(tuple: TranscriptionTuple, audioManager: AudioRecorderManager) {
        self.tuple = tuple
        _audioManager = StateObject(wrappedValue: audioManager)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with Name and Date
            HStack {
                Image(systemName: "waveform")
                    .foregroundColor(LectraColors.brand)
                Text(tuple.name)
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
                Text(formatDate(tuple.createdAt))
                    .font(.caption)
                    .foregroundColor(LectraColors.textSecondary)
            }
            
            // Playback Controls with inline Progress Bar
            HStack(spacing: 16) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        if audioManager.isPlaying {
                            audioManager.stopAudio()
                        } else {
                            audioManager.playSwiftDataAudio(tuple: tuple)
                        }
                    }
                }) {
                    Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(LectraColors.brand)
                        .clipShape(Circle())
                }
                
                if audioManager.isPlaying {
                    AudioProgressBar(audioManager: audioManager, showTimes: false)
                        .transition(.opacity)
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Time Display
            if audioManager.isPlaying {
                HStack {
                    Text(formatDuration(audioManager.currentTime))
                        .font(.caption)
                        .foregroundColor(LectraColors.textSecondary)
                    Spacer()
                    Text(formatDuration(audioManager.duration))
                        .font(.caption)
                        .foregroundColor(LectraColors.textSecondary)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
                .padding(.horizontal, 4)
            }
        }
        .padding()
        .background(LectraColors.secondaryBackground)
        .cornerRadius(12)
        .shadow(radius: 2)
        .animation(.easeInOut(duration: 0.3), value: audioManager.isPlaying)
        .onAppear {
            audioManager.setup(with: tuple)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    let tuple = TuplePreviewData().dummyTuple
    return TupleCard(
        tuple: tuple,
        audioManager: AudioRecorderManager.shared
    )
} 
