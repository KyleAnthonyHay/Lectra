//
//  EmptyFolderView.swift
//  Lectra
//
//  Created by Kyle-Anthony Hay on 2/26/25.
//

import SwiftUI
import SwiftData

struct EmptyFolderView: View {
    let folder: Folder
    @State private var isShowingNewRecordingDialog = false
    @State private var navigateToRecordView = false
    @State private var newRecordingName = ""
    @State private var selectedFolder: Folder? = nil
    @State private var didConfirmRecordingCreation = false
    @EnvironmentObject private var folderManager: FolderManager
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 70))
                .foregroundColor(LectraColors.brandSecondary)
            
            Text("No Transcriptions Yet")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Tap the + button to create your first transcription in '\(folder.name)'")
                .font(.body)
                .foregroundColor(LectraColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: {
                newRecordingName = ""
                selectedFolder = folder
                isShowingNewRecordingDialog = true
            }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Create Transcription")
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(LectraColors.brand)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding(.top, 10)
            
            Spacer()
            
            // Add tab bar for consistency
            TabBar(onAddButtonTapped: {
                newRecordingName = ""
                selectedFolder = folder
                isShowingNewRecordingDialog = true
            })
        }
        .sheet(isPresented: $isShowingNewRecordingDialog) {
            NewRecordingDialog(
                newRecordingName: $newRecordingName,
                selectedFolder: $selectedFolder,
                didConfirmCreation: $didConfirmRecordingCreation,
                rootDirectory: folderManager.rootDirectory
            )
            .onDisappear {
                if didConfirmRecordingCreation && !newRecordingName.isEmpty {
                    navigateToRecordView = true
                }
            }
        }
        .navigationDestination(isPresented: $navigateToRecordView) {
            RecordView(tupleName: newRecordingName, folder: selectedFolder)
        }
    }
}

#Preview {
    EmptyFolderView(folder: TuplePreviewData().dummyFolder)
        .environmentObject(FolderManager(modelContext: ModelContext(try! ModelContainer(for: Folder.self)), rootDirectory: RootDirectory()))
}
