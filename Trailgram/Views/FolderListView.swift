//
//  FolderListView.swift
//  Trailgram
//
//  Created by 刘闰生 on 8/4/2025.
//

import SwiftUI

struct FolderListView: View {
    @Environment(FolderStore.self) var folderStore

    @State private var newFolderName: String = ""

    var body: some View {
        List {
            Section(header: Text("New Folder")) {
                HStack {
                    TextField("Folder name", text: $newFolderName)
                    Button("Add") {
                        let newFolder = Folder(name: newFolderName)
                        folderStore.addFolder(newFolder)
                        newFolderName = ""
                    }
                    .disabled(newFolderName.isEmpty)
                }
            }

            Section(header: Text("Folders")) {
                ForEach(folderStore.folders, id: \.id) { folder in
                    NavigationLink(destination: FolderDetailView(folder: folder)) {
                        HStack {
                            Image(systemName: "folder")
                            Text(folder.name)
                        }
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        let folder = folderStore.folders[index]
                        folderStore.deleteFolder(folder)
                    }
                }
            }
        }
        .navigationTitle("All Folders")
    }
}

#Preview {
//    FolderListView()
}
