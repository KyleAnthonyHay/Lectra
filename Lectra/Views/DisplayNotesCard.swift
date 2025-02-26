import SwiftUI
import MarkdownUI

struct DisplayNotesCard: View {
    @State private var defaultResponse: String = """
        # PREVIEW DATA

        ## Personal Information

        - Experience:
          - 5 years of experience in Videography and Photography
          - 4 years of experience in Software Development
          
        ## Professional Experiences

        1. ### Videography and Photography

            - 5 years of Professional Experience
            - Owns a Production Company

        2. ### Software Development

            - 4 years of Experience
            - Currently looking for a Job in Tech

        ## Ownership

        - Owns a Production Company
        """
    var gptResponse: String?
    @ObservedObject var audioManager: AudioRecorderManager
    @EnvironmentObject var transcriptionTuple: TranscriptionTuple
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ZStack(alignment: .leading) {
            // Background card with shadow
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.background)
                .shadow(radius: 3)

            // Content
            VStack(alignment: .leading, spacing: 10) {

                // GPT Response or Default Text
                Markdown(gptResponse ?? defaultResponse)
                    .markdownTheme(.gitHub)
                    .textSelection(.enabled)
                    .padding(20)

                // Save Button
                Button(action: {
                    let markdown = gptResponse ?? defaultResponse
                    saveMarkdownAsPDF(markdown: markdown) // Save as PDF
                    // Save to swift data
                    audioManager.saveTranscription(modelContext: modelContext, tuple: transcriptionTuple, transcription: gptResponse ?? defaultResponse)
                    
                    print("Save button tapped")
                }) {
                    Image(systemName: "square.and.arrow.down")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.white)
                        .padding()
                        .background(.icon)
                        .cornerRadius(9)
                        .shadow(radius: 5)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
        }
        .frame(maxWidth: 360) // Card width is fixed, height adjusts dynamically
        .background(Color.background)
        .cornerRadius(16)
        .shadow(radius: 3)
    }
}

#Preview {
    DisplayNotesCard(gptResponse: nil, audioManager: AudioRecorderManager(transcriptionTuple: TuplePreviewData().dummyTuple)) // Preview with default text
}
