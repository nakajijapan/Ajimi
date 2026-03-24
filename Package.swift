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
        .library(
            name: "AjimiCore",
            targets: ["AjimiCore"]
        ),
    ],
    targets: [
        .target(
            name: "AjimiCore",
            path: "Source/Classes",
            sources: [
                "AjimiOptions.swift",
                "String+Ajimi.swift",
                "Error.swift",
            ]
        ),
        .target(
            name: "Ajimi",
            dependencies: ["AjimiCore"],
            path: "Source",
            exclude: [
                "Classes/AjimiOptions.swift",
                "Classes/String+Ajimi.swift",
                "Classes/Error.swift",
            ],
            resources: [
                .process("Assets")
            ]
        ),
        .testTarget(
            name: "AjimiCoreTests",
            dependencies: ["AjimiCore"],
            path: "AjimiCoreTests"
        ),
    ]
)
