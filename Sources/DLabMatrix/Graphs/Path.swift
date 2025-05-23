//                      _                 _       _
//                   __| |_   _  ___ _ __| | __ _| |__
//                  / _` | | | |/ _ \ '__| |/ _` | '_ \
//                 | (_| | |_| |  __/ |  | | (_| | |_) |
//                  \__,_|\__, |\___|_|  |_|\__,_|_.__/
//                        |_ _/
//
//         Making Population Genetic Software That Doesn't Suck
//
//  Path.swift
//  DLabMatrix
//
//  Created by Rodney Dyer on 5/22/25.
//  Copyright (c) 2021-2025 The Dyer Laboratory.  All Rights Reserved.
//

import Foundation


public struct Path: Identifiable, Hashable, CustomStringConvertible {
    public var id: UUID
    
    public var source: Node
    public var destination: Node
    public var sequence: [Node]
    public var length: Double
    
    public init(source: Node, destination: Node, sequence: [Node] = [], distance: Double = 0.0) {
        self.id = UUID()
        self.source = source
        self.destination = destination
        self.sequence = sequence
        self.length = distance
    }
    
    public static func == (lhs: Path, rhs: Path) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public var description: String {
        var ret = "\(source.label) -> \(destination.label); dist=\(length); path = "
        for node in sequence {
            if node != sequence.first! {
                ret += " -> \(node.label)"
            } else {
                ret += "\(node.label)"
            }
        }
        return ret
    }
    
}

