// FolderView.swift

import SwiftUI
import SwiftData

struct FolderView: View {
    //Basic UI Implementation
    @State private var isShowingNewFolderDialog = false
    @State private var newFolderName = ""
    // Record View
    @State private var isShowingNewRecordingDialog = false
    @State private var navigateToRecordView = false
    @State private var newRecordingName = ""
    
    // MARK: Swift Data Implementation
    @Environment(\.modelContext) private var modelContext
    let rootDirectory: RootDirectory
    
    private var folderManager: FolderManager {
        FolderManager(modelContext: modelContext, rootDirectory: rootDirectory)
    }
    
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
                        NavigationLink(destination: FileListView(transcriptionTuples: tuplePreviewData.dummyTupleArray)){
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
                        RecordView(tupleName: newRecordingName)
                    }
                }
 
                
            }
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
            NewRecordingDialog(newRecordingName: $newRecordingName)
                .onDisappear {
                    navigateToRecordView = true
                }
        }
    }
}



#Preview {
    FolderView(rootDirectory: PreviewData.rootDirectory)
}
