//
//  dyerlab.org                                          @dyerlab
//                      _                 _       _
//                   __| |_   _  ___ _ __| | __ _| |__
//                  / _` | | | |/ _ \ '__| |/ _` | '_ \
//                 | (_| | |_| |  __/ |  | | (_| | |_) |
//                  \__,_|\__, |\___|_|  |_|\__,_|_.__/
//                        |_ _/
//
//         Making Population Genetic Software That Doesn't Suck
// 
//  DLabMatrix
//  RangeEnum.swift
//
//  Created by Rodney Dyer on 6/15/21.
//  Copyright (c) 2021-2025 The Dyer Laboratory.  All Rights Reserved.

import Foundation

public enum RangeEnum: Int, CaseIterable, Comparable {
    case uniform_0_1 = 1
    case uniform_neg1_1 = 2
    case normal_0_1 = 3
    
    public static func < (lhs: RangeEnum, rhs: RangeEnum) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
