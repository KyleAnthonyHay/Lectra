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
    @State private var isSaving = false
    @State private var showSaveConfirmation = false

    var displayText: String {
        if !audioManager.streamedTranscription.isEmpty {
            return audioManager.streamedTranscription
        }
        return gptResponse ?? defaultResponse
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // GPT Response or Default Text
            Markdown(displayText)
                .markdownTheme(.lectraClearBackground)
                .textSelection(.enabled)
                .padding(.horizontal)
                .animation(.easeInOut, value: audioManager.streamedTranscription)

            // Save Button
            HStack {
                Spacer()
                Button(action: {
                    withAnimation {
                        isSaving = true
                    }
                    
                    // Save actions
                    saveMarkdownAsPDF(markdown: displayText)
                    audioManager.saveTranscription(modelContext: modelContext, tuple: transcriptionTuple, transcription: displayText)
                    
                    // Show confirmation
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showSaveConfirmation = true
                    }
                    
                    // Reset states after delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            isSaving = false
                            showSaveConfirmation = false
                        }
                    }
                }) {
                    HStack(spacing: 8) {
                        if isSaving {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else if showSaveConfirmation {
                            Image(systemName: "checkmark")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .transition(.scale.combined(with: .opacity))
                        } else {
                            Image(systemName: "square.and.arrow.down")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                        }
                        
                        if !isSaving {
                            Text(showSaveConfirmation ? "Saved!" : "Save")
                                .font(.system(size: 16, weight: .medium))
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(showSaveConfirmation ? Color.green : LectraColors.brand)
                            .shadow(radius: 3)
                    )
                    .scaleEffect(isSaving ? 0.95 : 1.0)
                }
                .disabled(isSaving)
                .padding(.trailing)
                .padding(.bottom)
            }
        }
        .padding(.top)
    }
}

#Preview {
    DisplayNotesCard(gptResponse: nil, audioManager: AudioRecorderManager(transcriptionTuple: TuplePreviewData().dummyTuple))
}
