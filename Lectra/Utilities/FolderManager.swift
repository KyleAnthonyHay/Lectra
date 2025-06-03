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
    
    // moves a tuple from one folder to the other
    func moveTuple(_ tuple: TranscriptionTuple, from sourceFolder: Folder, to targetFolder: Folder) {
        sourceFolder.transcriptionTuples.removeAll { $0.id == tuple.id}
        
        targetFolder.transcriptionTuples.append(tuple)
        
        do {
            try modelContext.save()
            // Force refresh any UI that might be observing these folders
            objectWillChange.send()
            print("Successfully moved \(tuple.name) from \(sourceFolder.name) to \(targetFolder.name)")
        } catch {
            print("Failed to move tuple: \(error)")
        }
    }
    
    func renameTuple(tuple: TranscriptionTuple, newName: String) {
        
        tuple.name = newName
        tuple.audioFile!.name = newName
        
        do {
            try modelContext.save()
            objectWillChange.send()
            print("Successfully renamed \(tuple.name)")
        } catch {
            print("Failed to rename tuple: \(error)")
        }
    }
    
    func renameFolder(_ folder: Folder, newName: String) {
        folder.name = newName
        
        do {
            try modelContext.save()
            objectWillChange.send()
            print("Successfully renamed folder to \(newName)")
        } catch {
            print("Failed to rename folder: \(error)")
        }
    }
}
