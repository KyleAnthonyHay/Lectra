//
//  TabBar.swift
//  Lectra
//
//  Created by Kyle-Anthony Hay on 4/5/25.
//

import SwiftUI

struct TabBar: View {
    var onAddButtonTapped: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            TabBarButton(icon: "house.fill", isSelected: true)
            TabBarButton(icon: "magnifyingglass", isSelected: false)
            
            // Middle add button
            Button(action: onAddButtonTapped) {
                Image(systemName: "plus")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.blue)
                    .clipShape(Circle())
            }
            .padding(.horizontal, 8)
            
            TabBarButton(icon: "tray.fill", isSelected: false)
            TabBarButton(icon: "gearshape", isSelected: false)
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .overlay(Divider(), alignment: .top)
    }
}

struct TabBarButton: View {
    let icon: String
    let isSelected: Bool
    
    var body: some View {
        Button(action: {}) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isSelected ? .primary : .gray)
                .frame(maxWidth: .infinity)
        }
    }
}


#Preview {
    TabBar(onAddButtonTapped: {
        print("Add button tapped")
    })
}
