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

    var coordinate: CLLocationCoordinate2D {
        coordinateWrapper.clCoordinate
    }

    init(title: String, description: String, coordinate: CLLocationCoordinate2D, date: Date = Date()) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.coordinateWrapper = CodableCoordinate(from: coordinate)
        self.date = date
    }
}




