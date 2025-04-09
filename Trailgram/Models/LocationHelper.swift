//
//  LocationHelper.swift
//  Trailgram
//
//  Created by 刘闰生 on 8/4/2025.
//

import Foundation
import CoreLocation
func reverseGeocode(_ coordinate: CLLocationCoordinate2D, completion: @escaping (String) -> Void) {
    let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
        if let placemark = placemarks?.first {
            let name = placemark.name ?? ""
            let street = placemark.thoroughfare ?? ""
            let city = placemark.locality ?? ""
            let address = [name, street, city].filter { !$0.isEmpty }.joined(separator: ", ")
            completion(address)
        } else {
            completion("Unknown location")
        }
    }
}
