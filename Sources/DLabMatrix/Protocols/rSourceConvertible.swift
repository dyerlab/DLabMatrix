//  rSourceConvertible.swift
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
//  Created by Rodney Dyer on 1/10/22.
//  Copyright (c) 2021-2025 The Dyer Laboratory.  All Rights Reserved.

import Foundation

public protocol rSourceConvertible {
    
    func toR() -> String
    
}
