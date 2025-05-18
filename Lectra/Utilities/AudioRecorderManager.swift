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

    func startRecording() {
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFileURL, settings: settings)
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()
            isRecording = true
            print("Recording started successfully at \(audioFileURL.path)")
        } catch {
            print("Error starting recording: \(error.localizedDescription)")
        }
    }

    func stopRecording(modelContext: ModelContext? = nil, transcriptionTuple: TranscriptionTuple) {
        audioRecorder?.stop()
        isRecording = false
        print("Recording stopped successfully. File saved at \(audioFileURL.path)")
        
        if let context = modelContext {
            do {
                let audioData = try getAudioData()
                let audioFile = AudioFile(name: transcriptionTuple.name, audioData: audioData)
                transcriptionTuple.audioFile = audioFile
                context.insert(transcriptionTuple)
                try context.save()
                print("CoreData: Save Successful :)")
            } catch {
                print("Error Saving audio Data to SwiftData: \(error.localizedDescription)")
            }
        }
    }

    func playAudio() {
        guard !isRecording else {
            print("Cannot play while recording")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioFileURL)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            isPlaying = true
            print("Audio playback started")
        } catch {
            print("Failed to play audio: \(error.localizedDescription)")
        }
    }
    
    func playSwiftDataAudio(tuple: TranscriptionTuple) {
        guard !isRecording else {
            print("Cannot play while recording")
            return
        }
        // Safely unwrap the optional audioData
        guard let audioData = tuple.audioFile?.audioData else {
            print("No audio data available")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(data: audioData)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            isPlaying = true
            print("Audio playback started from SwiftData audio")
        } catch {
            print("Failed to play swift data audio: \(error.localizedDescription)")
        }
    }

    func stopAudio() {
        audioPlayer?.stop()
        isPlaying = false
        print("Audio playback stopped")
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

extension AudioRecorderManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        print("Audio playback finished")
    }
}

