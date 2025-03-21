/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import XCTest
import GoogleMobileAds
import PrebidMobileGAMEventHandlers

class PBMGAMBannerEventHandlerTests: XCTestCase {
    
    func testAdSizesConversion() {
     
        // Static sizes
        runSizeCheck(AdSizeBanner           , CGSize(width: 320, height: 50))
        runSizeCheck(AdSizeLargeBanner      , CGSize(width: 320, height: 100))
        runSizeCheck(AdSizeMediumRectangle  , CGSize(width: 300, height: 250))
        runSizeCheck(AdSizeFullBanner       , CGSize(width: 468, height: 60))
        runSizeCheck(AdSizeLeaderboard      , CGSize(width: 728, height: 90))
        runSizeCheck(AdSizeSkyscraper       , CGSize(width: 120, height: 600))

        // Dynamic sizes: need to test with iPhone 11

        /// An ad size that spans the full width of the application in portrait orientation. The height is
        /// typically 50 points on an iPhone/iPod UI, and 90 points tall on an iPad UI.
        runSizeCheck(portraitAnchoredAdaptiveBanner(width: 414), CGSize(width: 414, height: 65))


        /// An ad size that spans the full width of the application in landscape orientation. The height is
        /// typically 32 points on an iPhone/iPod UI, and 90 points tall on an iPad UI.
        runSizeCheck(landscapeAnchoredAdaptiveBanner(width: 896), CGSize(width: 896, height: 59))


        /// An ad size that spans the full width of its container, with a height dynamically determined by
        /// the ad.
        runSizeCheck(AdSizeFluid, CGSize(width: 393, height: 1))


        // Invalid ad size marker.
        runSizeCheck(AdSizeInvalid, CGSize(width: 0, height: 0))
    }
    
    func testAdSizesArray() {
        
        let GADSizes = [
            nsValue(for: AdSizeBanner),
            nsValue(for: AdSizeMediumRectangle),
            nsValue(for: AdSizeInvalid)
        ]
        
        let eventHandler = GAMBannerEventHandler(adUnitID: "some_id", validGADAdSizes: GADSizes);
        
        XCTAssertEqual(eventHandler.adSizes.count, 3)
        
        XCTAssertEqual(eventHandler.adSizes[0]  , CGSize(width: 320, height: 50))
        XCTAssertEqual(eventHandler.adSizes[1]  , CGSize(width: 300, height: 250))
        XCTAssertEqual(eventHandler.adSizes[2]  , CGSize(width: 0, height: 0))
    }
    
    func testInvalidValue() {
        runCheckInvalidValue(NSValue(nonretainedObject:42))
        runCheckInvalidValue(NSValue(pointer:"Do not panic!"))
    }
    
    
    func runSizeCheck(_ GADSize: AdSize, _ size: CGSize, file: StaticString = #file, line: UInt = #line) {
        
        let eventHandler = GAMBannerEventHandler(
            adUnitID: "some_id",
            validGADAdSizes: [nsValue(for: GADSize)]
        )
        
        let val = eventHandler.adSizes.first!
        
        XCTAssertEqual(val, size, file: file, line: line)
    }
    
    func runCheckInvalidValue(_ value: NSValue, file: StaticString = #file, line: UInt = #line) {
        
        let eventHandler = GAMBannerEventHandler(adUnitID: "some_id", validGADAdSizes: [value]);
        let val = eventHandler.adSizes.first!
        
        XCTAssertEqual(val, CGSize(width: 0, height: 0), file: file, line: line)
    }
}
