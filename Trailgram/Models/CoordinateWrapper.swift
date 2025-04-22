//
//  CoordinateWrapper.swift
//  Trailgram
//
//  Created by 刘闰生 on 8/4/2025.
//

import Foundation
import CoreLocation

/// A lightweight wrapper used to compare coordinates with Equatable conformance.
/// Useful when CLLocationCoordinate2D alone doesn't conform to Equatable.
struct CoordinateWrapper: Equatable {
    let coordinate: CLLocationCoordinate2D

    static func == (lhs: CoordinateWrapper, rhs: CoordinateWrapper) -> Bool {
        lhs.coordinate.latitude == rhs.coordinate.latitude &&
        lhs.coordinate.longitude == rhs.coordinate.longitude
    }
}


