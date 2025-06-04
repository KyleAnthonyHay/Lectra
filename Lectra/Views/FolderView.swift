import SwiftUI
import SwiftData

struct FolderView: View {
    // Keep your existing properties
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var folderManager: FolderManager
    let rootDirectory: RootDirectory
    
    @State private var isShowingNewFolderDialog = false
    @State private var newFolderName = ""
    @State private var isShowingNewRecordingDialog = false
    @State private var navigateToRecordView = false
    @State private var newRecordingName = ""
    @State private var selectedFolder: Folder? = nil
    @State private var didConfirmRecordingCreation = false
    
    // Add property for recent folders
    @State private var recentFolders: [Folder] = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                LectraColors.background.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Profile header - keep your existing implementation
                        HStack() {
                            Image(uiImage: .profilePicture)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 44, height: 44)
                                .cornerRadius(4)
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Kyle-Anthony Hay")
                                        .font(.body)
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                }
                                Text("Beta Tester")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Button(action: {}) {
                                Image(systemName: "ellipsis")
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        
                        // MARK: Jump back in section (Recent folders)
                        VStack(alignment: .leading) {
                            Text("Jump back in")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 20)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    // Display most recent folders or recordings
                                    ForEach(getRecentItems(), id: \.id) { folder in
                                        NavigationLink(destination: FileListView(folder: folder)) {
                                            RecentItemCard(item: folder)
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        // MARK: Folders section
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Text("Folders")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                
                                Spacer()
                                
                                Button(action: {
                                    isShowingNewFolderDialog = true
                                }) {
                                    Image(systemName: "plus")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                            
                            // Folder list with functional NavigationLinks
                            ForEach(rootDirectory.folders, id: \.id) { folder in
                                NavigationLink(destination: FileListView(folder: folder)) {
                                    FolderRow(folder: folder)
                                }
                                .buttonStyle(PlainButtonStyle()) // Keeps the styling consistent
                            }
                            .onDelete { offsets in
                                folderManager.deleteFolders(at: offsets)
                            }
                        }
                    }
                    .padding(.vertical)
                }
                
                // Add the tab bar at the bottom
                VStack {
                    Spacer()
                    TabBar(onAddButtonTapped: {
                        newRecordingName = ""
                        isShowingNewRecordingDialog = true
                    })
                }
            }
            .navigationDestination(isPresented: $navigateToRecordView) {
                RecordView(tupleName: newRecordingName, folder: selectedFolder)
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
            NewRecordingDialog(newRecordingName: $newRecordingName, selectedFolder: $selectedFolder, didConfirmCreation: $didConfirmRecordingCreation, rootDirectory: rootDirectory)
                .onDisappear {
                    if didConfirmRecordingCreation && !newRecordingName.isEmpty {
                        navigateToRecordView = true
                    }
                }
        }
        .onAppear {
            // Load recent items - first 3 folders from the main list
            recentFolders = Array(rootDirectory.folders.prefix(3))
        }
    }
    
    // Helper function to get recent items
    private func getRecentItems() -> [Folder] {
        return Array(rootDirectory.folders.prefix(3))
    }
}





#Preview {
    FolderView(rootDirectory: PreviewData.rootDirectory)
}
