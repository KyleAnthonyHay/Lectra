import SwiftUI

struct DisplayNotesCard: View {
    @State private var gptResponse: String = """
        This is an example of a GPT-generated response. The generated text will dynamically resize the card vertically, allowing users to view all the content without scrolling. The card itself adjusts based on the length of the text.

        By leveraging SwiftUI's flexibility, this layout ensures the Save button remains at the very bottom, even as the content grows. This approach enhances usability and visual appeal for longer pieces of text.

        For instance, imagine you're taking notes during a lecture or summarizing a detailed conversation. The text may span several paragraphs, and this card is designed to accommodate that seamlessly. Here's another line to make this example more realistic.
        
        The goal is to maintain a clean, structured layout without compromising on readability or accessibility.
        
        This is an example of a GPT-generated response. The generated text will dynamically resize the card vertically, allowing users to view all the content without scrolling. The card itself adjusts based on the length of the text.

        By leveraging SwiftUI's flexibility, this layout ensures the Save button remains at the very bottom, even as the content grows. This approach enhances usability and visual appeal for longer pieces of text.

        For instance, imagine you're taking notes during a lecture or summarizing a detailed conversation. The text may span several paragraphs, and this card is designed to accommodate that seamlessly. Here's another line to make this example more realistic.
        
        The goal is to maintain a clean, structured layout without compromising on readability or accessibility.
        """

    var body: some View {
        ZStack(alignment: .leading) {
            // Background card with shadow
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.background)
                .shadow(radius: 3)

            // Content
            VStack(alignment: .leading, spacing: 10) {
                // Header Text
                Text("Notes")
                    .font(.custom("Inter", size: 28).weight(.bold))
                    .foregroundColor(.textSet)
                    .padding(.leading, 20)
                    .padding(.top, 20)

                // GPT Response
                Text(gptResponse)
                    .font(.custom("Inter", size: 16))
                    .foregroundColor(.textSet)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)

                // Save Button
                Button(action: {
                    // Add action here
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
    DisplayNotesCard()
}
