//
//  EmptyFolderView.swift
//  Lectra
//
//  Created by Kyle-Anthony Hay on 2/26/25.
//

import SwiftUI

struct EmptyFolderView: View {
    var folder: Folder
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            // MARK: Animated Folder ICon
            Image(systemName: "folder")
                .resizable()
                .scaledToFit()
                .frame(width: 100)
                .foregroundStyle(.secondary)
                .opacity(isAnimating ? 0.8 : 0.6)
                .scaleEffect(isAnimating ? 1.05 : 1.0)
                .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
            
            // Simple text showing the folder is empty
            Text("\(folder.name) is empty")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    EmptyFolderView(folder: TuplePreviewData().dummyFolder)
}
