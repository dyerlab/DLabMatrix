// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.
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

import PackageDescription

let package = Package(
    name: "DLabMatrix",
    platforms: [.iOS(.v14), .macOS(.v10_15)],
    products: [
        .library(
            name: "DLabMatrix",
            targets: ["DLabMatrix"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "DLabMatrix",
            dependencies: []),
        .testTarget(
            name: "DLabMatrixTests",
            dependencies: ["DLabMatrix"]),
    ]
)
