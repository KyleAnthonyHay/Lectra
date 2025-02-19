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
    @Query(FetchDescriptor<TranscriptionTuple>()) private var swiftDataTranscriptionTuples: [TranscriptionTuple]
    let transcriptionTuples: [TranscriptionTuple]
    // UI: Columns
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    var body: some View {
        ScrollView {
            // MARK: Title
            Text("Transcriptions")
                .font(.title)
            // MARK: Files
            LazyVGrid(columns: columns) {
                ForEach(swiftDataTranscriptionTuples, id: \.id) { tuple in
                    TranscriptionCard(tuple: tuple)
                }.padding(8)
            }
            .padding()
        }// End of Scrollview
        .padding(EdgeInsets(top: 8, leading: 8, bottom: 0, trailing: 8))
    }
}

// MARK: - Card View
struct TranscriptionCard: View {
    @Environment(\.modelContext) private var modelContext
    let tuple: TranscriptionTuple
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
            // Trash button to delete the tuple from SwiftData
            Button {
                // Delete the tuple from SwiftData and save the changes
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

#Preview {
    let previewData = TuplePreviewData()
    FileListView(transcriptionTuples: previewData.dummyTupleArray)
}
