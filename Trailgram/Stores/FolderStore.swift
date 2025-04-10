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
