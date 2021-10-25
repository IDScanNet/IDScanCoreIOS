// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "IDScanCore",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(
            name: "IDScanCore",
            targets: ["IDScanCore"]),
        .library(
            name: "IDScanComponentTests",
            targets: ["IDScanComponentTests"])
    ],
    targets: [
        .target(
            name: "IDScanCore",
            resources: [
                .copy("ComponentInfo.plist")
            ]
        ),
        .target(
            name: "IDScanComponentTests",
            dependencies: ["IDScanCore"]
        ),
        .target(
            name: "IDScanCoreTestModel",
            dependencies: ["IDScanCore"],
            path: "Tests/IDScanCoreTestModel",
            resources: [
                .copy("ComponentInfo.plist")
            ]
        ),
        .testTarget(
            name: "IDScanCoreTests",
            dependencies: ["IDScanCore", "IDScanComponentTests", "IDScanCoreTestModel"],
            resources: [
                .copy("IDScanComponents.plist")
            ]
        ),
    ]
)
