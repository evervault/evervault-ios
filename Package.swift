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
            url: "https://github.com/evervault/evervault-ios/releases/download/1.1.4/AttestationBindings.xcframework.zip",
            checksum: "3cf5d992689dd0070131290a75b400942881b3b107e1d7a87942269bdd369082"
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
