// FolderView.swift

import SwiftUI
import SwiftData

/// TODO:
///  - add the ability to assign  new recording to group
///  - add refind where to create new folder swiftdata object and make changes accordingly

struct FolderView: View {
    // MARK: Swift Data Implementation
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var folderManager: FolderManager
    let rootDirectory: RootDirectory
    
    //Basic UI Implementation
    @State private var isShowingNewFolderDialog = false
    @State private var newFolderName = ""
    
    // Record View
    @State private var isShowingNewRecordingDialog = false
    @State private var navigateToRecordView = false
    @State private var newRecordingName = ""
    @State private var selectedFolder: Folder? = nil
    

    
    
    
    // PREVIEW DATA
    let tuplePreviewData = TuplePreviewData()
    
    
    // MARK: UI
    var body: some View {
        NavigationStack {
            VStack {
                Text("Folders")
                    .font(.largeTitle)
                    .padding()
                List {
                    ForEach(rootDirectory.folders, id: \.id) { folder in
                        NavigationLink(destination: FileListView(folder: folder)){
                            Text(folder.name)
                        }
                    }
                    .onDelete { offsets in
                        folderManager.deleteFolders(at: offsets)
                    }
                }
                
                
                HStack {
                    // MARK: NEW FOLDER
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
                    
                    
                    // MARK: NEW RECORDING
                    Button(action: {
                        newRecordingName = ""
                        isShowingNewRecordingDialog = true
                        print("New View Button Pressed")
                    }) {
                        HStack {
                            Image(systemName: "plus")
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }.navigationDestination(isPresented: $navigateToRecordView) {
                        RecordView(tupleName: newRecordingName, folder: selectedFolder)
                    }
                }
 
                
            }// end of Vstack
        }
        .sheet(isPresented: $isShowingNewFolderDialog) {
            NewFolderDialog(folderName: $newFolderName)
                .onDisappear {
                    if !newFolderName.isEmpty {
                        folderManager.addNewFolder(named: newFolderName)
                        newFolderName = ""
                    }
                }
        }
        .sheet(isPresented: $isShowingNewRecordingDialog) {
            NewRecordingDialog(newRecordingName: $newRecordingName, selectedFolder: $selectedFolder, rootDirectory: rootDirectory)
                .onDisappear {
                    if !newRecordingName.isEmpty {
                        navigateToRecordView = true
                    }
                }
        }
    }
}



#Preview {
    FolderView(rootDirectory: PreviewData.rootDirectory)
}
