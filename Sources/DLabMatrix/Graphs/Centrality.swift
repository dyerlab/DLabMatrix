//                      _                 _       _
//                   __| |_   _  ___ _ __| | __ _| |__
//                  / _` | | | |/ _ \ '__| |/ _` | '_ \
//                 | (_| | |_| |  __/ |  | | (_| | |_) |
//                  \__,_|\__, |\___|_|  |_|\__,_|_.__/
//                        |_ _/
//
//         Making Population Genetic Software That Doesn't Suck
//
//  Centrality.swift
//  DLabMatrix
//
//  Created by Rodney Dyer on 5/22/25.
//  Copyright (c) 2021-2025 The Dyer Laboratory.  All Rights Reserved.

import Foundation

/*
public func OutDegreeCentrality( graph: Graph ) -> Vector {
    var ret = Vector(repeating: 0.0, count: graph.count )
    for edge in graph.edges {
        if let idx = graph.nodes.firstIndex(where: { $0.id == edge.from } ) {
            ret[idx] += 1.0
        }
    }
    return ret
}

public func InDegreeCentrality( graph: Graph ) -> Vector {
    var ret = Vector(repeating: 0.0, count: graph.count )
    for edge in graph.edges {
        if let idx = graph.nodes.firstIndex(where: { $0.id == edge.to } ) {
            ret[idx] += 1.0
        }
    }
    return ret
}

public func TotalDegreeCentrality( graph: Graph ) -> Vector {
    return OutDegreeCentrality(graph: graph) + InDegreeCentrality(graph: graph)
}



public func ClosenessCentrality(graph: Graph) -> Vector {
    let n = graph.count
    var ret = Vector(repeating: 0.0, count: n)

    for (i, source) in graph.nodes.enumerated() {
        var totalDistance = 0.0
        var reachableCount = 0

        for (j, target) in graph.nodes.enumerated() {
            if i == j { continue }
            if let path = graph.shortestPaths(in: graph, from: source, to: target) {
                totalDistance += path.distance
                reachableCount += 1
            }
        }

        if totalDistance > 0.0 && reachableCount > 0 {
            ret[i] = Double(reachableCount) / totalDistance
        } else {
            ret[i] = 0.0
        }
    }

    return ret
}

*/


/*
public func BetweennessCentrality(graph: Graph) -> Vector {
    let n = graph.count
    var ret = Vector(repeating: 0.0, count: n)

    for i in 0..<n {
        for j in 0..<n {
            if i == j { continue }
            guard let path = graph.shortestPath(from: graph.nodes[i], to: graph.nodes[j]) else { continue }

            for (k, node) in graph.nodes.enumerated() {
                if k != i && k != j && path.sequence.contains(where: { $0.id == node.id }) {
                    ret[k] += 1.0
                }
            }
        }
    }

    // Normalize (optional)
    let scale = Double((n - 1) * (n - 2))
    if scale > 0 {
        for i in 0..<n {
            ret[i] /= scale
        }
    }

    return ret
}

*/

/*
public func EigenvectorCentrality(graph: Graph) -> Vector?  {
    let A = AdjacentyMatrix(graph: graph, weighed: true)
    let n = A.rows
    guard n > 0 && A.cols == n else { return nil }
    
    var b_k = Vector(repeating: 1.0, count: n)
    let maxIterations = 1000
    let tolerance = 1e-6
    
    for _ in 0..<maxIterations {
        let b_k1 = A * b_k
        let norm = b_k1.norm()
        if norm == 0 {
            return nil
        }
        let b_k1_normalized = b_k1 / norm
        let diff = (b_k1_normalized - b_k).norm()
        b_k = b_k1_normalized
        if diff < tolerance {
            break
        }
    }
    
    return b_k
}
*/
