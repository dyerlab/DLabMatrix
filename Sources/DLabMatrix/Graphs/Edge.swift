//
//  File.swift
//  
//
//  Created by Rodney Dyer on 5/6/22.
//

import Foundation

struct Edge: Codable {
    var from: UUID
    var to: UUID
    var weight: Double
    
    init(from: Node, to: Node, weight: Double ) {
        self.from = from.id
        self.to = to.id
        self.weight = weight
    }
}


extension Edge: Equatable {
    static func ==(lhs: Edge, rhs: Edge) -> Bool {
        return lhs.from == rhs.from && lhs.to == rhs.to && lhs.weight == rhs.weight
    }
}


extension Edge: CustomStringConvertible {
    var description: String {
        return String( "\(from.description) -> \(to.description)  \(self.weight)")
    }
}
