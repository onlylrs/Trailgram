//
//  FirebaseStorageManager.swift
//  Trailgram
//
//  Created by 刘闰生 on 14/4/2025.
//

import Foundation
import FirebaseStorage
import UIKit

class FirebaseStorageManager {
    static let shared = FirebaseStorageManager()
    private let storage = Storage.storage()
    private let bucketName = "trailgram.firebasestorage.app" // ⬅️ 改为你的 bucket ID

    func uploadImage(_ image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            return completion(.failure(NSError(domain: "InvalidImageData", code: -1)))
        }

        let filename = UUID().uuidString + ".jpg"
        let storageRef = storage.reference().child("posters/\(filename)")
        

        // ✅ 上传数据
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        storageRef.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                return completion(.failure(error))
            }

            // ✅ 确保上传成功再获取 URL
            storageRef.downloadURL { url, error in
                if let error = error {
                    return completion(.failure(error))
                }
                if let url = url {
                    completion(.success(url))
                } else {
                    completion(.failure(NSError(domain: "NoDownloadURL", code: -3)))
                }
            }
        }
    }
//    func uploadImageAsync(_ image: UIImage) async throws -> String {
//        let storageRef = Storage.storage().reference()
//        let filename = "posters/\(UUID().uuidString).jpg"
//        let imageRef = storageRef.child(filename)
//
//        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
//            throw URLError(.cannotDecodeContentData)
//        }
//
//        // putDataAsync 是 Firebase 的 async 方法（需要 Firebase SDK 支持 iOS concurrency）
//        _ = try await imageRef.putDataAsync(imageData, metadata: nil)
//        let url = try await imageRef.downloadURL()
//        return url.absoluteString
//    }
    func uploadImageAsync(_ image: UIImage) async throws -> String {
        let storageRef = Storage.storage().reference()
        let imageName = UUID().uuidString + ".jpg"
        let imageRef = storageRef.child("posters/\(imageName)")

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "ImageError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to JPEG data"])
        }

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        _ = try await imageRef.putDataAsync(imageData, metadata: metadata)

        // ✅ 获取带 token 的公开下载 URL
        let downloadURL = try await imageRef.downloadURL()
        return downloadURL.absoluteString
    }
}
