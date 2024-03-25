// swift-tools-version: 5.7.1

import PackageDescription

let package = Package(
    name: "Evervault",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "EvervaultCore",
            targets: ["EvervaultCore"]
        ),
        .library(
            name: "EvervaultInputs",
            targets: ["EvervaultInputs"]
        ),
        .library(
            name: "EvervaultEnclaves",
            targets: ["EvervaultEnclaves", "AttestationBindings"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/birdrides/mockingbird.git", .upToNextMinor(from: "0.20.0"))
    ],
    targets: [
        .target(
            name: "EvervaultCore",
            dependencies: []
        ),
        .target(
            name: "EvervaultInputs",
            dependencies: [
                "EvervaultCore",
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "EvervaultEnclaves",
            dependencies: [
                "AttestationBindings",
                "EvervaultCore",
            ]
        ),
        .binaryTarget(
            name: "AttestationBindings",
            url: "https://github.com/evervault/evervault-ios/releases/download/1.0.0/AttestationBindings.xcframework.zip",
            checksum: "eacbe39e953e77c688ab1e051210dee07802c7787f5e60c32eb53ae338b9baeb"
        ),
        .testTarget(
            name: "EvervaultCoreTests",
            dependencies: [
                "EvervaultCore",
                .product(name: "Mockingbird", package: "mockingbird")
            ]
        ),
        .testTarget(
            name: "EvervaultInputsTests",
            dependencies: [
                "EvervaultCore",
                "EvervaultInputs",
                .product(name: "Mockingbird", package: "mockingbird")
            ]
        ),
    ]
)
