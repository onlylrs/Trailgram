//
//  MemoryStore.swift
//  Trailgram
//
//  Created by 刘闰生 on 8/4/2025.
//

import Foundation
import MapKit
import Observation

/// MemoryStore manages map-related transient state and app-wide flags
/// related to location tracking and newly added memory spots.
///
/// This includes the currently focused coordinate, whether to trigger auto-location,
/// and the visible MKCoordinateRegion for the map UI.
@Observable
class MemoryStore {
    /// The coordinate that the app UI should focus on, such as after selecting or adding a spot.
    var focusCoordinate: CoordinateWrapper? = nil
    
    /// Indicates whether a spot has just been added, used for triggering animations or UI updates.
    var hasJustAddedSpot: Bool = false
    
    /// Determines whether the app should center on the user's location upon launch.
    var shouldLocateOnLaunch: Bool = true

    /// The visible map region used by MapKit, centered by default on Tokyo.
    var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.6586, longitude: 139.7454), // default: Tokyo
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
}

