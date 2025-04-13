//
//  MemorySpotDetailView.swift
//  Trailgram
//
//  Created by 刘闰生 on 8/4/2025.
//

import SwiftUI
import PhotosUI

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
    @State private var showImagePicker = false

    @State private var selectedImageItem: PhotosPickerItem? = nil
    @State private var image: UIImage? = nil
    @State private var showFullImageViewer: Bool = false
    
    let originalSpot: MemorySpot
    
    init(spot: MemorySpot, parentFolderID: UUID) {
        self.originalSpot = spot
        self._spot = State(initialValue: spot)
        self.parentFolderID = parentFolderID
    }
    
    
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
            
            Section(header: Text("Image")) {
                VStack(alignment: .leading, spacing: 10) {
                    if let filename = spot.imagePath {
                        let url = FileManager.default
                            .urls(for: .documentDirectory, in: .userDomainMask)
                            .first!
                            .appendingPathComponent(filename)

                        if let uiImage = UIImage(contentsOfFile: url.path) {
                            // 全屏查看
                            Button(action: {
                                showFullImageViewer = true
                            }) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .cornerRadius(12)
                            }
                            .buttonStyle(.plain)

                            // 删除按钮
                            if isEditing {
                                Button(role: .destructive) {
                                    spot.imagePath = nil
                                } label: {
                                    Label("Remove Picture", systemImage: "trash")
                                }
                            }
                        } else {
                            Text("⚠️ Image not found at path.")
                        }

                    } else {
                        if isEditing {
                            PhotosPicker(selection: $selectedImageItem, matching: .images) {
                                Label("Add Picture", systemImage: "plus")
                                    .foregroundColor(.blue)
                            }
                            .onChange(of: selectedImageItem) { newItem in
                                if let item = newItem {
                                    Task {
                                        if let data = try? await item.loadTransferable(type: Data.self),
                                           let uiImage = UIImage(data: data) {
                                            let filename = UUID().uuidString + ".jpg"
                                            let url = FileManager.default
                                                .urls(for: .documentDirectory, in: .userDomainMask)
                                                .first!
                                                .appendingPathComponent(filename)
                                            if let jpegData = uiImage.jpegData(compressionQuality: 0.8) {
                                                try? jpegData.write(to: url)
                                                spot.imagePath = filename  // ✅ 只存文件名
                                                print("✅ Saved image to: \(url.path)")
                                            }
                                        }
                                    }
                                }
                            }
                        } else {
                            Text("No image added")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 5)
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
                    if isEditing {
                        spot = originalSpot  // ✅ 重置 UI 的绑定状态
                    }
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
        .fullScreenCover(isPresented: $showFullImageViewer) {
            if let filename = spot.imagePath {
                let url = FileManager.default
                    .urls(for: .documentDirectory, in: .userDomainMask)
                    .first!
                    .appendingPathComponent(filename)

                if let image = UIImage(contentsOfFile: url.path) {
                    ZStack {
                        Color.black.ignoresSafeArea()
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .onTapGesture {
                                showFullImageViewer = false
                            }
                    }
                }
            }
        }
    }
    

    func saveSpot() {
        for i in 0..<folderStore.folders.count {
            if let updated = updateSpot(in: &folderStore.folders[i], with: spot) {
                folderStore.folders[i] = updated
                folderStore.save()
                break
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
