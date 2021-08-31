// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "SwiftyInsta",
    platforms: [
        .macOS(.v10_14), .iOS(.v12), .tvOS(.v12), .watchOS(.v5)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "SwiftyInsta",
            targets: ["SwiftyInsta"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/evgenyneu/keychain-swift.git", from: "19.0.0"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.3.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "SwiftyInsta",
            dependencies: ["KeychainSwift", "CryptoSwift"],
            path: "SwiftyInsta"
        ),
    ]
)
