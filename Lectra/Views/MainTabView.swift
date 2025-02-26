//
//  MainTabView.swift
//  Lectra
//
//  Created by Kyle-Anthony Hay on 12/25/24.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @Query(FetchDescriptor<RootDirectory>()) private var rootDirectories: [RootDirectory]
    @Environment(\.modelContext) private var modelContext

    // T3: Create a StateObject for the FolderManager with a temporary empty initialization
    @StateObject private var folderManager = FolderManager(
        modelContext: ModelContext(try! ModelContainer(for: RootDirectory.self)),
        rootDirectory: RootDirectory()
    )
    
    private var rootDirectory: RootDirectory {
        if let existingRootDirectory = rootDirectories.first {
            return existingRootDirectory
        }
        
        let newRootDirectory = RootDirectory()
        modelContext.insert(newRootDirectory)
        
        do {
            try modelContext.save()
        } catch {
            print("Could not save root directory: \(error)")
        }
        
        return newRootDirectory
    }
    
    var body: some View {
        // T3: Update the folderManager with the correct context and root directory
        let _ = folderManager.updateContext(modelContext: modelContext, rootDirectory: rootDirectory)
        FolderView(rootDirectory: rootDirectory).environmentObject(folderManager)
    }
}

#Preview {
    MainTabView()
}

