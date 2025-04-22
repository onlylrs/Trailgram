//
//  Folder.swift
//  Trailgram
//
//  Created by 刘闰生 on 8/4/2025.
//

import Foundation

/// Represents a user-created folder that holds MemorySpots and potentially nested subfolders.
struct Folder: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var children: [Folder] = []
    var spots: [MemorySpot] = []

    init(name: String) {
        self.id = UUID()
        self.name = name
    }
    init(id: UUID, name: String, spots: [MemorySpot], children: [Folder]){
        self.id = id
        self.name = name
        self.spots = spots
        self.children = children
    }
}

extension Folder {
    /// Recursively collects all MemorySpots within this folder and its children.
    var allSpots: [MemorySpot] {
        var result = spots
        for child in children {
            result += child.allSpots
        }
        return result
    }
}


