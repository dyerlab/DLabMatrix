//
//  MatrixTests.swift
//  Tests macOS
//                      _                 _       _
//                   __| |_   _  ___ _ __| | __ _| |__
//                  / _` | | | |/ _ \ '__| |/ _` | '_ \
//                 | (_| | |_| |  __/ |  | | (_| | |_) |
//                  \__,_|\__, |\___|_|  |_|\__,_|_.__/
//                        |_ _/
//
//         Making Population Genetic Software That Doesn't Suck
//
//  Created by Rodney Dyer on 6/7/21.
//  Copyright (c) 2021-2025 The Dyer Laboratory.  All Rights Reserved.
//

import Testing
import SceneKit
import CoreGraphics

@testable import DLabMatrix

struct VectorTests {
    
    @Test
    func testInit() {
        let v = Vector(repeating: 2.2, count: 4 )
        
        #expect(v.count == 4)
        #expect(v.sum == 8.8)

        #expect(v[1] == 2.2)
        #expect(v.magnitude == sqrt( 19.36))
        #expect(v.normal == [0.5, 0.5, 0.5, 0.5])
        
        let v1 = Vector([1.0,2.0,3.0])
        #expect(v1.x == 1.0)
        #expect(v1.y == 2.0)

        #expect(v1.asCGPoint == CGPoint( x: 1.0, y: 2.0) )
        
        let v1svn = v1.asSNCVector3
        #expect(v1svn.x == 1.0)
        #expect(v1svn.y == 2.0)
        #expect(v1svn.z == 3.0)
        
        let v2 = [-2.3, 2.1, 2.8]
        #expect(v2.limitAnnealingMagnitude(temp: 2.2) == [-2.2, 2.1, 2.2 ])
        #expect(Vector.zeros(3) == [0.0, 0.0, 0.0])
        
    }
    
    
    @Test
    func testOperators() {
        
        let x = [ 1.0 ,2.0, 3.0 ]
        let y = [ 3.0, 2.0, 1.0 ]
        let s = 2.0
        
        #expect(x+s == [3.0, 4.0, 5.0])
        #expect(x-s == [-1.0, 0.0, 1.0])
        #expect(x*s == [2.0, 4.0, 6.0])
        #expect(x/s == [ 1.0/2.0,
                               2.0/2.0,
                               3.0/2.0])
        
        #expect(x + y == [4.0, 4.0, 4.0])
        #expect(x - y == [-2.0, 0.0, 2.0])
        #expect(x * y == [3.0, 4.0, 3.0])
        #expect(x / y == [1.0/3.0, 2.0/2.0, 3.0/1.0])
        
        #expect(x .* y == 10.0)
        #expect(distance(x,y) == sqrt( (x - y).map { $0 * $0 }.sum ))
        
        #expect(amovaDistance( [ 0.0, 2.0, 0.0], [ 2.0, 0.0, 0.0] ) == 4.0)
        #expect(amovaDistance( [ 0.0, 2.0, 0.0], [ 1.0, 1.0, 0.0] ) == 1.0)
        #expect(amovaDistance( [ 1.0, 0.0, 1.0], [ 0.0, 2.0, 0.0] ) == 3.0)
        #expect(amovaDistance( [ 1.0, 1.0, 0.0], [ 0.0, 1.0, 1.0] ) == 1.0)
        #expect(amovaDistance( [ 2.0, 0.0, 0.0], [ 2.0, 0.0, 0.0] ) == 0.0)
        #expect(amovaDistance( [ 1.0, 1.0, 0.0, 0.0], [ 0.0, 0.0, 1.0, 1.0] ) == 2.0)

    }
    
    
    
    @Test
    func testRSourceConvertable() {
        
        let x = Vector(repeating: 1.0, count: 10)
        #expect(x.count == 10)
        
        let r = x.toR()
        #expect(!r.isEmpty)
        #expect(r == "c(1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0)")
        
    }

}
