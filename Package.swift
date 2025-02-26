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
        ),
        .library(
            name: "PrebidMobileAdMobAdapters",
            targets: ["_PrebidMobileAdMobAdapters"]
        ),
        .library(
            name: "PrebidMobileGAMEventHandlers",
            targets: ["_PrebidMobileGAMEventHandlers"]
        ),
        .library(
            name: "PrebidMobileMAXAdapters",
            targets: ["_PrebidMobileMAXAdapters"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", exact: "11.13.0"),
        .package(url: "https://github.com/AppLovin/AppLovin-MAX-Swift-Package.git", .upToNextMajor(from: "10.3.6"))
    ],
    targets: [
        .target(
            name: "_PrebidMobile",
            dependencies: [
                "PrebidMobile",
                "OMSDK",
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads")
            ],
            path: "Frameworks/PrebidMobile"
        ),
        .target(
            name: "_PrebidMobileAdMobAdapters",
            dependencies: [
                "_PrebidMobile",
                "PrebidMobileAdMobAdapters"
            ],
            path: "Frameworks/PrebidMobileAdMobAdapters"
        ),
        .target(
            name: "_PrebidMobileGAMEventHandlers",
            dependencies: [
                "_PrebidMobile",
                "PrebidMobileGAMEventHandlers"
            ],
            path: "Frameworks/PrebidMobileGAMEventHandlers"
        ),
        .target(
            name: "_PrebidMobileMAXAdapters",
            dependencies: [
                "_PrebidMobile",
                "PrebidMobileMAXAdapters",
                .product(name: "AppLovinSDK", package: "AppLovin-MAX-Swift-Package")
            ],
            path: "Frameworks/PrebidMobileMAXAdapters"
        ),
        .binaryTarget(
            name: "PrebidMobile",
            path: "Frameworks/XCPrebidMobile.xcframework"
        ),
        .binaryTarget(
            name: "PrebidMobileAdMobAdapters",
            path: "Frameworks/XCPrebidMobileAdMobAdapters.xcframework"
        ),
        .binaryTarget(
            name: "PrebidMobileGAMEventHandlers",
            path: "Frameworks/XCPrebidMobileGAMEventHandlers.xcframework"
        ),
        .binaryTarget(
            name: "PrebidMobileMAXAdapters",
            path: "Frameworks/XCPrebidMobileMAXAdapters.xcframework"
        ),
        .binaryTarget(
            name: "OMSDK",
            path: "Frameworks/OMSDK-Static_Prebidorg.xcframework"
        )
    ],
    swiftLanguageVersions: [.v5]
)