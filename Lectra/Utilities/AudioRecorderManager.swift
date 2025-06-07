import Foundation
import SwiftUI
import AVFoundation
import SwiftData

final class AudioRecorderManager: NSObject, ObservableObject {
    static let shared = AudioRecorderManager()
    private(set) var transcriptionTuple: TranscriptionTuple?
    
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var audioFileURL: URL!

    @Published var isRecording = false
    @Published var isPlaying = false
    @Published var hasRecording = false
    @Published var duration: TimeInterval = 0
    @Published var currentTime: TimeInterval = 0
    @Published var streamedTranscription: String = ""
    @Published var isTranscribing = false
    private var timer: Timer?
    private let openAIClient = OpenAIClientWrapper()

    private override init() {
        super.init()
    }
    
    func setup(with transcriptionTuple: TranscriptionTuple) {
        print("AudioRecorderManager: Setting up new session")
        self.transcriptionTuple = transcriptionTuple
        
        // Reset all state variables
        isRecording = false
        isPlaying = false
        hasRecording = false
        duration = 0
        currentTime = 0
        streamedTranscription = ""
        
        // Set the path to Documents/Transcriptions
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioRecordingDirectory = documentsDirectory.appending(path: "AudioRecordings")

        // Ensure the directory exists
        if !FileManager.default.fileExists(atPath: audioRecordingDirectory.path) {
            do {
                try FileManager.default.createDirectory(at: audioRecordingDirectory, withIntermediateDirectories: true, attributes: nil)
                print("AudioRecorderManager: Transcriptions directory created")
            } catch {
                print("AudioRecorderManager: Failed to create Transcriptions directory: \(error.localizedDescription)")
            }
        }

        // Define the file path for recordings
        audioFileURL = audioRecordingDirectory.appendingPathComponent("Lecture-Recording.m4a")
        
        // Clean up any existing recording file
        if FileManager.default.fileExists(atPath: audioFileURL.path) {
            do {
                try FileManager.default.removeItem(at: audioFileURL)
                print("AudioRecorderManager: Removed existing recording file")
            } catch {
                print("AudioRecorderManager: Failed to remove existing recording: \(error.localizedDescription)")
            }
        }
        
        configureAudioSession()
        print("AudioRecorderManager: Setup completed")
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
        guard FileManager.default.fileExists(atPath: audioFileURL.path) else {
            print("Audio file does not exist at path: \(audioFileURL.path)")
            throw AudioError.fileNotFound
        }
        
        do {
            let data = try Data(contentsOf: audioFileURL)
            print("Successfully retrieved audio data: \(data.count) bytes")
            return data
        } catch {
            print("Failed to read audio data: \(error)")
            throw AudioError.failedToReadData(error)
        }
    }
    
    func saveTranscription(modelContext: ModelContext, tuple: TranscriptionTuple, transcription: String) {
        print("AudioRecorderManager: Starting saveTranscription")
        print("AudioRecorderManager: Tuple provided: \(tuple)")
        print("AudioRecorderManager: Current transcriptionTuple: \(String(describing: transcriptionTuple))")
        
        guard let audioFile = tuple.audioFile else {
            print("AudioRecorderManager: No audio file found")
            return
        }
        
        print("AudioRecorderManager: Audio file found, creating transcription")
        
        if tuple.transcription == nil {
            let newTranscription = Transcription(associatedAudioFile: audioFile, text: transcription)
            tuple.transcription = newTranscription
            print("AudioRecorderManager: Created new transcription")
        } else {
            tuple.transcription?.text = transcription
            print("AudioRecorderManager: Updated existing transcription")
        }
        
        do {
            // Save the updated tuple in the model context.
            try modelContext.save()
            print("AudioRecorderManager: Transcription saved successfully")
        } catch {
            print("AudioRecorderManager: Error saving transcription: \(error.localizedDescription)")
        }
    }
    
    func processAudioWithStreaming() async throws {
        print("AudioRecorderManager: Starting audio processing with streaming...")
        guard transcriptionTuple != nil else {
            print("AudioRecorderManager: No transcription tuple set")
            throw AudioError.fileNotFound
        }
        
        guard FileManager.default.fileExists(atPath: audioFileURL.path) else {
            print("AudioRecorderManager: No audio file found at: \(audioFileURL.path)")
            throw AudioError.fileNotFound
        }
        
        do {
            let audioData = try getAudioData()
            print("AudioRecorderManager: Audio data retrieved, size: \(audioData.count) bytes")
            
            let segments = try await splitAudioIntoTwoMinuteSegments(from: audioData)
            print("AudioRecorderManager: Split audio into \(segments.count) segments")
            
            // Process segments with streaming updates
            let transcription = try await openAIClient.processAudioSegments(audioSegments: segments) { [weak self] update in
                print("AudioRecorderManager: Received streaming update: \(update.prefix(50))...")
                Task { @MainActor in
                    print("AudioRecorderManager: Setting streamedTranscription on MainActor")
                    self?.streamedTranscription = update
                    print("AudioRecorderManager: streamedTranscription set to: \(update.prefix(50))...")
                }
            }
            
            // Final update with complete transcription
            print("AudioRecorderManager: Transcription completed successfully")
            await MainActor.run {
                print("AudioRecorderManager: Setting final streamedTranscription")
                self.streamedTranscription = transcription
                print("AudioRecorderManager: Final streamedTranscription set")
            }
        } catch {
            print("AudioRecorderManager: Error in processAudioWithStreaming: \(error)")
            if let audioError = error as? AudioError {
                throw audioError
            } else {
                throw AudioError.processingFailed(error)
            }
        }
    }
    
    func setupWithAudioData(tuple: TranscriptionTuple, audioData: Data) {
        print("AudioRecorderManager: Setting up with audio data")
        self.transcriptionTuple = tuple
        
        // Reset state variables
        isRecording = false
        isPlaying = false
        streamedTranscription = ""
        currentTime = 0
        
        // Set up the file path
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioRecordingDirectory = documentsDirectory.appendingPathComponent("AudioRecordings")
        
        // Ensure the directory exists
        if !FileManager.default.fileExists(atPath: audioRecordingDirectory.path) {
            do {
                try FileManager.default.createDirectory(at: audioRecordingDirectory, withIntermediateDirectories: true, attributes: nil)
                print("AudioRecorderManager: Created AudioRecordings directory")
            } catch {
                print("AudioRecorderManager: Failed to create directory: \(error.localizedDescription)")
            }
        }
        
        // Set up the audio file URL and save the data
        audioFileURL = audioRecordingDirectory.appendingPathComponent("Lecture-Recording.m4a")
        do {
            try audioData.write(to: audioFileURL)
            print("AudioRecorderManager: Saved audio data to file")
            
            // Set up audio player to get duration
            let player = try AVAudioPlayer(data: audioData)
            duration = player.duration
            hasRecording = true
            print("AudioRecorderManager: Successfully set up with audio duration: \(duration)")
        } catch {
            print("AudioRecorderManager: Failed to handle audio data: \(error.localizedDescription)")
            hasRecording = false
            duration = 0
        }
        
        configureAudioSession()
    }
    
}

// MARK: Audio Splitting
extension AudioRecorderManager {
    func splitAudioIntoTwoMinuteSegments(from audioData: Data) async throws -> [Data] {
        print("Starting audio splitting process...")
        
        // Create a temporary file to work with AVAsset
        let tempDirectory = FileManager.default.temporaryDirectory
        let tempURL = tempDirectory.appendingPathComponent(UUID().uuidString + ".m4a")
        
        do {
            try audioData.write(to: tempURL)
            print("Temporary audio file created at: \(tempURL.path)")
            
            let asset = AVURLAsset(url: tempURL)
            let duration = try await asset.load(.duration)
            let durationInSeconds = CMTimeGetSeconds(duration)
            print("Audio duration: \(durationInSeconds) seconds")
            
            let segmentDuration: Double = 120 // 2 minutes
            let numberOfSegments = Int(ceil(durationInSeconds / segmentDuration))
            var segments: [Data] = []
            
            print("Splitting into \(numberOfSegments) segments...")
            
            for i in 0..<numberOfSegments {
                let startTime = Double(i) * segmentDuration
                let segmentTime = min(segmentDuration, durationInSeconds - startTime)
                
                let timeRange = CMTimeRange(
                    start: CMTime(seconds: startTime, preferredTimescale: 1000),
                    duration: CMTime(seconds: segmentTime, preferredTimescale: 1000)
                )
                
                let segmentURL = tempDirectory.appendingPathComponent("segment_\(i).m4a")
                
                guard let exportSession = AVAssetExportSession(
                    asset: asset,
                    presetName: AVAssetExportPresetAppleM4A
                ) else {
                    print("Failed to create export session for segment \(i)")
                    continue
                }
                
                exportSession.outputURL = segmentURL
                exportSession.outputFileType = .m4a
                exportSession.timeRange = timeRange
                
                do {
                    print("Exporting segment \(i)...")
                    try await exportSession.export(to: segmentURL, as: .m4a)
                    
                    if let segmentData = try? Data(contentsOf: segmentURL) {
                        segments.append(segmentData)
                        print("Successfully exported segment \(i): \(segmentData.count) bytes")
                    }
                } catch {
                    print("Export error for segment \(i): \(error.localizedDescription)")
                }
                
                try? FileManager.default.removeItem(at: segmentURL)
            }
            
            // Clean up temporary file
            try? FileManager.default.removeItem(at: tempURL)
            
            print("Audio splitting completed. Total segments: \(segments.count)")
            return segments
        } catch {
            print("Error in splitAudioIntoTwoMinuteSegments: \(error)")
            throw error
        }
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

// Add custom error types
enum AudioError: Error {
    case fileNotFound
    case failedToReadData(Error)
    case failedToSplit(Error)
    case exportFailed(Error)
    case processingFailed(Error)
    
    var localizedDescription: String {
        switch self {
        case .fileNotFound:
            return "Audio file not found"
        case .failedToReadData(let error):
            return "Failed to read audio data: \(error.localizedDescription)"
        case .failedToSplit(let error):
            return "Failed to split audio: \(error.localizedDescription)"
        case .exportFailed(let error):
            return "Failed to export audio: \(error.localizedDescription)"
        case .processingFailed(let error):
            return "Failed to process audio: \(error.localizedDescription)"
        }
    }
}

