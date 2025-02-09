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
            // !!!: Add Swift Data Root Directory Object
            FolderView(rootDirectory: PreviewData.rootDirectory)
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

