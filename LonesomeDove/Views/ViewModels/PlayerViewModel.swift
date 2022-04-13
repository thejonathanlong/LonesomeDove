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

    var player: AVPlayer

    var timeRanges: [CMTimeRange]

    var currentTimeRangeAndImageIndex = 0

    var tintColor: Color = .white

    init(asset: AVAsset,
         images: [UIImage],
         timeRanges: [CMTimeRange]) {
        let playerItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: ["duration", "metadata", "tracks"])
        self.player = AVPlayer(playerItem: playerItem)
        self.images = images
        self.timeRanges = timeRanges.sorted {
            ($0.start + $0.duration) <= $1.start
        }
        self.isPlaying = false
    }

    func togglePlayPause() {
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
    }
    
    func next() {
        let currentTime = player.currentTime()
        let nextTimeRange = timeRanges.first { $0.start > currentTime } ?? CMTimeRange.zero
        currentTimeRangeAndImageIndex = timeRanges.firstIndex(of: nextTimeRange) ?? currentTimeRangeAndImageIndex
        seek(to: nextTimeRange)
    }

    func previous() {
        let currentTime = player.currentTime()
        let currentTimeRange = timeRanges.first { $0.containsTime(currentTime) } ?? CMTimeRange.zero
        let previousTimeRangeIndex = max((timeRanges.firstIndex(of: currentTimeRange) ?? 1) - 1, 0)
        let previousTimeRange = timeRanges[previousTimeRangeIndex]
        currentTimeRangeAndImageIndex = previousTimeRangeIndex
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
            self?.player.seek(to: timeRange.start + CMTime(seconds: (1.0/30.0), preferredTimescale: timeRange.start.timescale))

        }
    }
}
