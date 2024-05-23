//
//  LocationManager.swift
//  AttestDemo
//
//  Created by Kaylee George on 5/22/24.
//

import Foundation
import CoreLocation

class LocationManager {
    static let shared = LocationManager()

    private let locationManager = CLLocationManager()

    func setup() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func getCurrentLocation() -> (Double, Double)? {
        guard let locValue: CLLocationCoordinate2D = locationManager.location?.coordinate else { return nil }
        return (locValue.latitude, locValue.longitude)
    }
}
