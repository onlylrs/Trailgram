//
//  TravelPosterViewModel.swift
//  Trailgram
//
//  Created by 刘闰生 on 13/4/2025.
//

import Foundation
import SwiftUI
import Observation
import CoreLocation
import FirebaseStorage

@MainActor
@Observable
class TravelPosterViewModel {
    var selectedFolderID: UUID? = nil
    var selectedTemplate: PosterTemplate = .classic
    var generatedImages: [UIImage] = []
    var isGenerating = false
    var errorMessage: String? = nil
    var addressMap: [UUID: String] = [:]
    var tempImagePaths: [String] {
        generatedImages.map { $0.saveToTemp() }
    }
    
    func generatePosters(for folder: Folder) async {
        isGenerating = true
        generatedImages = []
        errorMessage = nil

        let spots = folder.spots // or allSpots
        let geocoder = CLGeocoder()
        
        for spot in spots {
            var address = "Unknown location"
            let location = CLLocation(latitude: spot.coordinate.latitude, longitude: spot.coordinate.longitude)
            
            
            do {
                let placemarks = try await geocoder.reverseGeocodeLocation(location)
                if let placemark = placemarks.first {
                    address = [placemark.name, placemark.locality, placemark.country]
                        .compactMap { $0 }
                        .joined(separator: ", ")
                }
                print("geocoding success")
                
            } catch {
                print("❌ Reverse geocoding failed: \(error.localizedDescription)")
                errorMessage = error.localizedDescription
            }
            
            var imageURL: String? = nil
            if let localPath = spot.imagePath {
                print("🪪 imagePath = \(localPath)")

                let fullPath: String
                if localPath.hasPrefix("/") {
                    fullPath = localPath
                } else {
                    fullPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(localPath).path
                }

                if let uiImage = UIImage(contentsOfFile: fullPath) {
                    do {
                        print("try await upload")
//                        imageURL = try await FirebaseStorageManager.shared.uploadImageAsync(uiImage)
                        imageURL = try await ImageKitManager.shared.uploadImage(uiImage, fileName: "poster-\(spot.id).jpg")
                        print("✅ Uploaded. URL = \(imageURL)")
                    } catch {
                        print("❌ Firebase upload failed: \(error.localizedDescription)")
                    }
                } else {
                    print("❌ Failed to load image from path: \(fullPath)")
                }
                
            }
            print("🖼️ imageURL to embed: \(imageURL ?? "nil")")
            
            
            if let html = selectedTemplate.renderHTML(for: spot, at: address, withImage: imageURL) {
                do {
                    let image = try await HTMLToImageAPI.generateImage(from: html)
                    generatedImages.append(image)
                } catch {
                    print("❌ API error: \(error.localizedDescription)")
                    errorMessage = error.localizedDescription
                }
            }
        }
        
        isGenerating = false
    }

    func clear() {
        generatedImages = []
    }
    func resolveAddresses(for spots: [MemorySpot]) {
        for spot in spots {
            if addressMap[spot.id] == nil {
                reverseGeocode(spot.coordinate) { address in
                    Task { @MainActor in
                        self.addressMap[spot.id] = address
                    }
                }
            }
        }
    }
}
