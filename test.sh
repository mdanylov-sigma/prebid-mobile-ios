#!/bin/sh

FILES=(
"Package.swift"
"Frameworks/OMSDK-Static_Prebidorg.xcframework"
"Frameworks/XCPrebidMobile.xcframework"
)

rsync -a --delete Package.swift test/
rsync -a --delete Frameworks/OMSDK-Static_Prebidorg.xcframework test/Frameworks/
rsync -a --delete Frameworks/XCPrebidMobile.xcframework test/Frameworks/