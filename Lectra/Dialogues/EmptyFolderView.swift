//
//  EmptyFolderView.swift
//  Lectra
//
//  Created by Kyle-Anthony Hay on 2/26/25.
//

import SwiftUI

struct EmptyFolderView: View {
    let folder: Folder
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 70))
                .foregroundColor(.gray)
            
            Text("No Transcriptions Yet")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Tap the + button to create your first transcription in '\(folder.name)'")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: {
                // Action to create new transcription
            }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Create Transcription")
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding(.top, 10)
            
            Spacer()
            
            // Add tab bar for consistency
            TabBar(onAddButtonTapped: {
                // Handle adding new transcription
            })
        }
    }
}

#Preview {
    EmptyFolderView(folder: TuplePreviewData().dummyFolder)
}
