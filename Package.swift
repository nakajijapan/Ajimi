// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Ajimi",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "Ajimi",
            targets: ["Ajimi"]
        ),
    ],
    targets: [
        .target(
            name: "Ajimi",
            path: "Source",
            resources: [
                .process("Assets")
            ]
        ),
        .testTarget(
            name: "AjimiTests",
            dependencies: ["Ajimi"],
            path: "AjimiTests"
        ),
    ]
)
