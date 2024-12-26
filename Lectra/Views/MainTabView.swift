//
//  MainTabView.swift
//  Lectra
//
//  Created by Kyle-Anthony Hay on 12/25/24.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            FolderView()
                .tabItem {
                    Label("Folder", systemImage: "folder")
                }
            RecordView()
                .tabItem {
                    Label("Record", systemImage: "mic.circle")
                }


        }
    }
}

#Preview {
    MainTabView()
}

