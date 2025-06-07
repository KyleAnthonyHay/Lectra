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
                    LectraColors.background.edgesIgnoringSafeArea(.all)
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            // MARK: Header
                            VStack(alignment: .leading, spacing: 16) {
                                Text(folder.name)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                
                                Text("\(folder.transcriptionTuples.count) transcriptions")
                                    .foregroundColor(LectraColors.textSecondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            
                            // MARK: Search and Sort
                            HStack {
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(LectraColors.textSecondary)
                                    TextField("Search transcriptions", text: $searchText)
                                }
                                .padding(8)
                                .background(LectraColors.secondaryBackground)
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
                                        .foregroundColor(LectraColors.brand)
                                        .padding(8)
                                        .background(LectraColors.secondaryBackground)
                                        .cornerRadius(8)
                                }
                            }
                            .padding(.horizontal)
                            
                            // MARK: Grid
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(filteredTuples) { tuple in
                                    NavigationLink(destination: TupleView(transcriptionTuple: tuple)) {
                                        FileListCard(tuple: tuple, folder: folder)
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

#Preview {
    let previewData = TuplePreviewData()
    return FileListView(folder: previewData.dummyFolder)
        .environmentObject(FolderManager(modelContext: ModelContext(try! ModelContainer(for: Folder.self)), rootDirectory: RootDirectory()))
}

