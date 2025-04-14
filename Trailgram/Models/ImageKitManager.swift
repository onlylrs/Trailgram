//
//  ImageKitUploader.swift
//  Trailgram
//
//  Created by 刘闰生 on 14/4/2025.
//

import Foundation
import UIKit

class ImageKitManager {
    static let shared = ImageKitManager()

    private let uploadURL = URL(string: "https://upload.imagekit.io/api/v1/files/upload")!
    private let privateKey = "private_+/JyfgGTO6iTL9lPvzZjUNgkek4="

    func uploadImage(_ image: UIImage, fileName: String = UUID().uuidString + ".jpg") async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "ImageEncoding", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to encode image"])
        }

        var request = URLRequest(url: uploadURL)
        request.httpMethod = "POST"

        // Basic Auth
        let authString = "\(privateKey):"
        let authData = authString.data(using: .utf8)!.base64EncodedString()
        request.setValue("Basic \(authData)", forHTTPHeaderField: "Authorization")

        // Form boundary
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        // Form body
        var body = Data()
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        body.append("\r\n")

        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"fileName\"\r\n\r\n")
        body.append(fileName)
        body.append("\r\n")

        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"useUniqueFileName\"\r\n\r\n")
        body.append("true")
        body.append("\r\n")

        body.append("--\(boundary)--\r\n")
        request.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResp = response as? HTTPURLResponse, httpResp.statusCode == 200 else {
            print("❌ HTTP status: \((response as? HTTPURLResponse)?.statusCode ?? -999)")
            throw NSError(domain: "UploadFailed", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }

        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        if let url = json?["url"] as? String {
            return url
        } else {
            throw NSError(domain: "ParseFailed", code: -3, userInfo: [NSLocalizedDescriptionKey: "URL not found in response"])
        }
    }
}

// Data extension for boundary encoding
extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
