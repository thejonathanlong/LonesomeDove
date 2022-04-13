//
//  PlayerViewModelTests.swift
//  LonesomeDoveTests
//
//  Created on 4/12/22.
//

@testable import LonesomeDove
import XCTest
import AVFoundation

class PlayerViewModelTests: XCTestCase {
    
    func testInitSortsTimeRanges() throws {
        let assetURL = try XCTUnwrap(URL(string: "https://movietrailers.apple.com/movies/disney/lightyear/lightyear-trailer-1_480p.mov"))
        let asset = AVAsset(url: assetURL)
        let images = [
            UIImage(named: "test_image"),
            UIImage(named: "test_image")
        ]
            .compactMap { $0 }
        let timeRanges = [
            CMTimeRange(start: CMTime(seconds: 1, preferredTimescale: 60000), duration: CMTime(seconds: 1, preferredTimescale: 60000)),
            CMTimeRange(start: CMTime(seconds: 0, preferredTimescale: 60000), duration: CMTime(seconds: 1, preferredTimescale: 60000))
        ]
        let playerViewModel = PlayerViewModel(asset: asset, images: images, timeRanges: timeRanges)
        
        let sortedTimeRanges = [
            CMTimeRange(start: CMTime(seconds: 0, preferredTimescale: 60000), duration: CMTime(seconds: 1, preferredTimescale: 60000)),
            CMTimeRange(start: CMTime(seconds: 1, preferredTimescale: 60000), duration: CMTime(seconds: 1, preferredTimescale: 60000))
        ]
        XCTAssertEqual(sortedTimeRanges, playerViewModel.timeRanges)
    }
    
    func testInitKeepsTimeRangesSorted() throws {
        let assetURL = try XCTUnwrap(URL(string: "https://movietrailers.apple.com/movies/disney/lightyear/lightyear-trailer-1_480p.mov"))
        let asset = AVAsset(url: assetURL)
        let images = [
            UIImage(named: "test_image"),
            UIImage(named: "test_image")
        ]
            .compactMap { $0 }
        let sortedTimeRanges = [
            CMTimeRange(start: CMTime(seconds: 0, preferredTimescale: 60000), duration: CMTime(seconds: 1, preferredTimescale: 60000)),
            CMTimeRange(start: CMTime(seconds: 1, preferredTimescale: 60000), duration: CMTime(seconds: 1, preferredTimescale: 60000))
        ]
        let playerViewModel = PlayerViewModel(asset: asset, images: images, timeRanges: sortedTimeRanges)
        
        
        XCTAssertEqual(sortedTimeRanges, playerViewModel.timeRanges)
    }
}
