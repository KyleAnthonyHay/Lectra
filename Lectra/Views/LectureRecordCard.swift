//
//  LectureRecordCard.swift
//  Lectra
//
//  Created by Kyle-Anthony Hay on 12/20/24.
//

import SwiftUI
import AVFoundation

struct LectureRecordCard: View {
    @State private var audioRecorder: AVAudioRecorder?
    @State private var isRecording = false
    
    let openAIClient = OpenAIClientWrapper()

    var body: some View {
        HStack {
            // Record Button
            Button(action: {
                isRecording ? stopRecording() : startRecording()
            }) {
                Image(systemName: isRecording ? "stop.circle.fill" : "record.circle.fill")
                    .resizable()
                    .foregroundColor(isRecording ? .red : .icon)
                    .frame(width: 50, height: 50)
            }
            .padding(.leading, 16)

            Spacer()
        }
        .frame(width: 360, height: 110)
        .background(Color.background)
        .cornerRadius(16)
        .shadow(radius: 12)
        .onAppear {
            configureAudioSession()
            setupAudioRecorder()
            listDocumentFiles()
        }
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

    private func setupAudioRecorder() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFileURL = documentsDirectory.appendingPathComponent("Lecture-Recording.m4a")

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0, // Ensure it's a Double
            AVNumberOfChannelsKey: 1, // Use mono
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFileURL, settings: settings)
            audioRecorder?.prepareToRecord()
            print("Audio Recorder setup successfully")
        } catch {
            print("Failed to set up audio recorder: \(error.localizedDescription)")
        }
    }

    private func startRecording() {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            audioRecorder?.record()
            isRecording = true
            print("Recording started successfully")
        } catch {
            print("Error starting recording: \(error.localizedDescription)")
        }
    }

    private func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        print("Recording stopped successfully")
        
        if let audioURL = audioRecorder?.url {
            do {
                let audioData = try Data(contentsOf: audioURL)
                let task = openAIClient.processSpeechTask(audioData: audioData)
                
                Task {
                    do {
                        let result = try await task.value // Wait for the transcription
                        print("Transcription Result: \(result)") // Print to terminal
                    } catch {
                        print("Error processing speech: \(error.localizedDescription)")
                    }
                }
            } catch {
                print("Failed to load audio data: \(error.localizedDescription)")
            }
        } else {
            print("Audio recorder URL is nil")
        }
    }



    private func listDocumentFiles() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: documentsDirectory.path)
            print("Files in document directory: \(files)")
        } catch {
            print("Error listing files: \(error.localizedDescription)")
        }
    }
}

#Preview {
    LectureRecordCard()
}
