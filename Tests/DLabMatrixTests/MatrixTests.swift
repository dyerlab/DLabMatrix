//
//  MatrixTests.swift
//  Tests macOS
//
//  Created by Rodney Dyer on 6/7/21.
//

import XCTest
@testable import DLabMatrix

class MatrixTests: XCTestCase {
    
    func testInit() {
        let M = Matrix(4, 4, 1.0)
        
        XCTAssertEqual( M.cols, 4 )
        XCTAssertEqual( M.rows, 4 )
        XCTAssertEqual( M[0,0], 1.0)
        XCTAssertEqual( M.sum, 16.0 )
        
        XCTAssertEqual( M.diagonal, Vector.zeros(4) + 1.0)
        XCTAssertEqual( M.diagonal.sum, 4.0 )
    
        
        
        
        
    }

    func testEquality() throws {
        
        let X = Matrix( 2, 2, 1...4 )
        let Y = Matrix( 2, 2, 2...5 )
        let Z = Matrix( 2, 3 )
        Z[0,0] = 1
        Z[0,1] = 2
        Z[1,0] = 3
        Z[1,1] = 4
        
        XCTAssertFalse( X == Y )
        XCTAssertFalse( X == Z )
        
        XCTAssertEqual( X, Z.submatrix([0,1], [0,1]) )
    }
    
    func testDesignMatrix() throws {
        
        let populations = ["RVA","RVA","RVA","Olympia","Olympia"]
        let X = Matrix.designMatrix(strata: populations )
        
        
        XCTAssertEqual( X.rows, 5)
        XCTAssertEqual( X.cols, 2)
        
        let H = Matrix(5,2)
        H[0,1] = 1.0
        H[1,1] = 1.0
        H[2,1] = 1.0
        H[3,0] = 1.0
        H[4,0] = 1.0
        
        XCTAssertEqual( X, H )
        
    }
    
    
    func testIdempotentDesignMatrix() throws {
        
        let populations = ["RVA","RVA","RVA","Olympia","Olympia"]
        let X = Matrix.idempotentHatMatrix(strata: populations )
         
        let H = Matrix(5,5,0.0)
        let c1 = 1.0 / 3.0
        let c2 = 1.0 / 2.0
        
        H[0,0] = c1
        H[0,1] = c1
        H[0,2] = c1
        H[1,0] = c1
        H[1,1] = c1
        H[1,2] = c1
        H[2,0] = c1
        H[2,1] = c1
        H[2,2] = c1
        
        H[3,3] = c2
        H[3,4] = c2
        H[4,3] = c2
        H[4,4] = c2
                
        XCTAssertTrue( H == X )
        
        
    }
    
}




