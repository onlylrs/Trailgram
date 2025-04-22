//
//  AddMemoryViewModel.swift
//  Trailgram
//
//  Created by 刘闰生 on 4/21/25.
//

import Foundation
import SwiftUI
import CoreLocation
import PhotosUI

@Observable
class AddMemoryViewModel {
    // MARK: - Input Bindings
    var title: String = ""
    var note: String = ""
    var selectedCoordinate: CLLocationCoordinate2D? = nil
    var selectedFolderID: UUID? = nil
    var readableAddress: String = ""
    var imagePath: String? = nil
    var selectedImageItem: PhotosPickerItem? = nil
    var showFullImageViewer: Bool = false
    var showSearchView = false
    var showFolderPicker = false
    var capturedImage: UIImage? = nil

    // MARK: - External Store (injected)
    var folderStore: FolderStore?
    var dismissAction: () -> Void = {}

    // MARK: - Init
    init(prefillCoordinate: CLLocationCoordinate2D? = nil) {
        self.selectedCoordinate = prefillCoordinate
        if let coord = prefillCoordinate {
            reverseGeocode(coord)
        } else {
            requestCurrentLocation()
        }
    }

    // MARK: - Location
    func requestCurrentLocation() {
        let manager = CLLocationManager()
        manager.requestWhenInUseAuthorization()
        if let location = manager.location {
            let coord = location.coordinate
            selectedCoordinate = coord
            reverseGeocode(coord)
        }
    }

    func reverseGeocode(_ coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, _ in
            if let placemark = placemarks?.first {
                let name = placemark.name ?? ""
                let street = placemark.thoroughfare ?? ""
                let city = placemark.locality ?? ""
                self.readableAddress = [name, street, city].filter { !$0.isEmpty }.joined(separator: ", ")
            } else {
                self.readableAddress = "Unknown location"
            }
        }
    }

    // MARK: - Image Handling
    func processSelectedImageItem() async {
        guard let item = selectedImageItem else { return }
        do {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                try saveImageToDisk(uiImage)
            }
        } catch {
            print("❌ Error processing image item: \(error.localizedDescription)")
        }
    }

    func saveCapturedImageToDisk() {
        guard let image = capturedImage else { return }
        try? saveImageToDisk(image)
    }

    private func saveImageToDisk(_ image: UIImage) throws {
        let filename = UUID().uuidString + ".jpg"
        let url = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent(filename)

        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try jpegData.write(to: url)
            imagePath = filename
            print("✅ Saved image to: \(url.path)")
        }
    }

    // MARK: - Save
    func save() {
        guard let coord = selectedCoordinate,
              let folderID = selectedFolderID,
              let store = folderStore else { return }

        let newSpot = MemorySpot(
            title: title,
            description: note,
            coordinate: coord,
            imagePath: imagePath
        )

        store.appendSpot(newSpot, to: folderID)
        store.focusCoordinate = CoordinateWrapper(coordinate: coord)
        dismissAction()
    }

    func reverseGeocodeIfNeeded() {
        if let coord = selectedCoordinate {
            reverseGeocode(coord)
        }
    }
}
