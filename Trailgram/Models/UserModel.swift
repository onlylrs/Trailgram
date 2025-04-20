//
//  UserModel.swift
//  Trailgram
//
//  Created by 刘闰生 on 4/20/25.
//

import Foundation

import FirebaseFirestore

struct AppUser: Identifiable, Codable {
    @DocumentID var id: String? // Firebase Auth UID
    var name: String
    var email: String
    var createdAt: Date = Date()
}
