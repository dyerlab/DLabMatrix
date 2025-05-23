//                      _                 _       _
//                   __| |_   _  ___ _ __| | __ _| |__
//                  / _` | | | |/ _ \ '__| |/ _` | '_ \
//                 | (_| | |_| |  __/ |  | | (_| | |_) |
//                  \__,_|\__, |\___|_|  |_|\__,_|_.__/
//                        |_ _/
//
//         Making Population Genetic Software That Doesn't Suck
//
//  Graph.swift
//
//
//  Created by Rodney Dyer on 5/6/22.
//  Copyright (c) 2021-2025 The Dyer Laboratory.  All Rights Reserved.

import Foundation

public class Graph: Codable  {
    public var nodes: [Node]
    public var edges: [Edge]
    
    public init() {
        nodes = [Node]()
        edges = [Edge]()
    }
    
    enum CodingKeys : String, CodingKey {
        case nodes
        case edges
    }
    
    required public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.nodes = try container.decode([Node].self, forKey: .nodes)
        self.edges = try container.decode([Edge].self, forKey: .edges)
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(nodes, forKey: .nodes)
        try container.encode(edges, forKey: .edges)
    }
    
    public func addNode( label: String, size: Double, coordinate: GeoCoordinate? = nil, color: String = "#cc0000" ) {
        self.nodes.append( Node(label: label, size: size, coord: coordinate, color: color) )
    }
    
    public func addEdge( from: String, to: String, weight: Double, symmetric: Bool = true ) {
        guard let idx1 = nodes.firstIndex(where: {$0.label == from} ) else { return }
        guard let idx2 = nodes.firstIndex(where: {$0.label == to} )  else { return }
        let node1 = nodes[idx1]
        let node2 = nodes[idx2]
        let edge = Edge(from: node1, to: node2, weight: weight)
        self.edges.append( edge )
        
        if symmetric {
            let edge2 = Edge(from: node2, to: node1, weight: weight)
            self.edges.append( edge2 )
        }
    }
    
}

// MARK: - Properties calculated from graph
extension Graph {
    
    public var isSpatial: Bool {
        return self.nodes.compactMap { $0.location }.count > 0
    }
    
    public var count: Int {
        return nodes.count
    }
    
    public func node(id: UUID) -> Node? {
        return self.nodes.first(where: { $0.id == id })
    }
    
    public func node(name: String) -> Node? {
        return self.nodes.first(where: { $0.label == name })
    }
    
    public var adjacency: Matrix {
        let N = nodes.count
        let ret = Matrix(N, N)
        
        edges.forEach({ edge in
            if let idx1 = nodes.firstIndex(where: {$0.id == edge.from} ),
               let idx2 = nodes.firstIndex(where: {$0.id == edge.to} ) {
                ret[idx1, idx2] = 1
            }
        })
        
        ret.rowNames = nodes.map { $0.label }
        ret.colNames = nodes.map { $0.label }
        
        return ret
    }
    
    public var incidence: Matrix {
        let N = nodes.count
        let ret = Matrix(N, N)
        
        edges.forEach({ edge in
            if let idx1 = nodes.firstIndex(where: {$0.id == edge.from} ),
               let idx2 = nodes.firstIndex(where: {$0.id == edge.to} ) {
                ret[idx1, idx2] = edge.weight
            }
        })
        
        ret.rowNames = nodes.map { $0.label }
        ret.colNames = nodes.map { $0.label }
        
        return ret
    }
    
    public func edgesFrom( node: Node ) -> [Edge] {
        return self.edges.filter { $0.from == node.id }
    }
    
}






// MARK: - Printing
extension Graph: CustomStringConvertible {
    public var description: String {
        var ret = String()
        nodes.forEach({ node in
            ret += String("\(node)\n")
        })
        edges.forEach({ edge in
            ret += String("\(edge)\n")
        })
        return ret
    }
}




