//
//  CoordinateWrapper.swift
//  Trailgram
//
//  Created by 刘闰生 on 8/4/2025.
//

import Foundation
import CoreLocation

struct CoordinateWrapper: Equatable {
    let coordinate: CLLocationCoordinate2D

    static func == (lhs: CoordinateWrapper, rhs: CoordinateWrapper) -> Bool {
        lhs.coordinate.latitude == rhs.coordinate.latitude &&
        lhs.coordinate.longitude == rhs.coordinate.longitude
    }
}


