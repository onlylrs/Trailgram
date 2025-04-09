//
//  MemoryStore.swift
//  Trailgram
//
//  Created by 刘闰生 on 8/4/2025.
//

import Foundation
import MapKit
import Observation

@Observable
class MemoryStore {
//    var memorySpots: [MemorySpot] = [
//        // Mock 数据
//        MemorySpot(
//            title: "Shibuya Crossing",
//            description: "A must-visit in Tokyo!",
//            coordinate: CLLocationCoordinate2D(latitude: 35.6595, longitude: 139.7005),
//            date: Date()
//        )
//    ]
    
    var focusCoordinate: CoordinateWrapper? = nil
    var hasJustAddedSpot: Bool = false
    var shouldLocateOnLaunch: Bool = true

    var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.6586, longitude: 139.7454), // 默认东京
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
}

