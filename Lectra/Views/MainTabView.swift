//
//  MainTabView.swift
//  Lectra
//
//  Created by Kyle-Anthony Hay on 12/25/24.
//

import SwiftUI
import SwiftData
import Foundation

// Clients will be initialized as StateObjects in MainTabView

struct MainTabView: View {
    // Initialize API clients as StateObjects to ensure they're created only once
    @StateObject private var openAIClient = OpenAIClientWrapper.shared
    @StateObject private var assemblyAIClient = AssemblyAIClient.shared
    
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
        FolderView(rootDirectory: rootDirectory)
            .environmentObject(folderManager)
            .environmentObject(openAIClient)
            .environmentObject(assemblyAIClient)
    }
}

#Preview {
    MainTabView()
}

