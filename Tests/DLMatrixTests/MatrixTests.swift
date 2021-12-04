//
//  MatrixTests.swift
//  Tests macOS
//
//  Created by Rodney Dyer on 6/7/21.
//

import XCTest
@testable import DLMatrix

class MatrixTests: XCTestCase {
    
    func testInit() {
        let M = Matrix(4, 4, 1.0)
        
        XCTAssertEqual( M.cols, 4 )
        XCTAssertEqual( M.rows, 4 )
        XCTAssertEqual( M[0,0], 1.0)
        XCTAssertEqual( M.sum, 0.0 )
        
    }

}
