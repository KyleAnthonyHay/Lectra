//
//  PreviewData.swift
//  Lectra
//
//  Created by Kyle-Anthony Hay on 2/8/25.
//
import SwiftData

// A global constant for preview data
struct PreviewData {
    static var rootDirectory: RootDirectory {
        let rootDirectory = RootDirectory()
        rootDirectory.folders.append(Folder(name: "Work"))
        rootDirectory.folders.append(Folder(name: "Personal"))
        return rootDirectory
    }
}
