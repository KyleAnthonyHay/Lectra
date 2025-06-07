//
//  TranscriptionCard.swift
//  Lectra
//
//  Created by Kyle-Anthony Hay on 2/12/25.
//

import SwiftUI
import SwiftData

struct FileListCard: View {
    let tuple: TranscriptionTuple
    let folder: Folder
    @StateObject private var audioManager: AudioRecorderManager
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var folderManager: FolderManager
    @Query private var folders: [Folder]
    
    @State private var isRenaming = false
    @State private var newName = ""
    
    init(tuple: TranscriptionTuple, folder: Folder) {
        self.tuple = tuple
        self.folder = folder
        _audioManager = StateObject(wrappedValue: AudioRecorderManager.shared)
        let descriptor = FetchDescriptor<Folder>(sortBy: [SortDescriptor(\.name)])
        _folders = Query(descriptor)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: tuple.createdAt)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Preview Image or Icon
            ZStack {
                Rectangle()
                    .fill(LectraColors.secondaryBackground)
                    .aspectRatio(16/9, contentMode: .fit)
                    .cornerRadius(8)
                
                Image(systemName: "waveform")
                    .font(.system(size: 30))
                    .foregroundColor(LectraColors.brand)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                // Title
                Text(tuple.name)
                    .font(.headline)
                    .lineLimit(2)
                    .foregroundColor(LectraColors.textPrimary)
                
                // Date
                Text(formattedDate)
                    .font(.caption)
                    .foregroundColor(LectraColors.textSecondary)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(LectraColors.background)
        .cornerRadius(12)
        .shadow(radius: 2)
        .contextMenu {
            // Move to Folder
            Menu("Move to...") {
                ForEach(folders) { targetFolder in
                    if targetFolder.id != folder.id {
                        Button(targetFolder.name) {
                            folderManager.moveTuple(tuple, from: folder, to: targetFolder)
                        }
                    }
                }
            }
            
            // Rename
            Button {
                newName = tuple.name
                isRenaming = true
            } label: {
                Label("Rename", systemImage: "pencil")
            }
            
            // Delete
            Button(role: .destructive) {
                modelContext.delete(tuple)
                try? modelContext.save()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .alert("Rename Transcription", isPresented: $isRenaming) {
            TextField("New name", text: $newName)
            Button("Cancel", role: .cancel) { }
            Button("Rename") {
                if !newName.isEmpty {
                    folderManager.renameTuple(tuple: tuple, newName: newName)
                }
            }
        } message: {
            Text("Enter a new name for this transcription")
        }
    }
}

#Preview {
    let previewData = TuplePreviewData()
    return FileListCard(tuple: previewData.dummyTuple, folder: previewData.dummyFolder)
        .environmentObject(FolderManager(modelContext: ModelContext(try! ModelContainer(for: Folder.self)), rootDirectory: RootDirectory()))
} 
