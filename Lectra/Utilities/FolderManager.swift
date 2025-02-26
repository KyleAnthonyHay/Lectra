// FolderManager.swift

import Foundation
import SwiftUI
import SwiftData

@MainActor
class FolderManager: ObservableObject {
    private var modelContext: ModelContext
    private(set) var rootDirectory: RootDirectory
    
    init(modelContext: ModelContext, rootDirectory: RootDirectory) {
        self.modelContext = modelContext
        self.rootDirectory = rootDirectory
    }
    
    func updateContext(modelContext: ModelContext, rootDirectory: RootDirectory) {
        self.modelContext = modelContext
        self.rootDirectory = rootDirectory
    }
    // MARK: CRUD Operations
    func addNewFolder(named folderName: String) {
        let newFolder = Folder(name: folderName)
        rootDirectory.folders.append(newFolder)
        
        do {
            try modelContext.save()
            print("Successfully added folder")
        } catch {
            print("Failed to save new folder: \(error)")
        }
    }
    
    func deleteFolders(at offsets: IndexSet) {
        offsets.forEach { index in
            let folder = rootDirectory.folders[index]
            modelContext.delete(folder)
        }
        
        do {
            try modelContext.save()
            print("Succesfully deleted folder")
        } catch {
            print("Could Not delete folder: \(error)")
        }
    }
    
    func add(tuple: TranscriptionTuple, to folder: Folder) {
        folder.transcriptionTuples.append(tuple)
        
        do {
            try modelContext.save()
            print("Succesfully added \(tuple.name) to \(folder.name) folder")
        } catch {
            print("Could Not delete folder: \(error)")
        }
    }
    
    // CHECK THIS
    func remove(tuple: TranscriptionTuple, fromFolder folder: Folder) {
        folder.transcriptionTuples.removeAll { $0.id == tuple.id }
        
        do {
            try modelContext.save()
            print("Succesfully deleted folder")
        } catch {
            print("Could Not delete folder: \(error)")
        }
    }
    
}
