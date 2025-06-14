//
//  RecentItemCard.swift
//  Lectra
//
//  Created by Kyle-Anthony Hay on 4/5/25.
//

import SwiftUI

import SwiftUI

import SwiftUI

struct RecentItemCard: View {
    let item: Folder
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack {
                Rectangle()
                    .fill(LectraColors.brand)
                    .frame(height: 120)
                    .cornerRadius(8, corners: [.topLeft, .topRight])
                
                VStack {
                    Spacer()
                    HStack {
                        Image(systemName: "folder")
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
                }
            }
            
            Text(item.name)
                .font(.caption)
                .padding(8)
                .lineLimit(1)
                .truncationMode(.tail)
                .foregroundColor(.primary)
        }
        .frame(width: 150, height: 150)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
}

#Preview {
    RecentItemCard(item: TuplePreviewData().dummyFolder)
}
