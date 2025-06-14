//
//  BlurModifiers.swift
//  Lectra
//
//  Created by Cascade AI on 6/13/25.
//

import SwiftUI

struct BottomBlurModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content
            
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
            .frame(height: 120)
            .padding(.bottom, -30)
            .blur(radius: 12)
            .allowsHitTesting(false) // Ensures touches pass through to content below
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .edgesIgnoringSafeArea(.bottom)
    }
}

extension View {
    func bottomBlur() -> some View {
        self.modifier(BottomBlurModifier())
    }
}
