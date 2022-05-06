//
//  File.swift
//  
//
//  Created by Rodney Dyer on 5/6/22.
//

import Foundation

struct Node : Codable {
    let id: UUID
    var label: String
    var size: Double
    var edges: [Edge]
    var coordinate: Vector
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case label
        case size
        case edges
        case coordinate
    }
    
    
    init(label: String, size: Double, coord: [Double] ) {
        self.id = UUID()
        self.label = label
        self.size = size
        self.coordinate = coord
        self.edges = [Edge]()
    }
    
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode( UUID.self, forKey: .id )
        label = try values.decode( String.self, forKey: .label )
        size = try values.decode( Double.self, forKey: .size )
        edges = try values.decode( Array.self, forKey: .edges )
        coordinate = try values.decode( Vector.self, forKey: .coordinate )
    }
    
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id )
        try container.encode(label, forKey: .label )
        try container.encode(size, forKey: .size )
        try container.encode(edges, forKey: .edges )
        try container.encode(coordinate, forKey: .coordinate )
    }

}

extension Node: Equatable {
    
    static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.id == rhs.id
    }
    
}


extension Node: CustomStringConvertible {
    
    var description: String {
        return String("\(label): \(size) ( \(self.coordinate) )")
    }
    
}
