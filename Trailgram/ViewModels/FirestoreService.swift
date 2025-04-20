//
//  FirestoreService.swift
//  Trailgram
//
//  Created by 刘闰生 on 4/20/25.
//

import Foundation
import FirebaseFirestore

class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()

    func saveFolder(_ folder: Folder, userId: String) async throws {
        let ref = db.collection("users").document(userId).collection("folders").document(folder.id.uuidString)
        try ref.setData(from: folder)
    }

    func fetchFolders(userId: String) async throws -> [Folder] {
        let snapshot = try await db.collection("users").document(userId).collection("folders").getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: Folder.self) }
    }

    // 同理 MemorySpot 的增删改查也在这里实现
}
