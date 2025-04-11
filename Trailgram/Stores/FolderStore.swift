//
//  FolderStore.swift
//  Trailgram
//
//  Created by 刘闰生 on 8/4/2025.
//

import Foundation

@Observable
class FolderStore {
    var focusCoordinate: CoordinateWrapper? = nil
    var folders: [Folder] = []
    var tempSpot: MemorySpot? = nil

    private let saveURL: URL

    init(filename: String = "folders.json") {
        let manager = FileManager.default
        let docs = manager.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.saveURL = docs.appendingPathComponent(filename)

        load()
        
        if folders.isEmpty {
                let defaultFolder = Folder(name: "My Spots")
                folders.append(defaultFolder)
                save()
        }
    }

    func addFolder(_ folder: Folder) {
        folders.append(folder)
        save()
    }
    
    func addFolder(name: String) {
        let folder = Folder(name: name)
        folders.append(folder)
        save()
    }
    
    func addFolder(_ name: String, to parentID: UUID) {
        let newFolder = Folder(id: UUID(), name: name, spots: [], children: [])

        for i in 0..<folders.count {
            if let updated = insertFolder(newFolder, into: &folders[i], to: parentID) {
                folders[i] = updated
                save()
                return
            }
        }
    }
    private func insertFolder(_ folder: Folder, into current: inout Folder, to targetID: UUID) -> Folder? {
        if current.id == targetID {
            current.children.append(folder)
            return current
        }

        for i in 0..<current.children.count {
            if let updated = insertFolder(folder, into: &current.children[i], to: targetID) {
                current.children[i] = updated
                return current
            }
        }

        return nil
    }


    func updateFolder(_ folder: Folder) {
        if let index = folders.firstIndex(where: { $0.id == folder.id }) {
            folders[index] = folder
            save()
        }
    }

    func deleteFolder(_ folder: Folder) {
        folders.removeAll { $0.id == folder.id }
        save()
    }
    
    func deleteFolderRecursive(_ folder: Folder) {
        for i in 0..<folders.count {
            if let updated = removeFolderRecursive(folder.id, from: &folders[i]) {
                folders[i] = updated
                save()
                return
            }
        }
    }

    private func removeFolderRecursive(_ id: UUID, from folder: inout Folder) -> Folder? {
        folder.children.removeAll { $0.id == id }

        for i in 0..<folder.children.count {
            if let updated = removeFolderRecursive(id, from: &folder.children[i]) {
                folder.children[i] = updated
            }
        }

        return folder
    }
    
    func replaceFolder(_ updated: Folder) {
        for i in 0..<folders.count {
            if let replaced = replaceFolder(in: &folders[i], with: updated) {
                folders[i] = replaced
                save()
                return
            }
        }
    }

    private func replaceFolder(in current: inout Folder, with updated: Folder) -> Folder? {
        if current.id == updated.id {
            return updated
        }
        for i in 0..<current.children.count {
            if let replaced = replaceFolder(in: &current.children[i], with: updated) {
                current.children[i] = replaced
                return current
            }
        }
        return nil
    }
    
    func appendSpot(_ spot: MemorySpot, to folderID: UUID) {
        for i in 0..<folders.count {
            if let updated = insertSpot(spot, into: &folders[i], to: folderID) {
                folders[i] = updated
                save()
                return
            }
        }
    }

    private func insertSpot(_ spot: MemorySpot, into folder: inout Folder, to targetID: UUID) -> Folder? {
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
    
    func updateFolderRecursive(_ updatedFolder: Folder) {
        for i in 0..<folders.count {
            if let new = applyUpdate(to: &folders[i], updatedFolder: updatedFolder) {
                folders[i] = new
                save()
                return
            }
        }
    }

    private func applyUpdate(to folder: inout Folder, updatedFolder: Folder) -> Folder? {
        if folder.id == updatedFolder.id {
            folder = updatedFolder
            return folder
        }

        for i in 0..<folder.children.count {
            if let new = applyUpdate(to: &folder.children[i], updatedFolder: updatedFolder) {
                folder.children[i] = new
                return folder
            }
        }

        return nil
    }


    func save() {
        do {
            let data = try JSONEncoder().encode(folders)
            try data.write(to: saveURL, options: [.atomic, .completeFileProtection])
            print("✅ Saved folders to: \(saveURL.lastPathComponent)")
        } catch {
            print("❌ Failed to save folders: \(error)")
        }
    }

    func load() {
        do {
            let data = try Data(contentsOf: saveURL)
            folders = try JSONDecoder().decode([Folder].self, from: data)
            print("📂 Loaded folders: \(folders.count)")
        } catch {
            print("⚠️ No saved folders found or failed to load: \(error)")
            folders = []
        }
    }
    
    func findFolderID(for spot: MemorySpot) -> UUID? {
        for folder in folders {
            if let found = search(for: spot, in: folder) {
                return found.id
            }
        }
        return nil
    }

    private func search(for spot: MemorySpot, in folder: Folder) -> Folder? {
        if folder.spots.contains(where: { $0.id == spot.id }) {
            return folder
        }

        for child in folder.children {
            if let found = search(for: spot, in: child) {
                return found
            }
        }

        return nil
    }
    
    func name(for id: UUID?) -> String? {
        guard let id else { return nil }
        return searchName(id: id, in: folders)
    }

    private func searchName(id: UUID, in folders: [Folder]) -> String? {
        for folder in folders {
            if folder.id == id {
                return folder.name
            } else if let found = searchName(id: id, in: folder.children) {
                return found
            }
        }
        return nil
    }
}

extension FolderStore {
    var allSpots: [MemorySpot] {
        folders.flatMap { collectSpots(in: $0) }
    }

    private func collectSpots(in folder: Folder) -> [MemorySpot] {
        var result = folder.spots
        for child in folder.children {
            result += collectSpots(in: child)
        }
        return result
    }
}

extension FolderStore {
    var allFoldersFlat: [Folder] {
        var result: [Folder] = []

        func collect(from folder: Folder) {
            result.append(folder)
            for child in folder.children {
                collect(from: child)
            }
        }

        for folder in folders {
            collect(from: folder)
        }
        return result
    }
}

extension FolderStore {
    var rootFolder: Folder {
        Folder(id: UUID(), name: "All", spots: [], children: folders)
    }
    func folder(at path: [UUID]) -> Folder? {
        var current = Folder(id: UUID(), name: "All", spots: [], children: folders)
        for id in path {
            if let next = current.children.first(where: { $0.id == id }) {
                current = next
            } else {
                return nil
            }
        }
        return current
    }
}
