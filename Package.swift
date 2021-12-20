// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DLabMatrix",
    platforms: [.iOS(.v14), .macOS(.v12)],
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
