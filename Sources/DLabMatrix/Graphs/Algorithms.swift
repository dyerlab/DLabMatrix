//
//  Algorithms.swift
//  DLabMatrix
//
//  Created by Rodney Dyer on 5/23/25.
//

import Foundation



/**  Graph based algorithms
 
 
 
 */
extension Graph {
    
    // MARK: - Measures of Node Centrality
    
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
                if let minDist = paths.first?.length, minDist < Double.infinity {
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

    
    /** Eigenvalue Centrality
     Estimated as the studentized dominant eigenvector of a weighted incidence matrix.
     - Returns: Vector of relative centrality
     */
    public var eigenvectorCentrality: Vector?  {
        guard let v = DominantEigenvector(A: self.incidence) else { return nil }
        return v.studentized
    }

    
    
    
    // MARK: - Graphwise parameters
    
    /** Properties based on edges
     - Returns: The longest of the shortest paths through the network.
     */
    public var diameter: Path? {
        let allPaths = self.allShortestPaths()
        return allPaths.sorted { $0.length > $1.length }.first
    }
    
    
    
    /** The strongly connected groups.
     This uses Kosaraju’s algorithm to estimate the number of strongly connected subgraphs.
     - Returns: Number of disconnected groups
     */
    public var stronglyConnectedComponents: [[String]] {
        let N = nodes.count
        guard N > 0 else { return [] }

        // Build adjacency list
        var adjList = [[Int]](repeating: [], count: N)
        for edge in edges {
            if let fromIndex = nodes.firstIndex(where: { $0.id == edge.from }),
               let toIndex = nodes.firstIndex(where: { $0.id == edge.to }) {
                adjList[fromIndex].append(toIndex)
            }
        }

        // First DFS to get finishing order
        var visited = [Bool](repeating: false, count: N)
        var finishStack = [Int]()

        func dfs1(_ u: Int) {
            visited[u] = true
            for v in adjList[u] {
                if !visited[v] {
                    dfs1(v)
                }
            }
            finishStack.append(u)
        }

        for i in 0..<N {
            if !visited[i] {
                dfs1(i)
            }
        }

        // Reverse graph
        var reversedAdjList = [[Int]](repeating: [], count: N)
        for u in 0..<N {
            for v in adjList[u] {
                reversedAdjList[v].append(u)
            }
        }

        // Second DFS on reversed graph
        visited = [Bool](repeating: false, count: N)
        var components = [[String]]()

        func dfs2(_ u: Int, component: inout [String]) {
            visited[u] = true
            component.append(nodes[u].label)
            for v in reversedAdjList[u] {
                if !visited[v] {
                    dfs2(v, component: &component)
                }
            }
        }

        for u in finishStack.reversed() {
            if !visited[u] {
                var component = [String]()
                dfs2(u, component: &component)
                components.append(component)
            }
        }

        return components
    }
    
    
    
    
    /** The number of strongly connected groups
     This uses Kosaraju’s algorithm to estimate the number of strongly connected subgraphs.
     - Returns: Number of disconnected groups
     */
    public var numberOfStronglyConnectedComponents: Int {
        return stronglyConnectedComponents.count
    }
    
    /** The number of disconnected subgraphs for symmetric edges
     - Returns: The number of disconnected componnents.
     */
    public var numberOfComponents: Int {
        var visited = Set<UUID>()
        var components = 0
        
        func dfs(_ nodeId: UUID) {
            visited.insert(nodeId)
            let neighbors = edges.filter { $0.from == nodeId }.map { $0.to }
            for neighbor in neighbors {
                if !visited.contains(neighbor) {
                    dfs(neighbor)
                }
            }
        }
        
        for node in nodes {
            if !visited.contains(node.id) {
                dfs(node.id)
                components += 1
            }
        }
        
        return components
    }
    
    
    
    
    
    
    
    
    // MARK: - Shortest Path Algorithms
    
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
    
    /// Returns all shortest paths between all pairs of nodes.
    public func allShortestPaths() -> [Path] {
        var ret = [Path]()
        for i in 0 ..< self.nodes.count {
            for j in 0 ..< self.nodes.count {
                if i != j {
                    ret.append(contentsOf: allShortestPaths(from: nodes[i], to: nodes[j]))
                }
            }
        }
        return ret
    }
    
    
    /// Overload function to pass node names instead of instances.
    /// - Parameters:
    ///   - from: The starting node name.
    ///   - to: The ending node name.
    /// - Returns: An array of all shortest paths (as Path objects) from `from` to `to`.
    public func allShortestPaths(from: String, to: String) -> [Path] {
        
        if let fromNode = nodes.first( where: { $0.label == from }),
           let toNode = nodes.first( where: { $0.label == to }) {
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
    
    
    
    
    

    
}


