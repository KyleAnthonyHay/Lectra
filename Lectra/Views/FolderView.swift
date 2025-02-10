// FolderView.swift

import SwiftUI
import SwiftData

struct FolderView: View {
    //Basic UI Implementation
    @State private var isShowingNewFolderDialog = false
    @State private var newFolderName = ""
    
    // MARK: Swift Data Implementation
    @Environment(\.modelContext) private var modelContext
    let rootDirectory: RootDirectory
    
    private var folderManager: FolderManager {
        FolderManager(modelContext: modelContext, rootDirectory: rootDirectory)
    }
    
    // MARK: UI
    var body: some View {
        NavigationView {
            VStack {
                Text("Folders")
                    .font(.largeTitle)
                    .padding()

                List(rootDirectory.folders, id: \.self) { folder in
                    NavigationLink(destination: FileListView(folder: folder.name)) {
                        Text(folder.name)
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
//                        folders.append(newFolderName)
                        folderManager.addNewFolder(named: newFolderName)
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
    FolderView(rootDirectory: PreviewData.rootDirectory)
}
