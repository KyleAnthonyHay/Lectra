//
//  PreviewData.swift
//  Lectra
//
//  Created by Kyle-Anthony Hay on 2/8/25.
//
import SwiftUI
import SwiftData

struct PreviewData {
    static var rootDirectory: RootDirectory {
        let rootDirectory = RootDirectory()
        rootDirectory.folders.append(Folder(name: "Work"))
        rootDirectory.folders.append(Folder(name: "Personal"))
        return rootDirectory
    }
}

struct TuplePreviewData {
    let dummyAudioFile: AudioFile
    let dummyTranscription: Transcription
    let dummyTuple: TranscriptionTuple
    var dummyTupleArray: [TranscriptionTuple] = []

    init() {
        // Load sample audio data from the app bundle
        var sampleData = Data()
        if let sampleAudioURL = Bundle.main.url(forResource: "LectraDemo", withExtension: "mp3"),
           let data = try? Data(contentsOf: sampleAudioURL) {
            sampleData = data
        } else {
            print("Failed to load sample audio data")
        }
        
        let audio = AudioFile(name: "Dummy Audio", audioData: sampleData)
        self.dummyAudioFile = audio
        
        let transcription = Transcription(associatedAudioFile: audio, text: "Sample transcription text.")
        self.dummyTranscription = transcription
        
        self.dummyTuple = TranscriptionTuple(
            name: "Sample Recording",
            audioFile: audio,
            transcription: transcription,
            createdAt: Date(timeIntervalSince1970: 0)
        )
        
        // Create 15 distinct instances for the array
       self.dummyTupleArray = (0..<15).map { _ in
           TranscriptionTuple(name: "Sample Recording", audioFile: audio, transcription: transcription)
       }
    }
}
