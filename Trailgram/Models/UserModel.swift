//
//  UserModel.swift
//  Trailgram
//
//  Created by 刘闰生 on 4/20/25.
//

import Foundation

import FirebaseFirestore

/// Represents a user account stored in Firestore with ID, name, and email metadata.
/// The ID is bound to Firebase Auth's UID via @DocumentID.
struct AppUser: Identifiable, Codable {
    @DocumentID var id: String? // Firebase Auth UID
    var name: String
    var email: String
    var createdAt: Date = Date()
}
