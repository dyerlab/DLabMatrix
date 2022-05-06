//
//  File.swift
//  
//
//  Created by Rodney Dyer on 5/6/22.
//

import Foundation

/*
 The Floyd Warshall method for determining the shortest path
 between all pairs of nodes.
 */
func shortestPath( A: Matrix ) -> Matrix {
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
