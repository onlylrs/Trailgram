//
//  FolderDetailView.swift
//  Trailgram
//
//  Created by 刘闰生 on 8/4/2025.
//

import SwiftUI

struct FolderDetailView: View {
    @Environment(FolderStore.self) var folderStore
    var folderID: UUID

    @State private var newSubfolderName: String = ""
    @State private var selectedFolderToRename: Folder?
    @State private var folderToDelete: Folder?
    @State private var renameText: String = ""
    @State private var showRenameAlert = false
    @State private var showDeleteConfirm = false
    
    @State private var folder: Folder = Folder(name: "")
    func reloadFolder() {
            folder = folderStore.allFoldersFlat.first(where: { $0.id == folderID }) ?? Folder(id: folderID, name: "Unknown", spots: [], children: [])
        }

    var body: some View {
        List {
            // 添加子 Folder 区域
            Section(header: Text("Add Subfolder")) {
                HStack {
                    TextField("Subfolder name", text: $newSubfolderName)
                    Button("Add") {
                        folderStore.addFolder(newSubfolderName, to: folderID)
                        newSubfolderName = ""
                        reloadFolder()
                    }
                    .disabled(newSubfolderName.isEmpty)
                }
            }

            // 子 Folder 列表
            Section(header: Text("Subfolders")) {
                ForEach(folder.children) { subfolder in
//                    NavigationLink(destination: FolderDetailView(folderID: subfolder.id)) {
//                        Label(subfolder.name, systemImage: "folder.fill")
//                    }
                    FolderRow(
                                folder: subfolder,
                                onRename: { f in
                                    selectedFolderToRename = f
                                    renameText = f.name
                                    showRenameAlert = true
                                },
                                onDelete: { f in
                                    folderToDelete = f
                                    showDeleteConfirm = true
                                }
                            )
                
                    
                }
                
            }

            // Spot 列表
            Section(header: Text("Spots")) {
                ForEach(folder.spots) { spot in
                    NavigationLink(destination: MemorySpotDetailView(spot: spot, parentFolderID: folder.id)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(spot.title).font(.headline)

                            if !spot.description.isEmpty {
                                Text(spot.description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                        }
                    }
                }
                .onDelete { indexSet in
                    var updated = folder
                    for index in indexSet {
                        updated.spots.remove(at: index)
                    }
                    folderStore.updateFolderRecursive(updated)
                    reloadFolder()
                }
            }
        }
        .navigationTitle(folder.name)
        .onAppear {
            reloadFolder()
        }
        .alert("Rename Folder", isPresented: $showRenameAlert) {
                    TextField("New name", text: $renameText)
                    Button("Save") {
                        if var folderToRename = selectedFolderToRename {
                            folderToRename.name = renameText
                            folderStore.updateFolder(folderToRename)
                            folderStore.updateFolderRecursive(folderToRename)
                            reloadFolder()
                        }
                    }
                    Button("Cancel", role: .cancel) {}
                }

                .alert("Delete this folder?", isPresented: $showDeleteConfirm) {
                    Button("Delete", role: .destructive) {
                        if let folder = folderToDelete {
                            folderStore.deleteFolderRecursive(folder)
                            reloadFolder()
                        }
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("All subfolders and spots will be permanently removed.")
                }
    }
}

struct FolderRow: View {
    var folder: Folder
    var onRename: (Folder) -> Void
    var onDelete: (Folder) -> Void
    
    var body: some View {
        NavigationLink(destination: FolderDetailView(folderID: folder.id)) {
            HStack {
                Label(folder.name, systemImage: "folder.fill")
                Spacer()
            }
        }
        // 关键：把 swipe 或 contextMenu 放到外面 wrapper，而不是 NavigationLink 上
        .background(Color.clear)
        .contentShape(Rectangle()) // ✅ 让整行可交互
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                onDelete(folder)
            } label: {
                Label("Delete", systemImage: "trash")
            }
            Button {
                onRename(folder)
            } label: {
                Label("Rename", systemImage: "pencil")
            }
            .tint(.orange)
        }
    }
}

#Preview {
//    FolderDetailView()
}
