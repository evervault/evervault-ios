// swift-tools-version: 5.8

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
            targets: ["EvervaultCages"]
        ),
        .library(
            name: "AttestationBindings",
            targets: ["AttestationBindings"]
        )
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
//            path: "AttestationBindings.xcframework"
            url: "https://github.com/lammertw/attestation-doc-validation/releases/download/0.0.3/AttestationBindings.xcframework.zip",
            checksum: "9bb3e9f85c6c99c16526ee61566e1f4424a5b44b0f264e6186d27114db40c878"
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
