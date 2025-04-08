//
//  Folder.swift
//  Trailgram
//
//  Created by 刘闰生 on 8/4/2025.
//

import Foundation
struct Folder: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var children: [Folder] = []
    var spots: [MemorySpot] = []

    init(name: String) {
        self.id = UUID()
        self.name = name
    }
}

