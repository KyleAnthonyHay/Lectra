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
    @State private var hasBeenSaved = false

    var displayText: String {
        if !audioManager.streamedTranscription.isEmpty {
            print("DisplayNotesCard: Using streamed transcription: \(audioManager.streamedTranscription.prefix(50))...")
            return audioManager.streamedTranscription
        }
        print("DisplayNotesCard: Using default or GPT response")
        return gptResponse ?? ""
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // GPT Response or Default Text
            Markdown(displayText)
                .markdownTheme(.lectraClearBackground)
                .textSelection(.enabled)
                .padding(.horizontal)
                .animation(.easeInOut, value: audioManager.streamedTranscription)
                .onChange(of: audioManager.streamedTranscription) { oldValue, newValue in
                    print("DisplayNotesCard: Received transcription update: \(newValue.prefix(50))...")
                }

            // Save Button - Only show if not yet saved
            if !hasBeenSaved {
                HStack {
                    Spacer()
                Button(action: {
                    withAnimation {
                        isSaving = true
                    }
                    
                    print("DisplayNotesCard: Starting save process")
                    print("DisplayNotesCard: Current transcription tuple: \(String(describing: transcriptionTuple))")
                    print("DisplayNotesCard: AudioManager transcription tuple: \(String(describing: audioManager.transcriptionTuple))")
                    
                    // Save actions
                    saveMarkdownAsPDF(markdown: displayText)
                    
                    // Use the transcriptionTuple from the environment
                    audioManager.saveTranscription(
                        modelContext: modelContext,
                        tuple: transcriptionTuple,
                        transcription: displayText
                    )
                    
                    print("DisplayNotesCard: Save completed")
                    
                    // Show confirmation
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showSaveConfirmation = true
                    }
                    
                    // Mark as saved and reset states after delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            isSaving = false
                            showSaveConfirmation = false
                            hasBeenSaved = true  // Set this to true so the button disappears
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
        }
        .padding(.top)
    }
}

#Preview {
    let tuple = TuplePreviewData().dummyTuple
    AudioRecorderManager.shared.setup(with: tuple)
    return DisplayNotesCard(gptResponse: nil, audioManager: AudioRecorderManager.shared)
}
