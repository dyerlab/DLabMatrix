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
//  
//
//  Created by Rodney Dyer on 5/6/22.
//  Copyright (c) 2021-2025 The Dyer Laboratory.  All Rights Reserved.

import Foundation

public struct Edge: Codable {
    public var from: UUID
    public var to: UUID
    public var weight: Double
    
    public init(from: Node, to: Node, weight: Double ) {
        self.from = from.id
        self.to = to.id
        self.weight = weight
    }
}


extension Edge: Equatable {
    public static func ==(lhs: Edge, rhs: Edge) -> Bool {
        return lhs.from == rhs.from && lhs.to == rhs.to && lhs.weight == rhs.weight
    }
}


extension Edge: CustomStringConvertible {
    public var description: String {
        return String( "\(from.description) -> \(to.description)  \(self.weight)")
    }
}
