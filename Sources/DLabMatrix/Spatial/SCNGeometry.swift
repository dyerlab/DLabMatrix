//                      _                 _       _
//                   __| |_   _  ___ _ __| | __ _| |__
//                  / _` | | | |/ _ \ '__| |/ _` | '_ \
//                 | (_| | |_| |  __/ |  | | (_| | |_) |
//                  \__,_|\__, |\___|_|  |_|\__,_|_.__/
//                        |_ _/
//
//         Making Population Genetic Software That Doesn't Suck
//
//  Copyright (c) 2021-2025 The Dyer Laboratory.  All Rights Reserved.
//
//  SCNGeometry.swift
//  DLabMatrix
//
//  Created by Rodney Dyer on 5/23/25.
//  Copyright (c) 2021-2025 The Dyer Laboratory.  All Rights Reserved.
//

import Foundation
import SceneKit


extension SCNGeometry {
    static func line(from vectorA: SCNVector3, to vectorB: SCNVector3) -> SCNGeometry {
        let vertices: [SCNVector3] = [vectorA, vectorB]
        let vertexSource = SCNGeometrySource(vertices: vertices)
        let indices: [UInt32] = [0, 1]
        let indexData = Data(bytes: indices, count: indices.count * MemoryLayout<UInt32>.size)
        let element = SCNGeometryElement(data: indexData,
                                         primitiveType: .line,
                                         primitiveCount: 1,
                                         bytesPerIndex: MemoryLayout<UInt32>.size)
        return SCNGeometry(sources: [vertexSource], elements: [element])
    }
}


