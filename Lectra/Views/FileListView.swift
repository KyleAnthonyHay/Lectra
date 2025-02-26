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
    
    // UI: Columns
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    var body: some View {
        if folder.transcriptionTuples.isEmpty {
            EmptyFolderView(folder: folder)
        } else {
            NavigationStack {
                ScrollView {
                    // MARK: Title
                    Text("Transcriptions")
                        .font(.title)
                    // MARK: Files
                    LazyVGrid(columns: columns) {
                        ForEach(folder.transcriptionTuples, id: \.id) { tuple in
                            NavigationLink {
                                TupleView(transcriptionTuple: tuple)
                            } label: {
                                TranscriptionCard(tuple: tuple, folder: folder)
                            }
                        }.padding(8)
                    }
                    .padding()
                }// End of Scrollview
                .padding(EdgeInsets(top: 8, leading: 8, bottom: 0, trailing: 8))
            }
        }
    }
}

// MARK: - Transcription Card
struct TranscriptionCard: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var folderManager: FolderManager
    @Query private var folders: [Folder]
    
    init(tuple: TranscriptionTuple, folder: Folder) {
        self.tuple = tuple
        self.folder = folder
        // Create a fetch descriptor to ensure we get all folders
        let descriptor = FetchDescriptor<Folder>(sortBy: [SortDescriptor(\.name)])
        _folders = Query(descriptor)
    }
    
    let tuple: TranscriptionTuple
    let folder: Folder
    
    var formattedDate: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM. dd, yyyy"
            return formatter.string(from: tuple.createdAt)
        }
    
    var body: some View {
        VStack(alignment: .center) {
            // The card graphic
            ZStack{
                Rectangle()
                    .cornerRadius(16)
                    .foregroundStyle(Color(UIColor.systemBackground))
                    .shadow(radius: 4)
                    .frame(width: 96, height: 96)

                Image(systemName: "newspaper.fill")
                    .font(.system(size: 36))
                    .padding()
            }
            // Display the tuple's name under the card
            Text(tuple.name)
                .font(.callout)
                .padding(.top,4)
            Text(formattedDate)
                .font(.caption)
            // HStack with folder and trash buttons
            HStack (spacing: 36) {
                Menu {
                    ForEach(folders, id: \.id) { targetFolder in
                        if targetFolder.id != folder.id {
                            Button(targetFolder.name) {
                                print("Moving tuple to folder: \(targetFolder.name)")
                                folderManager.moveTuple(tuple, from: folder, to: targetFolder)
                            }
                        }
                    }
                } label: {
                    Image(systemName: "arrow.turn.up.left")
                        .foregroundColor(.blue)
                }
                
                
                
                Button {
                    // Delete the tuple from SwiftData and save the changes
    //                folderManager.remove(tuple: tuple, fromFolder: folder)
                    modelContext.delete(tuple)
                    try? modelContext.save()
                    print("Deleted tuple: \(tuple.name)")
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .padding(.top, 4)
            }
        }
    
        
    }
}

#Preview {
    let previewData = TuplePreviewData()
    FileListView(folder: previewData.dummyFolder).environmentObject(FolderManager(modelContext: ModelContext(try! ModelContainer(for: Folder.self)), rootDirectory: RootDirectory()))
}
