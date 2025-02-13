//
//  FileListView.swift
//  Lectra
//
//  Created by Kyle-Anthony Hay on 2/12/25.
//

import SwiftUI
import SwiftData

struct FileListView: View {
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
                ForEach(transcriptionTuples, id: \.id) { tuple in
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
        }
    
        
    }
}

#Preview {
    let previewData = TuplePreviewData()
    FileListView(transcriptionTuples: previewData.dummyTupleArray)
}
