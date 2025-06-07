//
//  TabBar.swift
//  Lectra
//
//  Created by Kyle-Anthony Hay on 4/5/25.
//

import SwiftUI

struct PlusButton: View {
    var onAddButtonTapped: () -> Void
    
    var body: some View {
        HStack {
            Spacer()
            
            // Plus button
            Button(action: onAddButtonTapped) {
                Image(systemName: "plus")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(LectraColors.brand)
                    .clipShape(Circle())
            }
            .padding(.bottom, 30) // Add extra padding to lift it up from the bottom
        }
        .padding(.horizontal)
        .background(LectraColors.background)
    }
}

#Preview {
    PlusButton(onAddButtonTapped: {
        print("Add button tapped")
    })
}
