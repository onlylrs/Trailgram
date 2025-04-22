//
//  FirestoreService.swift
//  Trailgram
//
//  Created by 刘闰生 on 4/20/25.
//

import Foundation
import FirebaseFirestore

/// A singleton wrapper around Firebase Firestore API for saving and fetching user folders and spots.
class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()

    /// Saves a folder into the user's Firestore document.
        /// - Parameters:
        ///   - folder: The Folder object to save.
        ///   - userId: The UID of the user.
    func saveFolder(_ folder: Folder, userId: String) async throws {
        let ref = db.collection("users").document(userId).collection("folders").document(folder.id.uuidString)
        try ref.setData(from: folder)
    }
    
    /// Fetches all folders belonging to the given user.
        /// - Parameter userId: The UID of the user.
        /// - Returns: An array of Folders.
    func fetchFolders(userId: String) async throws -> [Folder] {
        let snapshot = try await db.collection("users").document(userId).collection("folders").getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: Folder.self) }
    }

    // 同理 MemorySpot 的增删改查也在这里实现
}
