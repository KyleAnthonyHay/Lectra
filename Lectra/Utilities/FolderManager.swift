// FolderManager.swift

import Foundation
import SwiftUI
import SwiftData

@MainActor
class FolderManager: ObservableObject {
    private let modelContext: ModelContext
    private let rootDirectory: RootDirectory
    
    init(modelContext: ModelContext, rootDirectory: RootDirectory) {
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
    
}
