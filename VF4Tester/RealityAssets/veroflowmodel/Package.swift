// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "veroflowmodel",
    platforms: [
        .iOS(.v16),  // CHANGE: Lower iOS requirement to match your app
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "veroflowmodel",
            targets: ["veroflowmodel"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "veroflowmodel",
            dependencies: [],
            resources: [.process("Resources")]
        ),
    ]
)