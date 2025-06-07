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
        ZStack(alignment: .bottom) {
            // Gradient blur effect with increasing intensity
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color.clear, location: 0),
                    .init(color: Color(.systemBackground).opacity(0.2), location: 0.3),
                    .init(color: Color(.systemBackground).opacity(0.4), location: 0.5),
                    .init(color: Color(.systemBackground).opacity(0.6), location: 0.7),
                    .init(color: Color(.systemBackground).opacity(0.9), location: 1.0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 120) // Increased height for more gradual effect
            .padding(.bottom, -30) // Extend past the bottom edge
            .blur(radius: 12)
            
            // Button container
            VStack {
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
                        .shadow(radius: 4, y: 2)
                }
                .padding(.bottom, 30)
                .padding(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .ignoresSafeArea(.all, edges: .bottom) // Ignore all safe areas at bottom
        .edgesIgnoringSafeArea(.bottom) // Additional safe area ignore for older iOS versions
    }
}

#Preview {
    PlusButton(onAddButtonTapped: {
        print("Add button tapped")
    })
}
