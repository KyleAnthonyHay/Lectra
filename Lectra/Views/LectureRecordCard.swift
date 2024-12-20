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
                print("Play Button Pressed")
                // Add play button functionality here
            }) {
                Image(systemName: "play.circle.fill")
                    .resizable()
                    .foregroundColor(.icon)
                    .frame(width: 50, height: 50)
            }
            .padding(.leading, 16)

            Spacer()
        }
        .frame(width: 360, height: 110)
        .background(Color.background)
        .cornerRadius(16)
        .shadow(radius: 12)
    }
}

#Preview {
    LectureRecordCard()
}
