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
    
    //second attempt at checking fetching and establishing the root directory
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
        FolderView(rootDirectory: rootDirectory)
    }
}

#Preview {
    MainTabView()
}

