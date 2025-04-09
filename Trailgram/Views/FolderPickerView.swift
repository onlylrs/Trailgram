//
//  FolderPickerView.swift
//  Trailgram
//
//  Created by 刘闰生 on 8/4/2025.
//

import SwiftUI

struct FolderPickerView: View {
    @Environment(FolderStore.self) var folderStore
    @Environment(\.dismiss) var dismiss
    var onSelect: (UUID) -> Void

    var body: some View {
        NavigationStack {
            List {
                ForEach(folderStore.folders) { folder in
                    FolderRow(folder: folder, onSelect: onSelect)
                }
            }
            .navigationTitle("Choose Folder")
        }
    }
}

struct FolderRow: View {
    var folder: Folder
    var onSelect: (UUID) -> Void

    var body: some View {
        Section {
            Button(folder.name) {
                onSelect(folder.id)
            }
            ForEach(folder.children) { child in
                FolderRow(folder: child, onSelect: onSelect)
                    .padding(.leading, 16)
            }
        }
    }
}


#Preview {
//    FolderPickerView()
}
