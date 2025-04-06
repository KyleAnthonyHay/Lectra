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
                Color(.systemBackground).edgesIgnoringSafeArea(.all)
                
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

// MARK: Additional components needed to complete the design

struct RecentItemCard: View {
    let item: Folder
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack {
                Rectangle()
                    .fill(Color.blue.opacity(0.8))
                    .frame(height: 120)
                    .cornerRadius(8, corners: [.topLeft, .topRight])
                
                VStack {
                    Spacer()
                    HStack {
                        Image(systemName: "folder")
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
                }
            }
            
            Text(item.name)
                .font(.caption)
                .padding(8)
                .lineLimit(2)
        }
        .frame(width: 150)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
}

struct FolderRow: View {
    let folder: Folder
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Folder header row
            HStack {
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    .animation(.spring(), value: isExpanded)
                
                Image(systemName: "folder")
                    .frame(width: 24)
                
                Text(folder.name)
                    .font(.body)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "plus")
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation {
                    isExpanded.toggle()
                }
            }
            
            // Expandable content (transcription tuples)
            if isExpanded {
                ForEach(folder.transcriptionTuples) { tuple in
                    TranscriptionTupleRow(tuple: tuple)
                        .padding(.leading, 40) // Indent to show hierarchy
                }
            }
        }
    }
}

// Row view for displaying each transcription tuple
struct TranscriptionTupleRow: View {
    let tuple: TranscriptionTuple
    
    var body: some View {
        HStack {
            Image(systemName: "doc.text")
                .frame(width: 24)
            
            Text(tuple.name)
                .font(.body)
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 20)
        .contentShape(Rectangle())
    }
}


struct TabBar: View {
    var onAddButtonTapped: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            TabBarButton(icon: "house.fill", isSelected: true)
            TabBarButton(icon: "magnifyingglass", isSelected: false)
            
            // Middle add button
            Button(action: onAddButtonTapped) {
                Image(systemName: "plus")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.blue)
                    .clipShape(Circle())
            }
            .padding(.horizontal, 8)
            
            TabBarButton(icon: "tray.fill", isSelected: false)
            TabBarButton(icon: "gearshape", isSelected: false)
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .overlay(Divider(), alignment: .top)
    }
}

struct TabBarButton: View {
    let icon: String
    let isSelected: Bool
    
    var body: some View {
        Button(action: {}) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isSelected ? .primary : .gray)
                .frame(maxWidth: .infinity)
        }
    }
}

// Helper for rounded corners (from the previous implementation)
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}






#Preview {
    FolderView(rootDirectory: PreviewData.rootDirectory)
}
