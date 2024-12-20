//
//  ContentView.swift
//  Lectra
//
//  Created by Kyle-Anthony Hay on 12/19/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack (spacing: 30) {
            LectureRecordCard()
            GenerateNotesCard()
        }
        
    }
}

#Preview {
    ContentView()
}
