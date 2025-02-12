//
//  NewRecordingDialogue.swift
//  Lectra
//
//  Created by Kyle-Anthony Hay on 2/12/25.
//

// NewFolderDialog.swift

import SwiftUI

struct NewRecordingDialog: View {
    @Binding var newRecordingName: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("New Recording")
                .font(.headline)

            TextField("Recording Name", text: $newRecordingName)
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
    NewRecordingDialog(newRecordingName: .constant(""))
}

