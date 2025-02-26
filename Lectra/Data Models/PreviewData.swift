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
        // Root Directory
        let rootDirectory = RootDirectory()
        
        // Folders
        let dummyTupleArray = TuplePreviewData.init().dummyTupleArray
        let workFolder = Folder(name: "Work")
        workFolder.transcriptionTuples = dummyTupleArray
        
        rootDirectory.folders.append(workFolder)
        rootDirectory.folders.append(Folder(name: "Personal"))
        
        
        return rootDirectory
    }
}

struct TuplePreviewData {
    let dummyAudioFile: AudioFile
    let dummyTranscription: Transcription
    let dummyTuple: TranscriptionTuple
    var dummyTupleArray: [TranscriptionTuple] = []
    var dummyFolder: Folder
    var dummyFolderArray: [Folder] = []
    var dummyResponse: String = """
        # Kyle Anthony - Software Developer and Videographer/Photographer

        ## Personal Information

        - Experience:
          - 5 years of experience in Videography and Photography
          - 4 years of experience in Software Development
          
        ## Professional Experiences

        1. ### Videography and Photography

            - 5 years of Professional Experience
            - Owns a Production Company

        2. ### Software Development

            - 4 years of Experience
            - Currently looking for a Job in Tech

        ## Ownership

        - Owns a Production Company
        """

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
        
        let transcription = Transcription(associatedAudioFile: audio, text: dummyResponse)
        self.dummyTranscription = transcription
        
        self.dummyTuple = TranscriptionTuple(
            name: "Sample Recording",
            audioFile: audio,
            transcription: transcription,
            createdAt: Date(timeIntervalSince1970: 0)
        )
        
       self.dummyTupleArray = (0..<15).map { _ in
           TranscriptionTuple(name: "Sample Recording", audioFile: audio, transcription: transcription)
       }
        
        // MARK: Folders
        let folder = Folder(name: "Sample Folder")
        folder.transcriptionTuples.append(contentsOf: dummyTupleArray)
        self.dummyFolder = folder
        
        
        let folders = (0..<4).map { i in
            Folder(name: "Sample Folder \(i)")
        }
        self.dummyFolderArray = folders
        
    }
}
