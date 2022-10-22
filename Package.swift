// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Sisyphos",
    platforms: [
        .macOS(.v12),
        .iOS(.v14),
    ],
    products: [
        .library(name: "Sisyphos", targets: ["Sisyphos"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Sisyphos",
            dependencies: []
        ),
        .testTarget(
            name: "SisyphosTests",
            dependencies: [
                "Sisyphos"
            ]
        ),
    ]
)
