//
//  PlayerViewModel.swift
//  LonesomeDove
//  Created on 1/22/22.
//

import AVFoundation
import Foundation
import Media
import SwiftUI
import UIKit

class PlayerViewModel: PlayerViewDisplayable {
    @Published var isPlaying: Bool

    var images: [UIImage]

    var player: AVPlayer?

    var timeRanges: [CMTimeRange]

    var currentTimeRangeAndImageIndex = 0

    var tintColor: Color = .white

    init(asset: AVAsset,
         images: [UIImage],
         timeRanges: [CMTimeRange]) {
        let playerItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: ["duration", "metadata", "tracks"])
        self.player = AVPlayer(playerItem: playerItem)
        self.images = images
        self.timeRanges = timeRanges
        self.isPlaying = false
    }

    func togglePlayPause() {
        if isPlaying {
            player?.pause()
        } else {
            player?.play()
        }
        isPlaying.toggle()
    }

    func next() {

        guard currentTimeRangeAndImageIndex < timeRanges.count &&
                currentTimeRangeAndImageIndex < images.count
        else {
            return
        }
        currentTimeRangeAndImageIndex += 1
        let nextTimeRange = timeRanges[currentTimeRangeAndImageIndex]
        seek(to: nextTimeRange)
    }

    func previous() {
        guard currentTimeRangeAndImageIndex > 0 &&
                currentTimeRangeAndImageIndex > 0
        else {
            return
        }

        currentTimeRangeAndImageIndex -= 1
        let previousTimeRange = timeRanges[currentTimeRangeAndImageIndex]
        seek(to: previousTimeRange)
    }

    func dismiss() {
        AppLifeCycleManager.shared.router.route(to: .dismissPresentedViewController(nil))
    }

    func move(to imageIndex: Int) {
        guard imageIndex >= 0 &&
                imageIndex < images.count &&
                imageIndex < timeRanges.count
        else { return }

        currentTimeRangeAndImageIndex = imageIndex
        let timeRange = timeRanges[imageIndex]
        seek(to: timeRange)
    }

    private func seek(to timeRange: CMTimeRange) {
        Task { [weak self] in
            self?.player?.seek(to: timeRange.start + CMTime(seconds: (1.0/30.0), preferredTimescale: timeRange.start.timescale))

        }
    }
}
