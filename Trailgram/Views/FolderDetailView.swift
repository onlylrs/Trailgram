//
//  FolderDetailView.swift
//  Trailgram
//
//  Created by 刘闰生 on 8/4/2025.
//

import SwiftUI

struct FolderDetailView: View {
    @Environment(FolderStore.self) var folderStore

    @State var folder: Folder
    @State private var newSubfolderName: String = ""

    var body: some View {
        List {
            // 添加子 Folder 区域
            Section(header: Text("Add Subfolder")) {
                HStack {
                    TextField("Subfolder name", text: $newSubfolderName)
                    Button("Add") {
                        var updated = folder
                        let newFolder = Folder(name: newSubfolderName)
                        updated.children.append(newFolder)
                        folderStore.updateFolder(updated)
                        folder = updated
                        newSubfolderName = ""
                    }
                    .disabled(newSubfolderName.isEmpty)
                }
            }

            // 子 Folder 列表
            Section(header: Text("Subfolders")) {
                ForEach(folder.children, id: \.id) { subfolder in
                    NavigationLink(destination: FolderDetailView(folder: subfolder)) {
                        Label(subfolder.name, systemImage: "folder.fill")
                    }
                }
            }

            // Spot 列表
            Section(header: Text("Spots")) {
                ForEach(folder.spots, id: \.id) { spot in
                    NavigationLink(destination: MemorySpotDetailView(spot: spot, parentFolderID: folder.id)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(spot.title)
                                .font(.headline)

                            if !spot.description.isEmpty {
                                Text(spot.description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                        }
                        .frame(maxHeight: .infinity, alignment: .center) // ✅ 垂直居中
                    }
                }
                .onDelete { indexSet in
                    var updated = folder
                    for index in indexSet {
                        updated.spots.remove(at: index)
                    }
                    folderStore.updateFolder(updated)
                    folder = updated
                }
            }
        }
        .navigationTitle(folder.name)
    }
}

#Preview {
//    FolderDetailView()
}
