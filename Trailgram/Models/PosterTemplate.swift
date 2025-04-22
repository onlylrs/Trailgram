//
//  PosterTemplate.swift
//  Trailgram
//
//  Created by 刘闰生 on 13/4/2025.
//

import Foundation

/// Enumerates different visual styles for rendering a MemorySpot as HTML posters.
/// Used by the HTML-to-image API to generate travel posters.
enum PosterTemplate: String, CaseIterable, Identifiable {
    case classic
    case pastel
    case card

    var id: String { rawValue }
    
    /// Generates an HTML string for the poster in the selected template style, given a MemorySpot, address, and optional image URL.
    func renderHTML(for spot: MemorySpot, at address: String = "", withImage imageURL: String? = nil) -> String? {
        guard let imageURL = imageURL else { return nil }

        switch self {
        case .classic:
            return """
            <html style="font-family: sans-serif;">
              <body style="padding: 20px; text-align: center;">
                <h1>\(spot.title)</h1>
                <img src="\(imageURL)" style="max-width: 90%; border-radius: 12px;" />
                <p><strong>Location:</strong> \(address)</p>
                <p>\(spot.description)</p>
              </body>
            </html>
            """

        case .pastel:
            return """
            <html>
            <head>
              <style>
                body {
                  background: #fdf6e3;
                  color: #333;
                  font-family: 'Georgia', serif;
                  padding: 20px;
                  text-align: center;
                }
                img {
                  max-width: 85%;
                  border-radius: 15px;
                  box-shadow: 0 4px 8px rgba(0,0,0,0.1);
                }
                h1 {
                  color: #d17c78;
                }
                .desc {
                  font-style: italic;
                  color: #555;
                }
              </style>
            </head>
            <body>
              <h1>\(spot.title)</h1>
              <img src="\(imageURL)" />
              <p><strong>\(address)</strong></p>
              <p class="desc">\(spot.description)</p>
            </body>
            </html>
            """

        case .card:
            return """
            <html>
            <head>
              <style>
                body {
                  background: #1e1e2f;
                  color: #ffffff;
                  font-family: 'Helvetica Neue', sans-serif;
                  display: flex;
                  align-items: center;
                  justify-content: center;
                  height: 100vh;
                }
                .card {
                  background: #2e2e3e;
                  border-radius: 12px;
                  padding: 20px;
                  max-width: 400px;
                  box-shadow: 0 8px 16px rgba(0,0,0,0.3);
                  text-align: center;
                }
                img {
                  max-width: 100%;
                  border-radius: 8px;
                }
                h1 {
                  color: #ffa94d;
                }
              </style>
            </head>
            <body>
              <div class="card">
                <h1>\(spot.title)</h1>
                <img src="\(imageURL)" />
                <p><strong>\(address)</strong></p>
                <p>\(spot.description)</p>
              </div>
            </body>
            </html>
            """
        }
    }
}
