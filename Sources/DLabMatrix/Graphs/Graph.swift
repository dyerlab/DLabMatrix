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

public class Graph {
    public var nodes: [Node]
    public var edges: [Edge]
    
    public init() {
        nodes = [Node]()
        edges = [Edge]()
    }
    
    public func newNode( label: String, size: Double, coord: Vector = Vector(), color: String = "#cc0000" ) {
        self.nodes.append( Node(label: label, size: size, coord: coord, color: color) )
    }
    
    public func newEdge( from: String, to: String, weight: Double, symmetric: Bool = true ) {
        guard let idx1 = nodes.firstIndex(where: {$0.name == from} ) else { return }
        guard let idx2 = nodes.firstIndex(where: {$0.name == to} )  else { return }
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
    
    public var count: Int {
        return nodes.count
    }
    
    public func node(id: UUID) -> Node? {
        return self.nodes.first(where: { $0.id == id })
    }
    
    public func node(name: String) -> Node? {
        return self.nodes.first(where: { $0.name == name })
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
        
        ret.rowNames = nodes.map { $0.name }
        ret.colNames = nodes.map { $0.name }
        
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
        
        ret.rowNames = nodes.map { $0.name }
        ret.colNames = nodes.map { $0.name }
        
        return ret
    }
    
}


// MARK: - Algorithms
extension Graph {
    
    /** Degree Centrality
     The number of edges on a node.
     - Parameters:
     - Direction: One of Direction.In, Direction.Out, or Direction.Both
     - Returns: Vector of counts
     */
    public func degreeCentrality(direction: Direction = .Both) -> Vector {
        var ret = Vector(repeating: 0.0, count: self.count)
        
        for edge in self.edges {
            if direction == .Out,
               let idx = self.nodes.firstIndex(where: { $0.id == edge.from } ) {
                ret[idx] += 1.0
            }
            else if direction == .In,
                    let idx = self.nodes.firstIndex(where: { $0.id == edge.to } ) {
                ret[idx] += 1.0
            }
            else if direction == .Both,
                    let idx1 = self.nodes.firstIndex(where: { $0.id == edge.from } ),
                    let idx2 = self.nodes.firstIndex(where: { $0.id == edge.to } ) {
                ret[idx1] += 1.0
                ret[idx2] += 1.0
            }
        }
        return ret
    }
    
    
    /// Closeness Centrality
    /// Returns the closeness centrality of each node as a Vector.
    /// For each node, sum the shortest distances to all other nodes, and compute the inverse of the average shortest distance.
    public var closenessCentrality: Vector {
        let n = nodes.count
        var centrality = Vector(repeating: 0.0, count: n)
        for (i, node) in nodes.enumerated() {
            var sumDistances: Double = 0.0
            var reachable: Int = 0
            for (j, other) in nodes.enumerated() {
                if i == j { continue }
                let paths = allShortestPaths(from: node, to: other)
                if let minDist = paths.first?.distance, minDist < Double.infinity {
                    sumDistances += minDist
                    reachable += 1
                }
            }
            if reachable > 0 && sumDistances > 0.0 {
                centrality[i] = Double(reachable) / sumDistances
            } else {
                centrality[i] = 0.0
            }
        }
        return centrality
    }
    
    
    /** Shortest Path Matrix
     The Floyd Warshall method for determining the shortest path between all pairs of nodes.
     - Returns: Matrix of shortest path values.
     */
    public var shortestPaths: Matrix {
        let A = self.incidence
        let N = A.rows
        let D = Matrix(N,N)
        let gMax = A.values.sum + 1.0
        D.rowNames = A.rowNames
        D.colNames = A.colNames
        for i in 0 ..< N {
            for j in 0 ..< N {
                if i != j {
                    let val = A[i,j]
                    if val > 0 {
                        D[i,j] = val
                    }
                    else {
                        D[i,j] = gMax
                    }
                }
            }
        }
        for k in 0 ..< N {
            for i in 0 ..< N {
                for j in 0 ..< N {
                    let curDist = D[i,j]
                    let newDist = D[i,k] + D[k,j]
                    if newDist < gMax {
                        if curDist < gMax {
                            D[i,j] = Double.minimum( curDist, newDist)
                        } else {
                            D[i,j] = newDist
                        }
                    }
                }
            }
        }
        for i in 0 ..< N {
            for j in 0 ..< N {
                if D[i,j] == gMax {
                    D[i,j] = Double.infinity
                }
            }
        }
        return D
    }
    
    /// Returns the betweenness centrality of each node as a Vector.
    /// - Returns: A Vector corresponds to the node at the same index in the `nodes` array.
    public var betweennessCentrality: Vector {
        // Brandes' algorithm for betweenness centrality
        let n = nodes.count
        var centrality = Vector(repeating: 0.0, count: n)
        // Map node UUID to its index in the nodes array
        var nodeIndex: [UUID: Int] = [:]
        for (i, node) in nodes.enumerated() {
            nodeIndex[node.id] = i
        }
        for sIdx in 0..<n {
            var stack: [Int] = []
            var pred: [[Int]] = Array(repeating: [], count: n)
            var sigma = Vector(repeating: 0.0, count: n)
            var dist = Vector(repeating: -1.0, count: n)
            sigma[sIdx] = 1.0
            dist[sIdx] = 0.0
            var queue: [Int] = [sIdx]
            while !queue.isEmpty {
                let v = queue.removeFirst()
                stack.append(v)
                // For each neighbor w of v
                let vNode = nodes[v]
                for edge in edgesFrom(node: vNode) {
                    guard let w = nodeIndex[edge.to] else { continue }
                    // Path discovery
                    if dist[w] < 0 {
                        dist[w] = dist[v] + 1.0
                        queue.append(w)
                    }
                    // Path counting
                    if dist[w] == dist[v] + 1.0 {
                        sigma[w] += sigma[v]
                        pred[w].append(v)
                    }
                }
            }
            var delta = Vector(repeating: 0.0, count: n)
            while let w = stack.popLast() {
                for v in pred[w] {
                    delta[v] += (sigma[v] / sigma[w]) * (1.0 + delta[w])
                }
                if w != sIdx {
                    centrality[w] += delta[w]
                }
            }
        }
        // Normalize if undirected
        // For undirected graphs, divide by 2
        for i in 0..<n {
            centrality[i] /= 2.0
        }
        return centrality
    }
    
    /// Overload function to pass node names instead of instances.
    /// - Parameters:
    ///   - from: The starting node name.
    ///   - to: The ending node name.
    /// - Returns: An array of all shortest paths (as Path objects) from `from` to `to`.
    public func allShortestPaths(from: String, to: String) -> [Path] {
        
        if let fromNode = nodes.first( where: { $0.name == from }),
           let toNode = nodes.first( where: { $0.name == to }) {
            return allShortestPaths(from: fromNode, to: toNode)
        } else {
            return []
        }
        
    }
    
    /// Returns all shortest paths from a start node to an end node.
    /// - Parameters:
    ///   - from: The starting node.
    ///   - to: The ending node.
    /// - Returns: An array of all shortest paths (as Path objects) from `from` to `to`.
    public func allShortestPaths(from: Node, to: Node) -> [Path] {
        // Use a BFS to find all shortest paths from `from` to `to`
        // Each path is a list of nodes, and the shortest paths are those with minimal total weight.
        // We'll use a queue of partial paths (as arrays of nodes), and track visited nodes with the minimal path length.
        struct QueueElement {
            let path: [Node]
            let totalWeight: Double
        }
        var allPaths: [Path] = []
        var minWeight: Double? = nil
        var queue: [QueueElement] = [QueueElement(path: [from], totalWeight: 0.0)]
        while !queue.isEmpty {
            let elem = queue.removeFirst()
            let last = elem.path.last!
            if last == to {
                if minWeight == nil || elem.totalWeight < minWeight! {
                    minWeight = elem.totalWeight
                    allPaths = [Path(source: elem.path.first!, destination: elem.path.last!, sequence: elem.path, distance: elem.totalWeight)]
                } else if elem.totalWeight == minWeight! {
                    allPaths.append(Path(source: elem.path.first!, destination: elem.path.last!, sequence: elem.path, distance: elem.totalWeight))
                }
                continue
            }
            // Prune paths longer than minWeight
            if let minW = minWeight, elem.totalWeight > minW {
                continue
            }
            for edge in self.edgesFrom(node: last) {
                if let nextNode = self.nodes.first(where: { $0.id == edge.to }),
                   !elem.path.contains(where: { $0.id == nextNode.id }) {
                    queue.append(QueueElement(path: elem.path + [nextNode], totalWeight: elem.totalWeight + edge.weight))
                }
            }
        }
        return allPaths
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






// MARK: - Default Data

public extension Graph {
    
    static var smallGraph: Graph  {
        let g = Graph()
        
        g.newNode(label: "A", size: 1.0, color: "#cc0000" )
        g.newNode(label: "B", size: 1.0, color: "#00cc00" )
        g.newNode(label: "C", size: 1.5, color: "#0000cc" )
        g.newNode(label: "D", size: 2.0, color: "#cc00cc" )
        
        g.newEdge(from: "A", to: "B", weight: 1.0, symmetric: true )
        g.newEdge(from: "B", to: "C", weight: 2.0, symmetric: true )
        g.newEdge(from: "C", to: "A", weight: 3.0, symmetric: true )
        g.newEdge(from: "C", to: "D", weight: 4.0, symmetric: false )
        
        return g
        
    }
    
    static var arapatGraph: Graph  {
        let graph = Graph()
        
        // Add the nodes
        graph.newNode(label: "101", size:  10.9490045955937, coord: [27.90509, -110.57436] )
        graph.newNode(label: "102", size:  9.68145014548612, coord: [26.38014, -109.12633] )
        graph.newNode(label: "12", size:  12.3260340244982, coord: [27.18232, -112.66552] )
        graph.newNode(label: "153", size:  5.00000000000000, coord: [24.13389, -110.46236] )
        graph.newNode(label: "156", size:  15.7739521332150, coord: [24.04380, -109.989] )
        graph.newNode(label: "157", size:  9.12488981473130, coord: [24.01950, -110.096] )
        graph.newNode(label: "159", size:  9.24628269169598, coord: [27.52944, -113.31609] )
        graph.newNode(label: "160", size:  13.3048781144080, coord: [27.40498, -112.52959] )
        graph.newNode(label: "161", size:  7.79266120077634, coord: [27.03670, -112.986] )
        graph.newNode(label: "162", size:  13.6130742119043, coord: [27.20280, -112.408] )
        graph.newNode(label: "163", size:  7.22574979122061, coord: [24.21150, -110.951] )
        graph.newNode(label: "164", size:  8.50475107418203, coord: [24.74642, -111.5441] )
        graph.newNode(label: "165", size:  8.72623273027708, coord: [26.24905, -112.40948] )
        graph.newNode(label: "166", size:  9.93759174921716, coord: [25.91409, -112.08062] )
        graph.newNode(label: "168", size:  7.38729491413727, coord: [25.55757, -111.21563] )
        graph.newNode(label: "169", size:  6.31310815833131, coord: [26.20876, -111.37833] )
        graph.newNode(label: "171", size:  6.54306946125740, coord: [28.22308, -113.18263] )
        graph.newNode(label: "173", size:  9.10239582312499, coord: [28.40846, -112.86985] )
        graph.newNode(label: "175", size:  6.32305924218924, coord: [28.72796, -113.48973] )
        graph.newNode(label: "177", size:  6.81042761896269, coord: [28.66056, -113.99141] )
        graph.newNode(label: "32", size:  8.68353222841994, coord: [26.63783, -109.327] )
        graph.newNode(label: "48", size:  8.24885884064512, coord: [24.21441, -110.27252] )
        graph.newNode(label: "51", size:  12.8358470535089, coord: [25.34819, -111.60056] )
        graph.newNode(label: "58", size:  5.27092245836431, coord: [26.01550, -111.35475] )
        graph.newNode(label: "64", size:  6.56370519542057, coord: [25.60521, -111.32638] )
        graph.newNode(label: "73", size:  7.10527775393008, coord: [24.00789, -109.85071] )
        graph.newNode(label: "75", size:  10.9707923572130, coord: [24.58843, -110.74599] )
        graph.newNode(label: "77", size:  6.73709195620796, coord: [24.87611, -110.69175] )
        graph.newNode(label: "84", size:  12.9735260593506, coord: [28.96651, -113.66787] )
        graph.newNode(label: "88", size:  7.08939629053169, coord: [29.32541, -114.29353] )
        graph.newNode(label: "89", size:  10.9184471869574, coord: [28.03661, -113.39991] )
        graph.newNode(label: "9", size:  7.32844226695142, coord: [29.01457, -113.94486] )
        graph.newNode(label: "93", size:  7.77340539043297, coord: [26.94589, -112.04613] )
        graph.newNode(label: "98", size:  8.84132371819749, coord: [23.07570, -109.64869] )
        graph.newNode(label: "Aqu", size:  13.267567610943, coord: [23.28550, -110.10429] )
        graph.newNode(label: "Const", size:  12.1937472191309, coord: [25.0247, -111.675] )
        graph.newNode(label: "ESan", size:  8.14010246388221, coord: [24.45879, -110.36857] )
        graph.newNode(label: "Mat", size:  12.5451639866387, coord: [23.08984, -110.1091] )
        graph.newNode(label: "SFr", size:  5.95123204751839, coord: [27.36320, -112.964] )
        
        graph.newEdge( from: "101", to: "102", weight: 8.45324671861479, symmetric: true)
        graph.newEdge( from: "101", to: "32", weight: 11.3392934536416, symmetric: true)
        graph.newEdge( from: "102", to: "32", weight: 12.362907286415, symmetric: true)
        graph.newEdge( from: "12", to: "161", weight: 2.90432059242197, symmetric: true)
        graph.newEdge( from: "12", to: "165", weight: 3.53104375426366, symmetric: true)
        graph.newEdge( from: "12", to: "93", weight: 2.95907651440433, symmetric: true)
        graph.newEdge( from: "153", to: "165", weight: 4.01936959972293, symmetric: true)
        graph.newEdge( from: "153", to: "58", weight: 1.22917316036238, symmetric: true)
        graph.newEdge( from: "156", to: "157", weight: 4.03245913683026, symmetric: true)
        graph.newEdge( from: "156", to: "48", weight: 5.12419089808697, symmetric: true)
        graph.newEdge( from: "156", to: "73", weight: 5.02121609605313, symmetric: true)
        graph.newEdge( from: "156", to: "75", weight: 5.78348393054996, symmetric: true)
        graph.newEdge( from: "157", to: "48", weight: 4.35040106460888, symmetric: true)
        graph.newEdge( from: "157", to: "Aqu", weight: 4.73488748210723, symmetric: true)
        graph.newEdge( from: "157", to: "ESan", weight: 3.76005223133308, symmetric: true)
        graph.newEdge( from: "159", to: "171", weight: 2.84376688249322, symmetric: true)
        graph.newEdge( from: "159", to: "173", weight: 2.89614187678504, symmetric: true)
        graph.newEdge( from: "159", to: "89", weight: 4.16572420527594, symmetric: true)
        graph.newEdge( from: "160", to: "168", weight: 3.85617041124065, symmetric: true)
        graph.newEdge( from: "160", to: "169", weight: 2.70207873507271, symmetric: true)
        graph.newEdge( from: "160", to: "93", weight: 2.91697233762107, symmetric: true)
        graph.newEdge( from: "160", to: "SFr", weight: 2.93265079330762, symmetric: true)
        graph.newEdge( from: "161", to: "162", weight: 3.31649675878596, symmetric: true)
        graph.newEdge( from: "161", to: "165", weight: 3.11692197360928, symmetric: true)
        graph.newEdge( from: "161", to: "93", weight: 2.50373688639928, symmetric: true)
        graph.newEdge( from: "161", to: "SFr", weight: 2.78976954662207, symmetric: true)
        graph.newEdge( from: "162", to: "64", weight: 6.19795399169885, symmetric: true)
        graph.newEdge( from: "162", to: "77", weight: 4.93245306852764, symmetric: true)
        graph.newEdge( from: "162", to: "93", weight: 3.29009085293472, symmetric: true)
        graph.newEdge( from: "163", to: "75", weight: 9.51832446611554, symmetric: true)
        graph.newEdge( from: "163", to: "Const", weight: 8.2403521345715, symmetric: true)
        graph.newEdge( from: "163", to: "ESan", weight: 8.36864126827798, symmetric: true)
        graph.newEdge( from: "164", to: "165", weight: 4.24795854776905, symmetric: true)
        graph.newEdge( from: "164", to: "169", weight: 3.71002063341606, symmetric: true)
        graph.newEdge( from: "164", to: "51", weight: 5.87479501991043, symmetric: true)
        graph.newEdge( from: "164", to: "Const", weight: 4.67765457155977, symmetric: true)
        graph.newEdge( from: "164", to: "SFr", weight: 5.81109654957986, symmetric: true)
        graph.newEdge( from: "165", to: "168", weight: 3.33489401772703, symmetric: true)
        graph.newEdge( from: "165", to: "169", weight: 2.85506964665014, symmetric: true)
        graph.newEdge( from: "165", to: "77", weight: 4.37837128931743, symmetric: true)
        graph.newEdge( from: "166", to: "168", weight: 4.00335783307894, symmetric: true)
        graph.newEdge( from: "168", to: "51", weight: 5.89050582196516, symmetric: true)
        graph.newEdge( from: "168", to: "58", weight: 3.98073711030734, symmetric: true)
        graph.newEdge( from: "168", to: "64", weight: 4.40361382730535, symmetric: true)
        graph.newEdge( from: "168", to: "77", weight: 5.05214719304513, symmetric: true)
        graph.newEdge( from: "169", to: "58", weight: 2.93645031235043, symmetric: true)
        graph.newEdge( from: "169", to: "93", weight: 2.6340580477165, symmetric: true)
        graph.newEdge( from: "169", to: "SFr", weight: 2.63342673975013, symmetric: true)
        graph.newEdge( from: "171", to: "173", weight: 2.72117328085347, symmetric: true)
        graph.newEdge( from: "171", to: "175", weight: 3.18304152193125, symmetric: true)
        graph.newEdge( from: "173", to: "89", weight: 3.23348171031955, symmetric: true)
        graph.newEdge( from: "175", to: "177", weight: 1.84258746362758, symmetric: true)
        graph.newEdge( from: "175", to: "88", weight: 3.63957775022367, symmetric: true)
        graph.newEdge( from: "177", to: "88", weight: 2.99650028760203, symmetric: true)
        graph.newEdge( from: "177", to: "9", weight: 3.17634016214171, symmetric: true)
        graph.newEdge( from: "48", to: "ESan", weight: 3.48492608276231, symmetric: true)
        graph.newEdge( from: "51", to: "58", weight: 4.98332507330647, symmetric: true)
        graph.newEdge( from: "58", to: "SFr", weight: 3.56433514791232, symmetric: true)
        graph.newEdge( from: "64", to: "77", weight: 7.35584476681318, symmetric: true)
        graph.newEdge( from: "64", to: "SFr", weight: 4.4480950761091, symmetric: true)
        graph.newEdge( from: "73", to: "75", weight: 3.65872754021918, symmetric: true)
        graph.newEdge( from: "73", to: "Aqu", weight: 3.69526146781118, symmetric: true)
        graph.newEdge( from: "73", to: "ESan", weight: 3.6283788722433, symmetric: true)
        graph.newEdge( from: "77", to: "93", weight: 3.93301088197976, symmetric: true)
        graph.newEdge( from: "84", to: "88", weight: 4.49124569905757, symmetric: true)
        graph.newEdge( from: "84", to: "89", weight: 7.54705626431277, symmetric: true)
        graph.newEdge( from: "84", to: "9", weight: 4.40780576409764, symmetric: true)
        graph.newEdge( from: "88", to: "9", weight: 3.33802592490648, symmetric: true)
        graph.newEdge( from: "93", to: "SFr", weight: 2.38236384351171, symmetric: true)
        graph.newEdge( from: "98", to: "Mat", weight: 4.19608147299158, symmetric: true)
        graph.newEdge( from: "Aqu", to: "ESan", weight: 3.80626949664509, symmetric: true)
        
        return graph
    }
    
}
