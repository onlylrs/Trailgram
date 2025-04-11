//
//  FolderListView.swift
//  Trailgram
//
//  Created by 刘闰生 on 8/4/2025.
//

import SwiftUI

enum ListMode: String, CaseIterable, Identifiable {
    case folders = "Folders"
    case spots = "All Spots"

    var id: String { rawValue }
}

struct FolderListView: View {
    @Environment(FolderStore.self) var folderStore
    @State private var newFolderName: String = ""
    @State private var mode: ListMode = .folders  // 默认是 Folder 模式
    @State private var selectedFolderToRename: Folder?
    @State private var folderToDelete: Folder?
    @State private var showRenameAlert = false
    @State private var showDeleteConfirm = false
    @State private var renameText: String = ""
    
    var body: some View {
        VStack {
            // ✅ 顶部 Picker 切换视图
            Picker("Mode", selection: $mode) {
                ForEach(ListMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.top)

            // ✅ 模式切换内容区域
            if mode == .folders {
                folderView
            } else {
                allSpotsView
            }
        }
        .navigationTitle("All Spots")
        .alert("Rename Folder", isPresented: $showRenameAlert, actions: {
            TextField("New name", text: $renameText)
            Button("Save") {
                if let folder = selectedFolderToRename {
                    var updated = folder
                    updated.name = renameText
                    folderStore.updateFolder(updated)
                }
            }
            Button("Cancel", role: .cancel) {}
        })

        .alert("Delete this folder?", isPresented: $showDeleteConfirm, actions: {
            Button("Delete", role: .destructive) {
                if let folder = folderToDelete {
                    folderStore.deleteFolder(folder)
                }
            }
            Button("Cancel", role: .cancel) {}
        }, message: {
            Text("All spots and subfolders will be removed.")
        })
    }

    var folderView: some View {
        List {
            Section(header: Text("New Folder")) {
                HStack {
                    TextField("Folder name", text: $newFolderName)
                    Button("Add") {
                        if !newFolderName.isEmpty {
                            folderStore.addFolder(name:  newFolderName)
                            newFolderName = ""
                        }
                    }
                    .disabled(newFolderName.isEmpty)
                }
            }

            Section(header: Text("Folders")) {
                ForEach(folderStore.folders) { folder in
                    NavigationLink(destination: FolderDetailView(folderID: folder.id)) {
                        Label(folder.name, systemImage: "folder.fill")
                    }
                    .contextMenu {
                        Button("Rename") {
                            selectedFolderToRename = folder
                            renameText = folder.name
                            showRenameAlert = true
                        }

                        Button("Delete", role: .destructive) {
                            folderToDelete = folder
                            showDeleteConfirm = true
                        }
                    }
                }
            }
        }
    }

    var allSpotsView: some View {
        List {
            ForEach(folderStore.allSpots) { spot in
                NavigationLink(destination: MemorySpotDetailView(spot: spot, parentFolderID: folderStore.findFolderID(for: spot) ?? UUID())) {
                    VStack(alignment: .leading) {
                        Text(spot.title).bold()
                        Text(spot.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

#Preview {
//    FolderListView()
}
