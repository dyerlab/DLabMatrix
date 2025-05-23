//                      _                 _       _
//                   __| |_   _  ___ _ __| | __ _| |__
//                  / _` | | | |/ _ \ '__| |/ _` | '_ \
//                 | (_| | |_| |  __/ |  | | (_| | |_) |
//                  \__,_|\__, |\___|_|  |_|\__,_|_.__/
//                        |_ _/
//
//         Making Population Genetic Software That Doesn't Suck
//
//  Node.swift
//
//  Created by Rodney Dyer on 5/6/22.
//  Copyright (c) 2021-2025 The Dyer Laboratory.  All Rights Reserved.

import Foundation

public struct Node : Codable, Identifiable, Hashable {
    public let id: UUID
    public var name: String
    public var size: Double
    public var color: String
    
    public var coordinate: GeoCoordinate?
    public var position: Vector?
    
    enum CodingKeys: String, CodingKey {
        case id
        case label
        case size
        case color
        case coordinate
        case position
    }
    
    public init(label: String, size: Double, coord: GeoCoordinate? = nil, position: Vector? = nil, color: String = "#cc00000") {
        self.id = UUID()
        self.name = label
        self.size = size
        self.coordinate = coord
        self.position = position
        self.color = color
    }
    
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode( UUID.self, forKey: .id )
        name = try values.decode( String.self, forKey: .label )
        size = try values.decode( Double.self, forKey: .size )
        coordinate = try values.decodeIfPresent( GeoCoordinate.self, forKey: .coordinate )
        position = try values.decodeIfPresent( Vector.self, forKey: .position)
        color = try values.decode( String.self, forKey: .color )
    }
    
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id )
        try container.encode(name, forKey: .label )
        try container.encode(size, forKey: .size )
        try container.encodeIfPresent(coordinate, forKey: .coordinate )
        try container.encodeIfPresent(position, forKey: .position)
        try container.encode(color, forKey: .color )
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Node: Equatable {
    public static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.id == rhs.id
    }
}


extension Node: CustomStringConvertible {
    public var description: String {
        return String("\(name): \(size) ( \(String(describing: self.coordinate) )")
    }
}
