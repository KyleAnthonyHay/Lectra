//
//  TVTranscriptionCard.swift
//  Lectra
//
//  Created by Kyle-Anthony Hay on 2/19/25.
//

import SwiftUI
import MarkdownUI

struct TVTranscriptionCard: View {
    @State private var defaultResponse: String = "# Transcription Variable empty"
    var transcription: String?
    
    var body: some View {
        
            ZStack(alignment: .leading) {
                // Background card with shadow
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.background)
                    .shadow(radius: 3)

                // Content
                VStack(alignment: .leading, spacing: 10) {

                    // GPT Response or Default Text
                    Markdown(transcription ?? defaultResponse)
                        .markdownTheme(.gitHub)
                        .textSelection(.enabled)
                        .padding(20)
                }
            }
            .frame(maxWidth: 360) // Card width is fixed, height adjusts dynamically
            .background(Color.background)
            .cornerRadius(16)
            .shadow(radius: 3)
    }
}

#Preview {
    TVTranscriptionCard(transcription: TuplePreviewData().dummyResponse)
}
