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
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
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
            Menu("Select Folder") {
                #warning("change previed Folders back to folders")
                ForEach(folders, id: \.id) { folder in
                    Button(folder.name) {
                        selectedFolder = folder
                        print("Selected folder: \(selectedFolder!.name)")
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
                    // 1. Create a new manager each time
                    // 2. Use it to add a new recording
//                    let tempManager = FolderManager(modelContext: modelContext, rootDirectory: rootDirectory)
                    dismiss() // Close dialog and save
                }) {
                    Text("Create")
                        .foregroundColor(.blue)
                        .fontWeight(.bold)
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .frame(maxWidth: 300)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 8)
    }
}

#Preview {
    let tuplePreviewData = TuplePreviewData()
    
    NewRecordingDialog(newRecordingName: .constant(""), selectedFolder: .constant(tuplePreviewData.dummyFolder), rootDirectory: PreviewData.rootDirectory)
}

