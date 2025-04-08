// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription


import PackageDescription
 
let package = Package(
    name: "PrebidMobile",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "PrebidMobile",
            targets: ["_PrebidMobile"]
        )
    ],
    targets: [
        .target(
            name: "_PrebidMobile",
            dependencies: [
                "PrebidMobile",
                "OMSDK",
            ],
            path: "Frameworks/PrebidMobile"
        ),
        .binaryTarget(
            name: "PrebidMobile",
            path: "Frameworks/XCPrebidMobile.xcframework"
        ),
        .binaryTarget(
            name: "OMSDK",
            path: "Frameworks/OMSDK-Static_Prebidorg.xcframework"
        )
    ],
    swiftLanguageVersions: [.v5]
)