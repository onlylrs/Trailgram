//
//  HTMLToImageAPI.swift
//  Trailgram
//
//  Created by 刘闰生 on 13/4/2025.
//

import Foundation

import UIKit

/// A wrapper around the HTMLCSStoImage API for generating images from HTML.
enum HTMLToImageAPI {
    static let apiKey = "4c884c2f-7648-4629-90fb-5186ffe1a542"
    static let endpoint = URL(string: "https://hcti.io/v1/image")!
    static let userID = "05b0d5c3-c2a2-4ea8-8910-174a56b5dc91"
    
    /// Sends a POST request to render the given HTML string as an image.
    /// - Parameter html: The HTML string to render.
    /// - Returns: A `UIImage` rendered from the HTML.
    static func generateImage(from html: String) async throws -> UIImage {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // Base64 encode: userID:apiKey
        let authString = "\(userID):\(apiKey)"
        let authData = authString.data(using: .utf8)!.base64EncodedString()
        request.setValue("Basic \(authData)", forHTTPHeaderField: "Authorization")

        // Encode HTML body
        let bodyComponents = [
            "html": html,
            "ms_delay": "500"
        ]

        let bodyString = bodyComponents
            .map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }
            .joined(separator: "&")

        request.httpBody = bodyString.data(using: .utf8)
        
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("📡 Response code: \(httpResponse.statusCode)")
        }
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw NSError(domain: "HTTPError", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed with status code: \(statusCode)"])
        }

        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let urlString = json["url"] as? String,
           let imageURL = URL(string: urlString),
           let imageData = try? Data(contentsOf: imageURL),
           let image = UIImage(data: imageData) {
            return image
        } else {
            throw URLError(.badServerResponse)
        }
    }
    
    
}

