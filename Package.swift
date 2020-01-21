// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EDC",
    products: [
        .library(name: "EDC", targets: ["EDC"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"), // 4.0.0-beta.2
    ],
    targets: [
        .target(name: "EDC", dependencies: ["Vapor"]),
        .testTarget(name: "EDCTests", dependencies: ["EDC"]),
    ]
)
