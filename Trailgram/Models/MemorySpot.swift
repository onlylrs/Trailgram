//
//  MemorySpot.swift
//  Trailgram
//
//  Created by 刘闰生 on 8/4/2025.
//

import Foundation
import CoreLocation

struct MemorySpot: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var description: String
    var coordinateWrapper: CodableCoordinate
    var date: Date
//    var imagePaths: [String] = []
    var imagePath: String? = nil

    var coordinate: CLLocationCoordinate2D {
        coordinateWrapper.clCoordinate
    }

    init(title: String, description: String, coordinate: CLLocationCoordinate2D, date: Date = Date(), imagePath: String? = nil) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.coordinateWrapper = CodableCoordinate(from: coordinate)
        self.date = date
        self.imagePath = imagePath
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, latitude, longitude, imagePath
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        let lat = try container.decode(CLLocationDegrees.self, forKey: .latitude)
        let lon = try container.decode(CLLocationDegrees.self, forKey: .longitude)
        coordinateWrapper = CodableCoordinate(latitude: lat, longitude: lon)
        imagePath = try container.decodeIfPresent(String.self, forKey: .imagePath)
        date = Date()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encodeIfPresent(imagePath, forKey: .imagePath)
    }
}

struct SelectedSpot: Identifiable, Hashable {
    let id = UUID() // 唯一 ID，只用于 navigation 匹配
    let spot: MemorySpot
    let folderID: UUID
}
