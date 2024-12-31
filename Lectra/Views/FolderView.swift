// FolderView.swift

import SwiftUI

struct FolderView: View {
    @State private var folders: [String] = ["All Files"] // Default folder
    @State private var isShowingNewFolderDialog = false
    @State private var newFolderName = ""

    var body: some View {
        NavigationView {
            VStack {
                Text("Folders")
                    .font(.largeTitle)
                    .padding()

                List(folders, id: \.self) { folder in
                    NavigationLink(destination: FileListView(folder: folder)) {
                        Text(folder)
                    }
                }
                .listStyle(PlainListStyle())

                Button(action: {
                    isShowingNewFolderDialog = true
                }) {
                    HStack {
                        Image(systemName: "folder.badge.plus")
                        Text("New Folder")
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
            }
        }
        .sheet(isPresented: $isShowingNewFolderDialog) {
            NewFolderDialog(folderName: $newFolderName)
                .onDisappear {
                    if !newFolderName.isEmpty {
                        folders.append(newFolderName)
                        newFolderName = ""
                    }
                }
        }
    }
}

struct FileListView: View {
    let folder: String

    var body: some View {
        Text("Displaying files for folder: \(folder)")
            .navigationTitle(folder)
    }
}

#Preview {
    FolderView()
}
