//
//  GenerateNotesCard.swift
//  Lectra
//
//  Created by Kyle-Anthony Hay on 12/20/24.
//

import SwiftUI

struct GenerateNotesCard: View {
    var body: some View {
        ZStack {
            // Background card with shadow
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.background)
                .frame(width: 363, height: 188)
                .shadow(radius: 8)

            // Content
            VStack(alignment: .leading, spacing: 16) {
                // Header Text
                VStack(alignment: .leading, spacing: 8) {
                    Text("Generate Notes")
                        .font(.custom("Inter", size: 24).weight(.heavy))
                        .foregroundColor(.textSet)

                    Text("Transcribe lectures into concise PowerPoints and detailed notes for efficient learning.")
                        .font(.custom("Inter", size: 12))
                        .foregroundColor(.secondary)
                }.frame(width: 250)

                // Generate Button
                Button(action: {
                    // Add action here
                    print("Generate button tapped")
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .foregroundColor(.white)
                        Text("Generate")
                            .font(.custom("Inter", size: 18).weight(.medium))
                            .foregroundColor(.white)
                    }
                    .padding()
                    .frame(width: 292, height: 49)
                    .background(.icon)
                    .cornerRadius(9)
                    .shadow(radius: 5)
                }
            }
        }
        .frame(width: 363, height: 188)
    }
}

#Preview {
    GenerateNotesCard()
}
