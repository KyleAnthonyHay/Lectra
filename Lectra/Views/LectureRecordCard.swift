//
//  LecturePlayCard.swift
//  Lectra
//
//  Created by Kyle-Anthony Hay on 12/20/24.
//

import SwiftUI

struct LectureRecordCard: View {
    var body: some View {
        HStack {
            // Play Button
            Button(action: {
                // Add play button functionality here
            }) {
                Image(systemName: "play.circle.fill")
                    .resizable()
                    .foregroundColor(.blue)
                    .frame(width: 40, height: 40)
            }
            .padding(.leading, 16)

            Spacer()
        }
        .frame(width: 363, height: 119)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 24)
    }
}

#Preview {
    LectureRecordCard()
}
