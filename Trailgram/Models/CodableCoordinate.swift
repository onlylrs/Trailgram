//
//  CodableCoordinate.swift
//  Trailgram
//
//  Created by 刘闰生 on 8/4/2025.
//



import Foundation
import CoreLocation


/// A Codable wrapper around CLLocationCoordinate2D to enable easy encoding/decoding for persistence.
struct CodableCoordinate: Codable, Hashable {
    var latitude: Double
    var longitude: Double

    var clCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    init(from coord: CLLocationCoordinate2D) {
        self.latitude = coord.latitude
        self.longitude = coord.longitude
    }

    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
