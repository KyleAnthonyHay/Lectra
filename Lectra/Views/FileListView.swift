//
//  FileListView.swift
//  Lectra
//
//  Created by Kyle-Anthony Hay on 2/12/25.
//

import SwiftUI
import SwiftData

// TODO:
/// Creating a TranscriptionView
///     - fetch & preview recorded audio

struct FileListView: View {
    let folder: Folder
    @State private var searchText = ""
    @State private var sortOrder: SortOrder = .nameAsc
    @State private var isRefreshing = false
    
    // UI: Columns with adaptive layout
    private let columns = [
        GridItem(.adaptive(minimum: 160, maximum: 180), spacing: 16)
    ]
    
    private var filteredTuples: [TranscriptionTuple] {
        let tuples = folder.transcriptionTuples
        if searchText.isEmpty {
            return sortedTuples(tuples)
        }
        return sortedTuples(tuples.filter { $0.name.localizedCaseInsensitiveContains(searchText) })
    }
    
    private func sortedTuples(_ tuples: [TranscriptionTuple]) -> [TranscriptionTuple] {
        switch sortOrder {
        case .nameAsc:
            return tuples.sorted { $0.name < $1.name }
        case .nameDesc:
            return tuples.sorted { $0.name > $1.name }
        case .dateAsc:
            return tuples.sorted { $0.createdAt < $1.createdAt }
        case .dateDesc:
            return tuples.sorted { $0.createdAt > $1.createdAt }
        }
    }
    
    var body: some View {
        if folder.transcriptionTuples.isEmpty {
            EmptyFolderView(folder: folder)
        } else {
            NavigationStack {
                ZStack {
                    Color(.systemBackground).edgesIgnoringSafeArea(.all)
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            // MARK: Header
                            VStack(alignment: .leading, spacing: 16) {
                                Text(folder.name)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                
                                Text("\(folder.transcriptionTuples.count) transcriptions")
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            
                            // MARK: Search and Sort
                            HStack {
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.gray)
                                    TextField("Search transcriptions", text: $searchText)
                                }
                                .padding(8)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(8)
                                
                                Menu {
                                    Picker("Sort Order", selection: $sortOrder) {
                                        Label("Name (A-Z)", systemImage: "arrow.up").tag(SortOrder.nameAsc)
                                        Label("Name (Z-A)", systemImage: "arrow.down").tag(SortOrder.nameDesc)
                                        Label("Date (Newest)", systemImage: "calendar").tag(SortOrder.dateDesc)
                                        Label("Date (Oldest)", systemImage: "calendar").tag(SortOrder.dateAsc)
                                    }
                                } label: {
                                    Image(systemName: "arrow.up.arrow.down")
                                        .foregroundColor(.blue)
                                        .padding(8)
                                        .background(Color(.secondarySystemBackground))
                                        .cornerRadius(8)
                                }
                            }
                            .padding(.horizontal)
                            
                            // MARK: Grid
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(filteredTuples) { tuple in
                                    NavigationLink(destination: TupleView(transcriptionTuple: tuple)) {
                                        TranscriptionCard(tuple: tuple, folder: folder)
                                            .frame(height: 220)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                    }
                    .refreshable {
                        // Simulate refresh
                        isRefreshing = true
                        try? await Task.sleep(nanoseconds: 1_000_000_000)
                        isRefreshing = false
                    }
                }
            }
        }
    }
}

// MARK: - Sort Order Enum
enum SortOrder {
    case nameAsc
    case nameDesc
    case dateAsc
    case dateDesc
}

// MARK: - Transcription Card
struct TranscriptionCard: View {
    let tuple: TranscriptionTuple
    let folder: Folder
    @StateObject private var audioManager: AudioRecorderManager
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var folderManager: FolderManager
    @Query private var folders: [Folder]
    
    @State private var isRenaming = false
    @State private var newName = ""
    
    init(tuple: TranscriptionTuple, folder: Folder) {
        self.tuple = tuple
        self.folder = folder
        _audioManager = StateObject(wrappedValue: AudioRecorderManager(transcriptionTuple: tuple))
        let descriptor = FetchDescriptor<Folder>(sortBy: [SortDescriptor(\.name)])
        _folders = Query(descriptor)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: tuple.createdAt)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Preview Image or Icon
            ZStack {
                Rectangle()
                    .fill(Color(.secondarySystemBackground))
                    .aspectRatio(16/9, contentMode: .fit)
                    .cornerRadius(8)
                
                Image(systemName: "waveform")
                    .font(.system(size: 30))
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                // Title
                Text(tuple.name)
                    .font(.headline)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                // Date
                Text(formattedDate)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                // Playback Controls
                HStack {
                    Button(action: {
                        if audioManager.isPlaying {
                            audioManager.stopAudio()
                        } else {
                            audioManager.playSwiftDataAudio(tuple: tuple)
                        }
                    }) {
                        Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                            .foregroundColor(.white)
                            .frame(width: 28, height: 28)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                    
                    if audioManager.isPlaying {
                        // Progress Bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 3)
                                
                                Rectangle()
                                    .fill(Color.blue)
                                    .frame(width: geometry.size.width * 0.4, height: 3)
                            }
                        }
                        .frame(height: 3)
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .contextMenu {
            // Move to Folder
            Menu("Move to...") {
                ForEach(folders) { targetFolder in
                    if targetFolder.id != folder.id {
                        Button(targetFolder.name) {
                            folderManager.moveTuple(tuple, from: folder, to: targetFolder)
                        }
                    }
                }
            }
            
            // Rename
            Button {
                newName = tuple.name
                isRenaming = true
            } label: {
                Label("Rename", systemImage: "pencil")
            }
            
            // Delete
            Button(role: .destructive) {
                modelContext.delete(tuple)
                try? modelContext.save()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .alert("Rename Transcription", isPresented: $isRenaming) {
            TextField("New name", text: $newName)
            Button("Cancel", role: .cancel) { }
            Button("Rename") {
                if !newName.isEmpty {
                    folderManager.renameTuple(tuple: tuple, newName: newName)
                }
            }
        } message: {
            Text("Enter a new name for this transcription")
        }
    }
}

#Preview {
    let previewData = TuplePreviewData()
    return FileListView(folder: previewData.dummyFolder)
        .environmentObject(FolderManager(modelContext: ModelContext(try! ModelContainer(for: Folder.self)), rootDirectory: RootDirectory()))
}

