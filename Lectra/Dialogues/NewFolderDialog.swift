// NewFolderDialog.swift

import SwiftUI

struct NewFolderDialog: View {
    @Binding var folderName: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("Create New Folder")
                .font(.headline)

            TextField("Folder Name", text: $folderName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

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
    NewFolderDialog(folderName: .constant(""))
}
