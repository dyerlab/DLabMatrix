//
//  MatrixAlgebra.swift
//                      _                 _       _
//                   __| |_   _  ___ _ __| | __ _| |__
//                  / _` | | | |/ _ \ '__| |/ _` | '_ \
//                 | (_| | |_| |  __/ |  | | (_| | |_) |
//                  \__,_|\__, |\___|_|  |_|\__,_|_.__/
//                        |_ _/
//
//         Making Population Genetic Software That Doesn't Suck
//
//
//
//  Created by Rodney Dyer on 6/10/21.
//  Copyright (c) 2021-2025 The Dyer Laboratory.  All Rights Reserved.
//


import Accelerate

public func GeneralizedInverse(_ X: Matrix ) -> Matrix {
    
    if X.rows != X.cols {
        return Matrix(0,0)
    }
    
    let Y = Matrix( X.rows, X.cols, X.values )
    var M = __CLPK_integer(X.rows)
    var N = M
    var LDA = N
    var pivot = [__CLPK_integer](repeating: 0, count: Int(N))
    var wkOpt = __CLPK_doublereal(0.0)
    var lWork = __CLPK_integer(-1)
    var error: __CLPK_integer = 0
    
    dgetrf_(&M, &N, &(Y.values), &LDA, &pivot, &error)
    
    if error != 0 {
        print("Error on dgetrf_, could not compute LU factorization ")
        return Matrix(0,0)
    }
    
    /* Query and allocate the optimal workspace */
    dgetri_(&N, &(Y.values), &LDA, &pivot, &wkOpt, &lWork, &error)
    lWork = __CLPK_integer(wkOpt)
    var work = Vector(repeating: 0.0, count: Int(lWork))
    
    /* Compute inversed matrix */
    dgetri_(&N, &(Y.values), &LDA, &pivot, &work, &lWork, &error)
    
    if error != 0 {
        print("Error on dgetrf_, could not invert matrix")
        return Matrix(0,0)
    }
    
    return Y
}




/// Principal Component Rotation
///
/// This function estimates a Principal Coponent Rotation on the passed data matrix.
/// - Parameter X: A data matrix
/// - Returns: A tuple with the eigenvalues (d), the eigenvectors (V) and the rotation on the original data (X).
public func PCRotation(_ X: Matrix ) -> (d: Vector, V: Matrix, X: Matrix)? {
    let A = X
    A.center()
    
    guard let s = SingularValueDecomposition( A ) else { return nil }
    
    let d = s.d / ( sqrt( max(1.0, Double( A.rows )-1.0)))
    let V = s.V
    let X = X .* V
    
    return (d,V,X)
}



/// Compute the Singular Value Decomposition of a Matrix
///
/// This decomposes the matrix such that **A = U * Matrix( d.count,d.count,d,true) * V.transpose()**.
/// - Parameter A: The matrix to partition
/// - Returns: The left and right eigenvalue matrices and the vector of igenvalues.
public func SingularValueDecomposition(_ A: Matrix) -> (U: Matrix, d: Vector, V: Matrix)? {
    var M = __CLPK_integer(A.rows);
    var N = __CLPK_integer(A.cols);
    
    var LDA = M;
    var LDU = M;
    var LDV = N;
    
    var wkOpt = __CLPK_doublereal(0.0)
    var lWork = __CLPK_integer(-1)
    var iWork = [__CLPK_integer](repeating: 0, count: Int(8 * min(M, N)))
    var error = __CLPK_integer(0)
    
    var d = Vector(repeating: 0.0, count: Int( min(M, N) ) )
    
    let U = Matrix(Int(LDU), Int(M))
    let V = Matrix(Int(LDV), Int(N))
    
    // Query and allocate the optimal workspace
    let _A = A.transpose
    var jobz: Int8 = 65 // It is 'A'
    dgesdd_(&jobz,
            &M, &N,
            &_A.values,
            &LDA, &d,
            &U.values,
            &LDU,
            &V.values, &LDV,
            &wkOpt, &lWork, &iWork,
            &error)
    
    // Catch any error
    if error != 0 {
        let logger = Logger()
        logger.notice("Could not allocate workspace for SVD decomposition.")
        return nil
    }
    
    lWork = __CLPK_integer(wkOpt)
    var work = Vector(repeating: 0.0, count: Int(lWork))
    
    // Compute the singular value decomposition
    dgesdd_(&jobz,
            &M, &N,
            &_A.values,
            &LDA, &d, &U.values,
            &LDU, &V.values,
            &LDV,
            &work, &lWork, &iWork,
            &error)
    
    // Catch any error
    if error != 0 {
        let logger = Logger()
        logger.notice("Could not compute SVD.")
        return nil
    }
    
    let rows = Array(0..<V.rows)
    let cols = Array(0..<d.count)
    return (U.transpose, d, V.submatrix( rows, cols ) )
    
    
}


// MARK: - Eigenvector Computation


/// Computes the dominant eigenvector of the matrix using the power iteration method.
/// - Parameters:
///   - A: A square matrix
///   - tolerance: The convergence tolerance.
///   - maxIterations: Maximum number of iterations.
/// - Returns: The normalized dominant eigenvector as a Vector, or nil if not converged.
public func DominantEigenvector(A: Matrix, tolerance: Double = 1e-6, maxIterations: Int = 1000) -> Vector? {
    
    guard A.rows == A.cols, A.rows > 0 else { return nil }
    
    // Start with a random vector
    var v = Vector((0..<A.cols).map { _ in Double.random(in: -1.0...1.0) })
    
    // Normalize
    let norm = sqrt(v.reduce(0.0) { $0 + $1 * $1 })
    if norm == 0.0 { return nil }
    v = v.map { $0 / norm }
    var prevV = v
    
    for _ in 0..<maxIterations {
        // Multiply matrix by vector
        var nextV = Vector(repeating: 0.0, count: A.cols)
        for r in 0..<A.rows {
            var sum = 0.0
            for c in 0..<A.cols {
                sum += A[r, c] * v[c]
            }
            nextV[r] = sum
        }
        // Normalize
        let nextNorm = sqrt(nextV.reduce(0.0) { $0 + $1 * $1 })
        if nextNorm == 0.0 { return nil }
        nextV = nextV.map { $0 / nextNorm }
        // Check for convergence
        let diff = zip(nextV, prevV).map { abs($0 - $1) }.max() ?? 0.0
        if diff < tolerance {
            return nextV
        }
        prevV = nextV
        v = nextV
    }
    
    // If not converged, return nil
    return nil
}



// MARK: - Methods that support Population Graph Construction

/// Returns a matrix of group centroids (mean per column for each group in `grouping`)
public func CentroidDistance(_ X: Matrix, grouping: [String]) -> Matrix {
    // Ensure grouping length matches the number of rows
    guard grouping.count == X.rows else {
        fatalError("Your grouping and predictor variables should have the same number of rows.... Come on now.")
    }

    // Identify unique groups and sort them
    let uniqueGroups = Array(Set(grouping)).sorted()
    var centroids: [Double] = []
    var rowNames: [String] = []

    for group in uniqueGroups {
        // Get row indices for this group
        let indices = grouping.enumerated().compactMap { $0.element == group ? $0.offset : nil }

        if indices.isEmpty { continue }

        // Accumulate group rows
        let groupMatrix = Matrix(indices.count, X.cols)
        for (i, rowIndex) in indices.enumerated() {
            for j in 0..<X.cols {
                groupMatrix[i, j] = X[rowIndex, j]
            }
        }

        // Calculate column means
        let means = groupMatrix.colSum / Double(groupMatrix.rows)
        centroids.append(contentsOf: means)
        rowNames.append(group)
    }

    let result = Matrix(uniqueGroups.count, X.cols, Vector(centroids))
    result.rowNames = rowNames
    result.colNames = X.colNames
    return result
}




/// Returns a vector of total variances (trace of covariance matrix) for each group in `grouping`
public func CentroidVariance(_ X: Matrix, grouping: [String]) -> [String: Double] {
    // Ensure grouping length matches the number of rows
    guard grouping.count == X.rows else {
        fatalError("Your grouping and predictor variables should have the same number of rows.... Come on now.")
    }

    // Identify unique groups and sort them
    let uniqueGroups = Array(Set(grouping)).sorted()
    var result: [String: Double] = [:]

    for group in uniqueGroups {
        // Get row indices for this group
        let indices = grouping.enumerated().compactMap { $0.element == group ? $0.offset : nil }
        guard !indices.isEmpty else { continue }

        // Create a matrix for the subgroup
        let groupMatrix = Matrix(indices.count, X.cols)
        for (i, rowIndex) in indices.enumerated() {
            for j in 0..<X.cols {
                groupMatrix[i, j] = X[rowIndex, j]
            }
        }

        // Center the matrix
        groupMatrix.center()

        // Compute covariance matrix
        let covariance = (groupMatrix.transpose .* groupMatrix) / Double(groupMatrix.rows - 1)

        // Compute trace (sum of diagonal)
        let variance = covariance.trace

        result[group] = variance
    }

    return result
}


/// A Swift equivalent to R's prcomp(x, retx = TRUE, center = TRUE, scale. = FALSE)
/// Returns a tuple of standard deviations, rotation matrix (eigenvectors), and principal component scores.
public func PRComp(_ X: Matrix) -> (sdev: Vector, rotation: Matrix, x: Matrix)? {
    // Center the data
    let centered = Matrix(X.rows, X.cols, X.values)
    centered.center()

    // Perform SVD
    guard let s = SingularValueDecomposition(centered) else { return nil }

    // s.d contains the singular values. Standard deviations = s.d / sqrt(n - 1)
    let n = Double(centered.rows)
    let sdev = s.d / sqrt(n - 1.0)

    // s.V is the rotation matrix (eigenvectors)
    let rotation = s.V

    // Principal component scores = X_centered * rotation
    let x = centered .* rotation

    return (sdev, rotation, x)
}


/// Swift version of the popgraph function from Dyer & Nason (2004)
/// - Parameters:
///   - X: A data matrix (rows are samples, columns are features)
///   - grouping: An array of population labels for each row
///   - critVal: Critical chi-square value for edge retention
///   - tol: Tolerance level for standard deviation and collinearity filtering
/// - Returns: A weighted adjacency matrix representing the graph topology
public func PopGraph(_ X: Matrix, grouping: [String], critVal: Double = 3.841459, tol: Double = 1.0e-4) -> Matrix {
    let N = grouping.count
    let groups = Array(Set(grouping)).sorted()
    let K = groups.count

    let EdgeStr = Matrix(K, K, 0.0)

    guard let pca = PRComp(X) else { return EdgeStr }

    let filteredIndices = (0..<pca.sdev.count).filter { pca.sdev[$0] > tol }
    let mv = Matrix(X.rows, filteredIndices.count, 0.0)
    for i in 0..<X.rows {
        for (jIndex, j) in filteredIndices.enumerated() {
            mv[i, jIndex] = pca.x[i, j]
        }
    }

    let P = mv.cols
    let popPriors = groups.map { g in Double(grouping.filter { $0 == g }.count) / Double(N) }

    let popMeans = Matrix(K, P, 0.0)
    for (i, g) in groups.enumerated() {
        let indices = grouping.enumerated().compactMap { $0.element == g ? $0.offset : nil }
        for j in 0..<P {
            let colMean = indices.map { mv[$0, j] }.reduce(0.0, +) / Double(indices.count)
            popMeans[i, j] = colMean
        }
    }

    var sigmaW = Vector(repeating: 0.0, count: P)
    for j in 0..<P {
        var colResiduals = Vector(repeating: 0.0, count: N)
        for i in 0..<N {
            let groupIndex = groups.firstIndex(of: grouping[i])!
            colResiduals[i] = mv[i, j] - popMeans[groupIndex, j]
        }
        sigmaW[j] = sqrt(colResiduals.variance)
    }

    for j in 0..<P {
        if sigmaW[j] < tol {
            sigmaW[j] = 1.0 // avoid division by near-zero
        }
    }

    let scaling1 = Matrix.DiagonalMatrix(diagonal:  sigmaW.map { 1.0 / $0 } )
    let fac = 1.0 / Double(N - K)
    // Build a matrix where each row is the group mean for the sample's group
    let groupMeansMatrix = Matrix(mv.rows, mv.cols)
    for i in 0..<grouping.count {
        if let groupIndex = groups.firstIndex(of: grouping[i]) {
            for j in 0..<mv.cols {
                groupMeansMatrix[i, j] = popMeans[groupIndex, j]
            }
        }
    }

    // Apply scaling and factor
    let X1 = ((mv - groupMeansMatrix) * sqrt(fac)) .* scaling1
    let X1SVD = SingularValueDecomposition(X1)!
    let rank1 = X1SVD.d.filter { $0 > tol }.count
    
    let V1 = X1SVD.V.submatrix(Array(0..<X1SVD.V.rows), Array(0..<rank1))
    let D1Inv = Matrix.DiagonalMatrix(diagonal: (0..<rank1).map { 1.0 / X1SVD.d[$0] })
    let scaling2 = scaling1 .* V1 .* D1Inv

    var mu = Vector(repeating: 0.0, count: P)
    for i in 0..<K {
        for j in 0..<P {
            mu[j] += popPriors[i] * popMeans[i, j]
        }
    }

    let centeredMeans = Matrix(K, P, 0.0)
    for i in 0..<K {
        for j in 0..<P {
            centeredMeans[i, j] = popMeans[i, j] - mu[j]
        }
    }

    let scalingVector = popPriors.map { sqrt(Double(N) * $0 / Double(K - 1)) }
    let scalingMatrix = Matrix.DiagonalMatrix(diagonal: scalingVector)
    let X2 = centeredMeans .* scalingMatrix .* scaling2
    
    let X2SVD = SingularValueDecomposition(X2)!
    let rank2 = X2SVD.d.filter { $0 > tol * X2SVD.d[0] }.count
    let finalScaling = scaling2 .* X2SVD.V.submatrix(Array(0..<X2SVD.V.rows), Array(0..<rank2))

    let meanLD = (0..<P).map { j in
        (0..<K).map { i in popMeans[i, j] }.reduce(0.0, +) / Double(K)
    }

    let LDValues = Matrix(X.rows, rank2, 0.0)
    for i in 0..<X.rows {
        for j in 0..<rank2 {
            var sum = 0.0
            for k in 0..<P {
                sum += (mv[i, k] - meanLD[k]) * finalScaling[k, j]
            }
            LDValues[i, j] = sum
        }
    }

    let allLD = CentroidDistance(LDValues, grouping: grouping)
    // let allSD = CentroidVariance(LDValues, grouping: grouping)

    let D = Matrix(K, K, 0.0)
    for i in 0..<K {
        for j in i..<K {
            if i != j {
                let p1 = allLD.getRow(r: i)
                let p2 = allLD.getRow(r: j)
                D[j, i] = sqrt(zip(p1, p2).map { pow($0 - $1, 2.0) }.reduce(0.0, +))
                D[i, j] = D[j,i]
            }
        }
    }

    let totMean = D.values.filter { $0 > 0 }.reduce(0.0, +) / Double(K * (K - 1))
    let colMeans = (0..<K).map { i in D.getCol(c: i).reduce(0.0, +) / Double(K) }
    let colMeanMatrix = Matrix(K, K, Vector(repeating: 0.0, count: K * K))
    let rowMeanMatrix = Matrix(K, K, Vector(repeating: 0.0, count: K * K))
    for i in 0..<K {
        for j in 0..<K {
            colMeanMatrix[i, j] = colMeans[j]
            rowMeanMatrix[i, j] = colMeans[i]
        }
    }

    let C = (D - colMeanMatrix - rowMeanMatrix + totMean) * -0.5

    let R = Matrix(K, K, 1.0)
    for i in 0..<K {
        for j in 0..<K where i != j {
            R[i, j] = C[i, j] / sqrt(C[i, i] * C[j, j])
        }
    }

    let RI = GeneralizedInverse(R)
    let SRI = Matrix(K, K, 1.0)
    for i in 0..<K {
        for j in 0..<K where i != j {
            SRI[i, j] = -1.0 * RI[i, j] / sqrt(RI[i, i] * RI[j, j])
        }
    }

    for i in 0..<K {
        for j in 0..<K {
            SRI[i, j] = 1.0 - pow(SRI[i, j], 2.0)
            if SRI[i, j] < 0.0 {
                SRI[i, j] = 0.0
            }
        }
    }

    let EED = Matrix(K, K, 0.0)
    for i in 0..<K {
        for j in 0..<K {
            EED[i, j] = -Double(N) * log(SRI[i, j])
            if EED[i, j] <= critVal {
                D[i, j] = 0.0
            }
        }
    }

    return D
}
