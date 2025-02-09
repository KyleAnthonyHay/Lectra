// FolderView.swift

import SwiftUI
import SwiftData

struct FolderView: View {
    //Basic UI Implementation
    @State private var folders: [String] = ["All Files"] // Default folder
    @State private var isShowingNewFolderDialog = false
    @State private var newFolderName = ""
    
    // Swift Data Implementation
    @Environment(\.modelContext) private var modelContext
    let rootDirectory: RootDirectory

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
    /// We just added the addNewFolder function
    ///     Time to better understand it as well as add the defult folder that should be initialized to the FolderView object in main tab view
    ///     we also need to add that swift data object in this view. Good luck.
    private func addNewFolder() {
        let newFolder = Folder(name: "New Folder")
        rootDirectory.folders.append(newFolder) // Add the folder to the RootDirectory
        modelContext.insert(newFolder)
        
        do {
            try modelContext.save()
            print("Successfully added a new folder.")
        } catch {
            print("Failed to save new folder: \(error)")
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
