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
        .package(url: "https://github.com/birdrides/mockingbird.git", .upToNextMinor(from: "0.20.0")),
        .package(
            url: "https://github.com/evervault/evervault-pay.git",
            from: "0.0.20"
        ),
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
                .product(name: "EvervaultPayment", package: "evervault-pay"),
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
            url: "https://github.com/evervault/evervault-ios/releases/download/1.1.5/AttestationBindings.xcframework.zip",
            checksum: "444c0cb0baab41754d6052994e482e8f096befa7b40eb4e7f77fdcb1d0e52bc7"
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
