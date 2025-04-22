import SwiftUI

/// MoveToFolderView provides a hierarchical folder browser used to move a spot or poster to a different folder.
/// Supports recursive navigation and subfolder creation.
struct MoveToFolderView: View {
    @Environment(FolderStore.self) var folderStore
    @Environment(\.dismiss) var dismiss

    let onSelect: (UUID) -> Void
    
    var confirmButtonText: String = "Put Here"
    @State private var folderStack: [Folder] = []
    @State private var showNewFolderAlert = false
    @State private var newFolderName = ""

    var currentFolder: Folder {
        folderStack.last ?? folderStore.rootFolder
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(currentFolder.children) { folder in
                    Button(action: {
                        withAnimation {
                            folderStack.append(folder)
                        }
                    }) {
                        Label(folder.name, systemImage: "folder")
                    }
                }

                if !currentFolder.spots.isEmpty {
                        Section(header: Text("Spots")) {
                            ForEach(currentFolder.spots) { spot in
                                VStack(alignment: .leading) {
                                    Text(spot.title).bold()
                                    if !spot.description.isEmpty {
                                        Text(spot.description)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                
                if currentFolder.spots.isEmpty && currentFolder.children.isEmpty {
                    Text("No items in this folder")
                        .foregroundColor(.secondary)
                }
            }
            .id(currentFolder.id) // 👈 每次 folder 变化都重建 List，触发 transition
            .transition(.move(edge: .trailing)) // 👈 平移效果
            .animation(.easeInOut(duration: 0.3), value: currentFolder.id) // 👈 添加动画
            
            .listStyle(.insetGrouped)
            .navigationTitle(currentFolder.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        if folderStack.count > 1 {
                            Button(action: {
                                withAnimation {
                                    _ = folderStack.popLast()
                                }
                            }) {
                                Label("Back", systemImage: "chevron.left")
                            }
                        }
                        Button(action: {
                            showNewFolderAlert = true
                        }) {
                            Image(systemName: "folder.badge.plus")
                        }
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(confirmButtonText) {
                        onSelect(currentFolder.id)
                        
                        // ✅ 强制刷新当前层级（触发视图更新）
                        if !folderStack.isEmpty {
                            let last = folderStack.removeLast()
                            folderStack.append(last)
                        }

                        dismiss()
                    }
                }
            }
            .alert("New Folder", isPresented: $showNewFolderAlert) {
                TextField("Folder name", text: $newFolderName)
                Button("Create") {
                    folderStore.addFolder(newFolderName, to: currentFolder.id)
                    newFolderName = ""
                    if let refreshed = folderStore.allFoldersFlat.first(where: { $0.id == currentFolder.id }) {
                        if !folderStack.isEmpty {
                            folderStack.removeLast()
                            folderStack.append(refreshed)
                        }
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
            .onAppear {
                folderStack = [folderStore.rootFolder]
            }
        }
    }
}

