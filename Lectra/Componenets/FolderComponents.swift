//
//  FolderComponents.swift
//  Lectra
//
//  Created by Kyle-Anthony Hay on 4/5/25.
//

import SwiftUI

struct FolderRow: View {
    let folder: Folder
    @State private var isExpanded: Bool = false
    @State private var showingRenameAlert: Bool = false
    @State private var newFolderName: String = ""
    @EnvironmentObject private var folderManager: FolderManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Folder header row
            HStack {
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    .animation(.spring(), value: isExpanded)
                
                Image(systemName: "folder")
                    .frame(width: 24)
                
                Text(folder.name)
                    .font(.body)
                
                Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation {
                    isExpanded.toggle()
                }
            }
            .contextMenu {
                Button {
                    newFolderName = folder.name
                    showingRenameAlert = true
                } label: {
                    Label("Rename", systemImage: "pencil")
                }
                
                Button(role: .destructive) {
                    if let index = folderManager.rootDirectory.folders.firstIndex(where: { $0.id == folder.id }) {
                        folderManager.deleteFolders(at: IndexSet(integer: index))
                    }
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
            .alert("Rename Folder", isPresented: $showingRenameAlert) {
                TextField("Folder Name", text: $newFolderName)
                Button("Cancel", role: .cancel) {}
                Button("Rename") {
                    folderManager.renameFolder(folder, newName: newFolderName)
                }
            }
            
            // Expandable content (transcription tuples)
            if isExpanded {
                ForEach(folder.transcriptionTuples) { tuple in
                    TranscriptionTupleRow(tuple: tuple)
                        .padding(.leading, 40) // Indent to show hierarchy
                }
            }
        }
    }
}

// Row view for displaying each transcription tuple
struct TranscriptionTupleRow: View {
    let tuple: TranscriptionTuple
    
    var body: some View {
        HStack {
            Image(systemName: "doc.text")
                .frame(width: 24)
            
            Text(tuple.name)
                .font(.body)
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 20)
        .contentShape(Rectangle())
    }
}

#Preview {
    FolderRow(folder: TuplePreviewData().dummyFolder)
}
