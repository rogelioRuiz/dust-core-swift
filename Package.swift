// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "dust-core-swift",
    platforms: [.iOS(.v14), .macOS(.v12)],
    products: [
        .library(name: "DustCore", targets: ["DustCore"])
    ],
    targets: [
        .target(name: "DustCore", path: "Sources/DustCore"),
        .testTarget(name: "DustCoreTests", dependencies: ["DustCore"], path: "Tests/DustCoreTests")
    ],
    swiftLanguageVersions: [.v5]
)
