//                      _                 _       _
//                   __| |_   _  ___ _ __| | __ _| |__
//                  / _` | | | |/ _ \ '__| |/ _` | '_ \
//                 | (_| | |_| |  __/ |  | | (_| | |_) |
//                  \__,_|\__, |\___|_|  |_|\__,_|_.__/
//                        |_ _/
//
//         Making Population Genetic Software That Doesn't Suck
//
//  Copyright (c) 2021-2025 The Dyer Laboratory.  All Rights Reserved.
//
//  Distances.swift
//  DLabMatrix
//
//  Created by Rodney Dyer on 5/23/25.
//  Copyright (c) 2021-2025 The Dyer Laboratory.  All Rights Reserved.
//

import Foundation
import CoreLocation

/** Distance between two points in km
 - Parameters:
    - coordinate1: The first coordinate
    - coordinate2: The other coordiante
 - Returns: The distance in kilometers.
 */
public func distanceBetween(_ coordinate1: CLLocationCoordinate2D, _ coordinate2: CLLocationCoordinate2D) -> Double {
    let location1 = CLLocation(latitude: coordinate1.latitude, longitude: coordinate1.longitude)
    let location2 = CLLocation(latitude: coordinate2.latitude, longitude: coordinate2.longitude)
    return location1.distance(from: location2) / 1000.0 // Distance in kilometers
}





public extension Array where Element == Node {
    
    var PhysicalDistance: Matrix {
        let N = self.count
        var ret = Matrix(N,N, .infinity)
        
        for i in 0 ..< N {
            if let coord1 = self[i].location?.coordinate {
                for j in i ..< N {
                    if let coord2 = self[j].location?.coordinate {
                        let dist = distanceBetween( coord1, coord2 )
                        ret[i,j] = dist
                        ret[j,i] = dist
                    }
                }
            }
        }
        return ret
    }
    
}
