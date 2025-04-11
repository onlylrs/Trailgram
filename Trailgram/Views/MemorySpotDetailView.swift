//
//  MemorySpotDetailView.swift
//  Trailgram
//
//  Created by 刘闰生 on 8/4/2025.
//

import SwiftUI


struct MemorySpotDetailView: View {
    @Environment(FolderStore.self) var folderStore

    @State var spot: MemorySpot
    var parentFolderID: UUID
    @State private var isEditing = false
    @State private var showFolderPicker = false
    @Environment(\.dismiss) var dismiss
    @State private var showDeleteConfirm = false
    @State private var readableAddress: String = ""
    @State private var showMoveSuccessAlert = false
    
    var body: some View {
        Form {
            Section(header: Text("Title")) {
                TextField("Title", text: $spot.title)
                    .disabled(!isEditing)
                    
            }

            Section(header: Text("Description")) {
                TextEditor(text: $spot.description)
                    .frame(minHeight: 120)
                    .disabled(!isEditing)
            }

            Section(header: Text("Location")) {
                if !readableAddress.isEmpty {
                    Label(readableAddress, systemImage: "mappin.and.ellipse")
                        .font(.callout)
                        .foregroundColor(.secondary)
                    } else {
                        Text("Loading address...")
                            .foregroundColor(.gray)
                    }
            }
            
            Section {
                Button {
                    showDeleteConfirm = true
                } label:{
                    Text("Delete")
                        .foregroundStyle(.red)
                }
                .alert("Delete this spot?", isPresented: $showDeleteConfirm) {
                    Button("Delete", role: .destructive) {
                        deleteSpot()
                    }
                    Button("Cancel", role: .cancel) {}
                }
                
                Button("Move to Folder") {
                    showFolderPicker = true
                }
                
// 这个sheet一定要在该section里面不然就会有第一次点击Move to Folder会先弹出sheet然后立即索回去的情况
                .sheet(isPresented: $showFolderPicker) {
                    MoveToFolderView { newID in
                        moveSpot(to: newID)
                        showFolderPicker = false
                    }
                }
            }

            

            if isEditing {
                Button("Save Changes") {
                    saveSpot()
                    isEditing = false
                }
            }
        }
        .navigationTitle("Spot Details")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Cancel" : "Edit") {
                    isEditing.toggle()
                }
            }
        }
        .alert("Moved Successfully", isPresented: $showMoveSuccessAlert) {
            Button("OK", role: .cancel) { }
        }
        
        .onAppear {
            reverseGeocode(spot.coordinate) { address in
                readableAddress = address
            }
        }
    }

    func saveSpot() {
        for i in 0..<folderStore.folders.count {
            if folderStore.folders[i].id == parentFolderID {
                if let index = folderStore.folders[i].spots.firstIndex(where: { $0.id == spot.id }) {
                    folderStore.folders[i].spots[index] = spot
                    folderStore.save()
                    break
                }
            }
        }
    }

    // 递归遍历所有 folders / children，找到并更新 spot
    func updateSpot(in folder: inout Folder, with spot: MemorySpot) -> Folder? {
        if let index = folder.spots.firstIndex(where: { $0.id == spot.id }) {
            folder.spots[index] = spot
            return folder
        }

        for i in 0..<folder.children.count {
            if let updated = updateSpot(in: &folder.children[i], with: spot) {
                folder.children[i] = updated
                return folder
            }
        }
        return nil
    }
    
    func deleteSpot() {
        for i in 0..<folderStore.folders.count {
            if let updated = removeSpot(spot.id, from: &folderStore.folders[i]) {
                folderStore.folders[i] = updated
                folderStore.save()
                break
            }
        }
        dismiss()
    }

    func moveSpot(to newID: UUID) {
        // ✅ 自己移除原来的 spot
        for i in 0..<folderStore.folders.count {
            if let updated = removeSpot(spot.id, from: &folderStore.folders[i]) {
                folderStore.folders[i] = updated
                break
            }
        }

        // ✅ 插入到新的 folder
        for i in 0..<folderStore.folders.count {
            if let updated = insertSpot(spot, into: &folderStore.folders[i], to: newID) {
                folderStore.folders[i] = updated
                folderStore.save()
                break
            }
        }
        showMoveSuccessAlert = true
    }

    func removeSpot(_ id: UUID, from folder: inout Folder) -> Folder? {
        if let index = folder.spots.firstIndex(where: { $0.id == id }) {
            folder.spots.remove(at: index)
            return folder
        }

        for i in 0..<folder.children.count {
            if let updated = removeSpot(id, from: &folder.children[i]) {
                folder.children[i] = updated
                return folder
            }
        }
        return nil
    }

    func insertSpot(_ spot: MemorySpot, into folder: inout Folder, to targetID: UUID) -> Folder? {
        if folder.id == targetID {
            folder.spots.append(spot)
            return folder
        }
        for i in 0..<folder.children.count {
            if let updated = insertSpot(spot, into: &folder.children[i], to: targetID) {
                folder.children[i] = updated
                return folder
            }
        }
        return nil
    }
    
}



#Preview {
//    MemorySpotDetailView()
}
