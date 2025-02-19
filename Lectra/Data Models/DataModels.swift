//
//  DataModels.swift
//  Lectra
//
//  Created by Kyle-Anthony Hay on 2/7/25.
//  command + option + forward slash
import Foundation
import SwiftData


/// Swift Data Object used to store audio files recorded by user
///
///     - id: unique identifier
///     - name: name of the audio file
///     - audioData: raw data of audio file
@Model
class AudioFile {
    @Attribute(.unique) var id: UUID
    var name: String
    var audioData: Data
    
    init(id: UUID = UUID(), name: String, audioData: Data) {
        self.id = id
        self.name = name
        self.audioData = audioData
    }
}


/// Swift Data Object used to store the Transcription as a `String`
///
///     - id: unique identifier
///     - associatedAudioFile: var that represents the relationship between this transcription and its audio counterpart
///     - text: transcription from OpenAI's Whisper model stored as a string
///
@Model
class Transcription {
    @Attribute(.unique) var id: UUID
    @Relationship var associatedAudioFile: AudioFile
    var text: String
    
    init(id: UUID = UUID(), associatedAudioFile: AudioFile, text: String) {
        self.id = id
        self.associatedAudioFile = associatedAudioFile
        self.text = text
    }
}

@Model
class TranscriptionTuple: ObservableObject {
    @Attribute(.unique) var id: UUID
    @Relationship(deleteRule: .cascade) var audioFile: AudioFile?
    @Relationship(deleteRule: .cascade) var transcription: Transcription?
    var createdAt: Date
    var name: String
    
    init(name: String, id: UUID = UUID(), audioFile: AudioFile? = nil, transcription: Transcription? = nil, createdAt: Date = Date()) {
        self.name = name
        self.id = id
        self.audioFile = audioFile
        self.transcription = transcription
        self.createdAt = createdAt
    }
}

@Model
class Folder {
    @Attribute(.unique) var id: UUID
    var name: String
    @Relationship(deleteRule: .cascade) var transcriptionTuples: [TranscriptionTuple]
    
    init(name: String, transcriptionTuples: [TranscriptionTuple] = []) {
        self.id = UUID()
        self.name = name
        self.transcriptionTuples = transcriptionTuples
    }
}

@Model
class RootDirectory {
    @Attribute(.unique) var id: UUID
    @Relationship var folders: [Folder]

    init(folders: [Folder] = [Folder(name: "Default Folder")]) {
        self.id = UUID()
        self.folders = folders
    }
}
