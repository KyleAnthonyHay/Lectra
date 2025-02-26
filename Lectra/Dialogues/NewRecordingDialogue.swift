//
//  NewRecordingDialogue.swift
//  Lectra
//
//  Created by Kyle-Anthony Hay on 2/12/25.
//

// NewFolderDialog.swift

import SwiftUI
import SwiftData
// TODO: Apply New Tuple to selected folder ? default flder
/// - custom folder query per row
struct NewRecordingDialog: View {
    @Binding var newRecordingName: String
    @Binding var selectedFolder: Folder?
    @State private var selectedFolderName: String = "Select Folder"
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var folderManager: FolderManager
    
    @Query(FetchDescriptor<Folder>()) private var folders: [Folder]
    var previewFolders = TuplePreviewData().dummyFolderArray
    var rootDirectory: RootDirectory

    var body: some View {
        VStack(spacing: 20) {
            // Card Title
            Text("New Recording").font(.headline)
            // Text Field
            TextField("Recording Name", text: $newRecordingName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            // Folder Selection
            Menu(selectedFolderName) {
                #warning("change previewFolders back to folders")
                ForEach(folders, id: \.id) { folder in
                    Button(folder.name) {
                        selectedFolder = folder
                        selectedFolderName = selectedFolder!.name
                        print("Selected folder: \(folder.name)")
                    }
                }
            }

            // Cancel and Save buttons
            HStack {
                Button(action: {
                    dismiss() // Close dialog without action
                }) {
                    Text("Cancel")
                        .foregroundColor(.red)
                }

                Spacer()

                Button(action: {
                    // If no folder is selected, use the first folder as default
                    if selectedFolder == nil && !folders.isEmpty {
                        selectedFolder = folders[0]
                        print("Using default folder")
                    }
                    
                    // If there are no folders to select from, create a default
                    if selectedFolder == nil {
                        folderManager.addNewFolder(named: "Default Folder")
                        print("Created and selected Default Folder")
                    }
                    
                    dismiss()
                }) {
                    Text("Create")
                        .foregroundColor(newRecordingName.isEmpty ? .gray : .blue)
                        .fontWeight(.bold)
                }.disabled(newRecordingName.isEmpty) // Disable button if no name is provided
            }
            .padding(.horizontal)
        }
        .padding()
        .frame(maxWidth: 300)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 8)
        .onAppear {
            // set default folder when dialogue appears
            if selectedFolder == nil && !folders.isEmpty {
                selectedFolder = folders[0]
                selectedFolderName = folders[0].name
            }
        }
    }
}

#Preview {
    let tuplePreviewData = TuplePreviewData()
    
    NewRecordingDialog(newRecordingName: .constant(""), selectedFolder: .constant(tuplePreviewData.dummyFolder), rootDirectory: PreviewData.rootDirectory)
}

