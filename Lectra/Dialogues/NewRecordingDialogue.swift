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
    @Binding var selectedFolder: Folder?  // The folder the user selects
    @Environment(\.dismiss) private var dismiss
    @Query(FetchDescriptor<Folder>()) private var folders: [Folder]
    var previewFolders = TuplePreviewData().dummyFolderArray

    var body: some View {
        VStack(spacing: 20) {
            Text("New Recording").font(.headline)

            TextField("Recording Name", text: $newRecordingName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Menu("Select Folder") {
                #warning("change previewFolders back to folders")
                ForEach(previewFolders, id: \.id) { folder in
                    Button(folder.name) {
                        selectedFolder = folder
                    }
                }
            }

            HStack {
                Button(action: {
                    dismiss() // Close dialog without action
                }) {
                    Text("Cancel")
                        .foregroundColor(.red)
                }

                Spacer()

                Button(action: {
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
    NewRecordingDialog(newRecordingName: .constant(""), selectedFolder: .constant(TuplePreviewData().dummyFolder))
}

