//                      _                 _       _
//                   __| |_   _  ___ _ __| | __ _| |__
//                  / _` | | | |/ _ \ '__| |/ _` | '_ \
//                 | (_| | |_| |  __/ |  | | (_| | |_) |
//                  \__,_|\__, |\___|_|  |_|\__,_|_.__/
//                        |_ _/
//
//         Making Population Genetic Software That Doesn't Suck
//
//  File.swift
//  DLabMatrix
//
//  Created by Rodney Dyer on 5/23/25.
//  Copyright (c) 2021-2025 The Dyer Laboratory.  All Rights Reserved.

import CoreLocation
import Foundation

public struct GeoCoordinate: Identifiable, Codable, Hashable {
    public var id: UUID
    public var latitude: Double
    public var longitude: Double
    
    public init(latitude: Double, longitude: Double) {
        self.id = UUID()
        self.latitude = latitude
        self.longitude = longitude
    }
    
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
