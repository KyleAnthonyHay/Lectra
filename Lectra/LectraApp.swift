//
//  LectraApp.swift
//  Lectra
//
//  Created by Kyle-Anthony Hay on 12/19/24.
//

import SwiftUI

@main
struct LectraApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }.modelContainer(for: [
            RootDirectory.self,
            Folder.self,
            TranscriptionTuple.self,
            Transcription.self,
            AudioFile.self
        ])
    }
}

