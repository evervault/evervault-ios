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
            name: "EvervaultCages",
            targets: ["EvervaultCages", "AttestationBindings"]
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
            name: "EvervaultCages",
            dependencies: [
                "AttestationBindings",
                "EvervaultCore",
            ]
        ),
        .binaryTarget(
            name: "AttestationBindings",
            url: "https://github.com/evervault/evervault-ios/releases/download/0.0.4/AttestationBindings.xcframework.zip",
            checksum: "26ac62d988a9752e3580f636f1f47561e2541911dd7350151ba0d43a086a86d4"
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
