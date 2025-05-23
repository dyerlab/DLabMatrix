//                      _                 _       _
//                   __| |_   _  ___ _ __| | __ _| |__
//                  / _` | | | |/ _ \ '__| |/ _` | '_ \
//                 | (_| | |_| |  __/ |  | | (_| | |_) |
//                  \__,_|\__, |\___|_|  |_|\__,_|_.__/
//                        |_ _/
//
//         Making Population Genetic Software That Doesn't Suck
//
//  
//  Random.swift
//  DLabMatrix
//
//  Created by Rodney Dyer on 6/15/21.
//  Copyright (c) 2021-2025 The Dyer Laboratory.  All Rights Reserved.
//

import Foundation

/// Public struct to make random stuff for various types of numbers from a range
public struct Random {
    
    /// Returns a random variable of type T from the passed ragne
    ///  - Parameters:
    ///   - Range: the closed range to grab a random number from
    /// - Returns: The random number in the range.
    public static func within<T>(_ range: ClosedRange<T>) -> T where T: FloatingPoint, T: ExpressibleByFloatLiteral {
        return (range.upperBound - range.lowerBound) * (T(arc4random()) / T(UInt32.max)) + range.lowerBound
    }
    
}
