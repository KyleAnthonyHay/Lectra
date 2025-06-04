import Foundation
import SwiftUI
import AVFoundation
import SwiftData

class AudioRecorderManager: NSObject, ObservableObject {
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var audioFileURL: URL

    @Published var isRecording = false
    @Published var isPlaying = false
    @Published var hasRecording = false
    @Published var duration: TimeInterval = 0
    @Published var currentTime: TimeInterval = 0
    @Published var streamedTranscription: String = ""
    private var timer: Timer?
    private let openAIClient = OpenAIClientWrapper()

    init(transcriptionTuple: TranscriptionTuple) {
        // Set the path to Documents/Transcriptions
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioRecordingDirectory = documentsDirectory.appending(path: "AudioRecordings")

        // Ensure the directory exists
        if !FileManager.default.fileExists(atPath: audioRecordingDirectory.path) {
            do {
                try FileManager.default.createDirectory(at: audioRecordingDirectory, withIntermediateDirectories: true, attributes: nil)
                print("Transcriptions directory created")
            } catch {
                print("Failed to create Transcriptions directory: \(error.localizedDescription)")
            }
        }

        // Define the file path for recordings
        audioFileURL = audioRecordingDirectory.appendingPathComponent("Lecture-Recording.m4a")
        
        super.init()
        configureAudioSession()
        checkForExistingRecording()
    }

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
            print("Audio session configured successfully")
        } catch {
            print("Failed to configure AVAudioSession: \(error.localizedDescription)")
        }
    }
    
    private func checkForExistingRecording() {
        hasRecording = FileManager.default.fileExists(atPath: audioFileURL.path)
        if hasRecording {
            do {
                let player = try AVAudioPlayer(contentsOf: audioFileURL)
                duration = player.duration
            } catch {
                print("Error getting audio duration: \(error)")
            }
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.audioPlayer else { return }
            self.currentTime = player.currentTime
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        currentTime = 0
    }

    func startRecording() {
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFileURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            isRecording = true
            print("Started recording")
        } catch {
            print("Failed to start recording: \(error.localizedDescription)")
        }
    }
    
    func stopRecording(modelContext: ModelContext, transcriptionTuple: TranscriptionTuple) {
        audioRecorder?.stop()
        isRecording = false
        hasRecording = true
        
        // Get the duration of the recording
        if let player = try? AVAudioPlayer(contentsOf: audioFileURL) {
            duration = player.duration
        }
        
        // Create and save AudioFile
        do {
            let audioData = try Data(contentsOf: audioFileURL)
            let audioFile = AudioFile(name: transcriptionTuple.name, audioData: audioData)
            transcriptionTuple.audioFile = audioFile
            try modelContext.save()
            print("Successfully saved audio file")
        } catch {
            print("Failed to save audio file: \(error)")
        }
    }
    
    func playAudio() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioFileURL)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            isPlaying = true
            startTimer()
            print("Started playing audio")
        } catch {
            print("Failed to play audio: \(error.localizedDescription)")
        }
    }
    
    func stopAudio() {
        audioPlayer?.stop()
        isPlaying = false
        stopTimer()
        print("Stopped playing audio")
    }
    
    func playSwiftDataAudio(tuple: TranscriptionTuple) {
        guard let audioFile = tuple.audioFile else {
            print("No audio file found")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(data: audioFile.audioData)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            isPlaying = true
            startTimer()
            print("Started playing SwiftData audio")
        } catch {
            print("Failed to play SwiftData audio: \(error.localizedDescription)")
        }
    }
    
    func getAudioData() throws -> Data {
        return try Data(contentsOf: audioFileURL)
    }
    
    func saveTranscription(modelContext: ModelContext, tuple: TranscriptionTuple, transcription: String) {
        
        if tuple.transcription == nil {
            let newTranscription = Transcription(associatedAudioFile: tuple.audioFile!, text: transcription)
            tuple.transcription = newTranscription
        }
        
        do {
            // Save the updated tuple in the model context.
            try modelContext.save()
            print("Transcription updated successfully.")
        } catch {
            print("Error saving transcription: \(error.localizedDescription)")
        }
    }
    
    func processAudioWithStreaming() async throws {
        guard let audioFile = try? getAudioData() else {
            print("No audio data available")
            return
        }
        
        let segments = try await splitAudioIntoTwoMinuteSegments(from: audioFile)
        
        // Process segments with streaming updates
        let transcription = try await openAIClient.processAudioSegments(audioSegments: segments) { [weak self] update in
            Task { @MainActor in
                self?.streamedTranscription = update
            }
        }
        
        // Final update with complete transcription
        await MainActor.run {
            self.streamedTranscription = transcription
        }
    }
    
}

// MARK: Audio Splitting
extension AudioRecorderManager {
    func splitAudioIntoTwoMinuteSegments(from audioData: Data) async throws -> [Data] {
        // Create a temporary file to work with AVAsset
        let tempDirectory = FileManager.default.temporaryDirectory
        let tempURL = tempDirectory.appendingPathComponent(UUID().uuidString + ".m4a")
        try audioData.write(to: tempURL)
        
        let asset = AVURLAsset(url: tempURL)
        let duration = try await asset.load(.duration)
        let durationInSeconds = CMTimeGetSeconds(duration)
        let segmentDuration: Double = 120 // 2 minutes is 120 seconds
        let numberOfSegments = Int(ceil(durationInSeconds / segmentDuration))
        var segments: [Data] = []
        
        for i in 0..<numberOfSegments {
            let startTime = Double(i) * segmentDuration
            let segmentTime = min(segmentDuration, durationInSeconds - startTime)
            
            let timeRange = CMTimeRange(
                start: CMTime(seconds: startTime, preferredTimescale: 1000),
                duration: CMTime(seconds: segmentTime, preferredTimescale: 1000)
            )
            
            let segmentURL = tempDirectory.appendingPathComponent("segment_\(i).m4a")
            
            // Create export session for this segment
            guard let exportSession = AVAssetExportSession(
                asset: asset,
                presetName: AVAssetExportPresetAppleM4A
            ) else {
                continue
            }
            
            exportSession.outputURL = segmentURL
            exportSession.outputFileType = .m4a
            exportSession.timeRange = timeRange
            
            do {
                // Use the new async/throws export method
                try await exportSession.export(to: segmentURL, as: .m4a)
                
                if let segmentData = try? Data(contentsOf: segmentURL) {
                    segments.append(segmentData)
                }
            } catch {
                print("Export error for segment \(i): \(error.localizedDescription)")
            }
            
            // Clean up segment file
            try? FileManager.default.removeItem(at: segmentURL)
        }
        
        // Clean up temporary file
        try? FileManager.default.removeItem(at: tempURL)
        
        return segments
    }
}

extension AudioRecorderManager: AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        isRecording = false
        hasRecording = flag
        if flag {
            if let player = try? AVAudioPlayer(contentsOf: audioFileURL) {
                duration = player.duration
            }
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        stopTimer()
    }
}

